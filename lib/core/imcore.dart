// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/heart_beat_message.dart';
import 'package:dearim/core/protocol/login.dart';
import 'package:dearim/core/protocol/protocol.dart';
import 'package:dearim/core/protocol/push_immessage.dart';
import 'package:dearim/core/protocol/send_immessage.dart';
import 'package:dearim/core/protocol/trans.dart';
import 'package:dearim/core/session.dart';
import 'package:dearim/core/sync.dart';
import 'package:dearim/core/utils.dart';
import 'package:dearim/utils/text_utils.dart';

import '../config.dart';
import 'device.dart';
import 'file_upload.dart';
import 'log.dart';
import 'heart_beat.dart';
import 'protocol/kickoff.dart';
import 'protocol/logout.dart';
import 'protocol/message.dart';
import 'reconnect.dart';

///
/// IM服务
///
///

//客户端状态
enum ClientState {
  unconnect, //未连接
  connecting, //连接中
  unlogin, //已连接 但未登录
  loging, //登录中
  logined, //登录成功
  logouting, //注销中
  undef, //未定义
}

enum DataStatus {
  errorMagicNumber, //协议解析错误
  errorVersion, //版本错误
  errorBodyEncode, //消息体编码方式不兼容
  errorOther, //其他错误
  errorLength, //数据长度不足
  duplicate,//重复消息
  success, //成功
}

//im登录回调
typedef IMLoginCallback = Function(Result loginResult);

//im注销回调
typedef IMLogOutCallback = Function(Result result);

//发送IM消息 回调
typedef SendIMMessageCallback = Function(IMMessage imMessage, Result result);

//删除IM消息 
typedef RemoveIMMessgaeCallback = Function(IMMessage msg, Result result);

//发送IM消息 附件状态回调
typedef IMMessageAttachStatusChangeCallback = Function(IMMessage imMessage , AttachState attachState);

//发送透传消息 回调
typedef SendTransMessageCallback = Function(
    TransMessage transMessage, Result result);

//状态改变回调
typedef StateChangeCallback = Function(
    ClientState oldState, ClientState newState);

//被踢出事件回调
typedef KickoffCallback = Function();

//接收到新消息
typedef IMMessageIncomingCallback = Function(
    List<IMMessage> incomingIMMessageList);

//接收透传消息回调
typedef TransMessageIncomingCallback = Function(TransMessage transMessage);

//handler抽象类
abstract class MessageHandler<T> {
  void handle(IMClient client, T msg);
}

class IMClient {
  // static String _serverAddress = "10.242.142.129"; //
  // static String _serverAddress = "192.168.31.230"; //mac
  // static String _serverAddress = "192.168.31.37";//windows
  static String _serverAddress = HOST;

  static int _port = 1013;

  static IMClient? _instance;

  static String get ServerAddress => _serverAddress;

  static int get Port => _port;

  IMLoginCallback? get loginCallback => _loginCallback;

  IMLogOutCallback? get logoutCallback => _logoutCallback;

  int get uid => _uid;

  ClientState get state => _state;

  Reconnect get reconnect => _reconnect;

  KickoffCallback? get kickoffCallback => _kickoffCallback;

  Map<String, SendIMMessageCallback> get sendIMMessageCallbackMap =>
      _sendIMMessageCallbackMap;

  Map<String, SendTransMessageCallback> get sendTransMessageCallbackMap =>
      _sendTransMessageCallbackMap;

  int get sessionUnreadCount => _sessionManager.totalUnreadCount;

  //用户id
  int _uid = -1;

  //注册token
  String? _token;

  ClientState _state = ClientState.undef;

  IMLoginCallback? _loginCallback;

  IMLogOutCallback? _logoutCallback;

  KickoffCallback? _kickoffCallback;

  Socket? _socket;

  int _receivedPacketCount = 0;

  bool _loginIsManual = false; //记录是否是手动发起的登录

  final SessionManager _sessionManager = SessionManager();

  //发送IM消息回调
  final Map<String, SendIMMessageCallback> _sendIMMessageCallbackMap =
      <String, SendIMMessageCallback>{};

  final Map<String, SendTransMessageCallback> _sendTransMessageCallbackMap =
      <String, SendTransMessageCallback>{};

  final List<IMMessageIncomingCallback> _imMessageIncomingCallbackList =
      <IMMessageIncomingCallback>[];

  final ByteBuf _dataBuf = ByteBuf.allocator(); //

  final List<StateChangeCallback> _stateChangeCallbackList =
      <StateChangeCallback>[];

  final List<TransMessageIncomingCallback> _transMsgIncomingCallback =
      <TransMessageIncomingCallback>[];

  //final List _todoList = []; //缓存要发送的消息

  late HeartBeat _heartBeat; //心跳包管理

  late Reconnect _reconnect; //断线重连

  late final StreamSubscription<ConnectivityResult> _streamSubscription;

  late SyncManager _syncManager;

  late FileUploadManager fileUploadManager;

  // 已收到的message id列表 用于重发逻辑下的去重操作
  final Set<int> receivedMsgIds = <int>{};

  IMClient() {
    DeviceManager.getDevice();

    _state = ClientState.unconnect;
    LogUtil.log("imclient instance create");

    _streamSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      LogUtil.log("网络环境变化$result");

      if (result == ConnectivityResult.none) {
        //网络不可用时
        onSocketClose();
      }
    });
    _heartBeat = HeartBeat(this);
    _reconnect = Reconnect(this);
    _syncManager = SyncManager(this);

    //_sessionManager = SessionManager();

    fileUploadManager = DefaultFileUploadManager();//默认文件上传类
  }

  static IMClient getInstance() {
    _instance ??= IMClient();
    return _instance!;
  }

  void debugStatus() {
    LogUtil.log("imclent state : $_state");
  }

  //im登录
  void imLogin(int uid, String token,
      {IMLoginCallback? loginCallback,
      String? host,
      int? port,
      bool manual = true}) {
    if (_state == ClientState.loging) {
      loginCallback?.call(Result.Error("正在登录中 请稍后再试"));
      return;
    }

    if (host != null) {
      _serverAddress = host;
    }

    if (port != null) {
      _port = port;
    }

    _uid = uid;
    _token = token;
    _loginCallback = loginCallback;
    _loginIsManual = manual;

    _socketConnect();
  }

  //im退出登录
  void imLoginOut({IMLogOutCallback? loginOutCallback}) async {
    _logoutCallback = loginOutCallback;

    if (_state == ClientState.logined) {
      //已经登录的 才能退出登录
      final LogoutReqMessage logoutReq = LogoutReqMessage(_token);
      sendData(logoutReq.encode());
      _changeState(ClientState.logouting);
    } else {
      if (_logoutCallback != null) {
        _logoutCallback!(Result.Error("Current state is not logined"));
      }
      return;
    }
  }

  //发送透传消息
  void sendTransMessage(TransMessage transMessage,
      {SendTransMessageCallback? callback}) {
    transMessage.from = _uid;
    if (Utils.isTextEmpty(transMessage.msgId)) {
      transMessage.msgId = Utils.genUniqueMsgId();
    }

    if (_state != ClientState.logined) {
      callback?.call(transMessage, Result.Error("error im client stauts"));
      return;
    }

    transMessage.updateTime = Utils.currentTime();

    if (callback != null) {
      _sendTransMessageCallbackMap[transMessage.msgId] = callback;
    }

    //发送
    sendData(SendTransMessageReqMsg(transMessage).encode());
  }

  //发送IM消息
  void sendIMMessage(IMMessage imMessage, {SendIMMessageCallback? callback}) async{
    imMessage.fromId = _uid;
    if (Utils.isTextEmpty(imMessage.msgId)) {
      imMessage.msgId = Utils.genUniqueMsgId();
    }

    if (_state != ClientState.logined) {
      callback?.call(imMessage, Result.Error("error im client stauts"));
      return;
    }

    var time = Utils.currentTime();
    imMessage.createTime = time;
    imMessage.updateTime = time;

    if (callback != null) {
      _sendIMMessageCallbackMap[imMessage.msgId] = callback;
    }

    LogUtil.log("imMessage.needUpload : ${imMessage.needUpload} , ${TextUtils.isEmpty(imMessage.url)}  , type: ${imMessage.imMsgType}");
    if(imMessage.needUpload){//有资源需要上传
      _uploadIMMessageAttachAndSend(imMessage , UploadFileType.image);
    }else{
      _doSendIMMessage(imMessage);
    }
  }

  // 上传资源并发送消息
  void _uploadIMMessageAttachAndSend(IMMessage imMessage , UploadFileType fileType , {SendIMMessageCallback? callback}){
    if(TextUtils.isEmpty(imMessage.localPath) || !File(imMessage.localPath!).existsSync()){
      callback?.call(imMessage, Result.Error("immessage file status error!"));
      return;
    }

    //上传文件
    imMessage.attachState = AttachState.UPLOADING;
    fileUploadManager.uploadFile(imMessage.localPath!, fileType, (result, url, attach){
      if(result == Codes.success && !TextUtils.isEmpty(url)){//上传成功
        imMessage.url = url;
        imMessage.attachState = AttachState.UPLOADED;
        _doSendIMMessage(imMessage);
      }else{//上传失败
        callback?.call(imMessage, Result.Error("immessage file upload error!"));
      }
    });
  }

  //讲IM消息编码 并发送  同时更新session会话列表  im消息本地持久化
  void _doSendIMMessage(IMMessage imMessage){
    //发送
    sendData(SendIMMessageReqMsg(imMessage).encode());
    //更新最近会话session
    _sessionManager.onSendIMMessage(imMessage);
  }

  //注册 或 解绑 状态改变事件监听
  bool registerStateObserver(StateChangeCallback callback, bool register) {
    if (register) {
      //注册
      if (!Utils.listContainObj(_stateChangeCallbackList, callback)) {
        _stateChangeCallbackList.add(callback);
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_stateChangeCallbackList, callback)) {
        _stateChangeCallbackList.remove(callback);
        return true;
      }
    }
    return false;
  }

  //注册最近会话变化监听
  bool registerRecentSessionObserver(RecentSessionChangeCallback callback, bool register) 
    => _sessionManager.registerRecentSessionObserver(callback, register);

  ///
  /// 注册未读消息数量改变监听
  ///
  bool registerUnreadCountObserver(UnreadCountChangeCallback callback ,bool register)
    => _sessionManager.registerUnreadChangeObserver(callback, register);

  //注册 或 解绑 透传消息事件监听
  bool registerTransMessageObserver(
      TransMessageIncomingCallback callback, bool register) {
    if (register) {
      //注册
      if (!Utils.listContainObj(_transMsgIncomingCallback, callback)) {
        _transMsgIncomingCallback.add(callback);
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_transMsgIncomingCallback, callback)) {
        _transMsgIncomingCallback.remove(callback);
        return true;
      }
    }
    return false;
  }

  //获取最近会话列表
  List<RecentSession> findRecentSessionList() {
    return _sessionManager.findRecentSessionList();
  }

  //查询指定会话历史消息
  Future<List<IMMessage>> queryIMMessageList(int sessionType, int uid ,
    {int flagTime = -1 , int limit = 30}) async {
    return _sessionManager.queryIMMessageByUid(sessionType, uid , flagTime , limit);
  }

  //注册接收IM消息
  bool registerIMMessageIncomingObserver(
      IMMessageIncomingCallback callback, bool register) {
    if (register) {
      //注册
      if (!Utils.listContainObj(_imMessageIncomingCallbackList, callback)) {
        _imMessageIncomingCallbackList.add(callback);
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_imMessageIncomingCallbackList, callback)) {
        _imMessageIncomingCallbackList.remove(callback);
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _heartBeat.dispose();
    _reconnect.dispose();

    _sessionManager.dispose();
    _streamSubscription.cancel();
  }

  //接收到新IM消息
  void receivedIMMessage(List<IMMessage> receivedMessageList) {
    for (IMMessage msg in receivedMessageList) {
      _sessionManager.onReceivedIMMessage(msg);
    } //end for each

    _fireIMMessageIncomingCallback(receivedMessageList);
  }

  //接收到透传消息
  void receivedTransMessage(TransMessage receivedTransMessage) {
    _fireTransMessageIncomingCallback(receivedTransMessage);
  }

  void _fireTransMessageIncomingCallback(final TransMessage tMsg) {
    for (TransMessageIncomingCallback cb in _transMsgIncomingCallback) {
      cb.call(tMsg);
    }
  }

  void _fireIMMessageIncomingCallback(List<IMMessage> receivedMessageList) {
    for (IMMessageIncomingCallback callback in _imMessageIncomingCallbackList) {
      callback.call(receivedMessageList);
    } //end for each
  }

  //状态切换
  void _changeState(ClientState newState) {
    if (_state != newState) {
      final ClientState oldState = _state;
      _state = newState;
      //LogUtil.log("state change : $_state");
      _fireStateChangeCallback(oldState, _state);
    }
  }

  //触发状态改变回调
  void _fireStateChangeCallback(ClientState oldState, ClientState newState) {
    // LogUtil.log(
    //     "_stateChangeCallbackList size ${_stateChangeCallbackList.length} ${_stateChangeCallbackList.hashCode.hashCode}");
    for (StateChangeCallback cb in _stateChangeCallbackList) {
      cb(oldState, newState);
    }
  }

  //连接服务器socket
  void _socketConnect() {
    LogUtil.log("call _socketConnect");
    _socket?.destroy();
    _heartBeat.stopHeartBeat(); //停止心跳 重新开始

    _changeState(ClientState.connecting);

    Future<Socket> socketFuture = Socket.connect(ServerAddress, Port,
        timeout: const Duration(seconds: 20));

    socketFuture.then((socket) {
      LogUtil.log(
          "连接成功! remote ${socket.remoteAddress.host} : ${socket.remotePort}");

      _socket = socket;

      //建立socket监听
      _socket?.listen((Uint8List data) {
        _receiveRemoteData(data);
      }, onError: (err) {
        LogUtil.log("socket read error : ${err.toString()}");
        onSocketClose();
      }, onDone: () {
        LogUtil.log("socket remote closed");
        onSocketClose();
      });

      _changeState(ClientState.unlogin);

      if (_socket != null) {
        _onSocketFirstContected();
      }
    }).catchError((error) {
      LogUtil.log("socket 连接失败 ${error.toString()}");
      LogUtil.errorLog("socket 连接失败 ${error.toString()}");
      onSocketClose();
      _changeState(ClientState.unconnect);
    }).onError((error, stackTrace) {
      LogUtil.log("occur error ${error.toString()}");
    }).whenComplete(() {
      //LogUtil.log("whenComplete");
    });
  }

  //socket首次连接成功
  void _onSocketFirstContected() {
    //todo 发送请求登录消息
    IMLoginReqMessage loginReqMsg = IMLoginReqMessage(_uid, _token);
    loginReqMsg.manual = _loginIsManual;

    _loginIsManual = false;
    sendData(loginReqMsg.encode());
    _changeState(ClientState.loging);
  }

  //socket被关闭 清理socket连接
  void onSocketClose() {
    LogUtil.log("call onSocketClose");
    _dataBuf.reset(); //buf清空

    _socket?.destroy();
    _changeState(ClientState.unconnect);
    _socket = null;

    _heartBeat.stopHeartBeat();
    _reconnect.tiggerReconnect();
  }

  //接收到远端数据
  void _receiveRemoteData(Uint8List data) {
    ByteBuf recvBuf = ByteBuf.allocator(size: data.length);
    recvBuf.writeUint8List(data);
    
    _heartBeat.recordTime();

    _dataBuf.writeByteBuf(recvBuf);
    _dataBuf.debugHexPrint();

    while (_dataBuf.hasReadContent) {
      final DataStatus checkResult = _checkDataStatus(
          _dataBuf.copyWithSize(Message.headerSize()),
          _dataBuf.couldReadableSize); //使用备份来做检测 节省资源 仅取前32个协议头字节
      LogUtil.log("checkResult $checkResult");

      if (checkResult == DataStatus.success) {
        final Message? msg = parseByteBufToMessage(_dataBuf);
        _dataBuf.compact();

        LogUtil.log("received data  len : ${data.length}");
        //execute hand
        _handleMsg(msg);
      } else if (checkResult == DataStatus.errorLength) {
        break;
      } else {
        _socket?.destroy();
        break;
      }
    } //end while
  }

  //将原始数据解码成message
  Message? parseByteBufToMessage(ByteBuf buf) {
    Message msgHead = Message.fromBytebuf(buf);
    Message? result;
    LogUtil.log("msgHead:${msgHead.type}");

    switch (msgHead.type) {
      case MessageTypes.LOGIN_RESP: //登录消息响应
        result = IMLoginRespMessage.from(msgHead, buf);
        break;
      case MessageTypes.LOGOUT_RESP: //退出登录 消息响应
        result = LogoutRespMessage.from(msgHead, buf);
        break;
      case MessageTypes.SEND_IMMESSAGE_RESP: //发送消息获取响应
        result = SendIMMessageRespMsg.from(msgHead, buf);
        break;
      case MessageTypes.PUSH_IMMESSAGE_REQ: //发送过来的IMMessage
        result = PushIMMessageReqMsg.from(msgHead, buf);
        break;
      case MessageTypes.PONG: //心跳响应
        result = PongMessage();
        break;
      case MessageTypes.KICK_OFF: //被踢掉
        result = KickoffMessage();
        break;
      case MessageTypes.SEND_TRANS_MESSAGE_RESP: //发送透传消息 请求响应
        result = SendTransMessageRespMsg.from(msgHead, buf);
        break;
      case MessageTypes.PUSH_TRANS_MESSAGE_REQ: //发送过来的透传消息
        result = PushTransMessageReqMsg.from(msgHead, buf);
        break;
      default:
        break;
    } //end switch
    return result;
  }

  //针对不同message 做不同业务处理
  void _handleMsg(Message? msg) {
    _receivedPacketCount++;

    //包重复检查
    if(receivedMsgIds.contains(msg?.uniqueId)){
      LogUtil.log("recevied has handled dupliate message ${msg?.uniqueId}");
      return;
    }
    receivedMsgIds.add(msg?.uniqueId??0);

    MessageHandler? handler;

    LogUtil.log("messageType:${msg?.type}");
    switch (msg?.type) {
      case MessageTypes.LOGIN_RESP:
        handler = IMLoginRespHandler();
        break;
      case MessageTypes.LOGOUT_RESP:
        handler = LogoutRespHandler();
        break;
      case MessageTypes.SEND_IMMESSAGE_RESP:
        handler = SendIMMessageHandler();
        break;
      case MessageTypes.PUSH_IMMESSAGE_REQ: //发送过来的IMMessage
        handler = PushIMMessageHandler();
        break;
      case MessageTypes.PONG: //心跳响应处理
        break;
      case MessageTypes.KICK_OFF: //被踢掉
        handler = KickOffHandler();
        break;
      case MessageTypes.SEND_TRANS_MESSAGE_RESP: //透传消息响应
        handler = SendTransMessageHandler();
        break;
      case MessageTypes.PUSH_TRANS_MESSAGE_REQ: //接收到新的透传消息
        handler = PushTransMessageHandler();
        break;
      default:
        break;
    } //end switch

    handler?.handle(this, msg);

    //LogUtil.log("packetCount : $_receivedPacketCount");
  }

  //检测数据状态
  DataStatus _checkDataStatus(ByteBuf buf, int bufRealSize) {
    if (buf.couldReadableSize < Message.headerSize()) {
      return DataStatus.errorLength;
    }

    int magicNumber = buf.readInt32();
    if (magicNumber != ProtocolConfig.MagicNumber) {
      return DataStatus.errorMagicNumber;
    }

    int version = buf.readInt32();
    if (version != ProtocolConfig.Version) {
      return DataStatus.errorVersion;
    }

    int length = buf.readInt64();
    int lastLength = length; //剩余长度
    if (bufRealSize < lastLength) {
      return DataStatus.errorLength;
    }

    buf.readInt32();
    int encodeType = buf.readInt32();
    if (encodeType != ProtocolConfig.BodyEncodeType) {
      return DataStatus.errorBodyEncode;
    }

    return DataStatus.success;
  }

  //登录成功
  void loginSuccess(bool manualLogin) async {
    LogUtil.log("login success 是否是手动登录: $manualLogin");
    _changeState(ClientState.logined);

    _reconnect.stopReconnect(); //停止重连尝试
    _heartBeat.startHeartBeat();
    _reconnect.CouldReconnect = true; //标识 未来可以自动重连

    //init session 登录成功后 构建
    if (manualLogin) {
      await _sessionManager.loadUid(_uid);
    }

    //同步离线消息
    sendSyncOfflineMessageRequest();
  }

  void sendSyncOfflineMessageRequest() {
    _syncManager.sendSyncOfflineMessageReq(uid);
  }

  //自动重连
  void autoReconnect() {
    imLogin(_uid, _token!, manual: false);
  }

  void loginFailed() {
    LogUtil.log("login failed");
    _changeState(ClientState.unlogin);
  }

  //退出登录
  void afterLogout(bool logoutSuccess) {
    if (logoutSuccess) {
      LogUtil.log("login out");
      _changeState(ClientState.unlogin); //状态改为未登录
      _socket?.destroy(); //主动关闭socket

      _reconnect.CouldReconnect = false; //手动退出登录  不再进行重连
      onSocketClose();
    } else {
      _changeState(ClientState.logined);
    }
  }

  //通过socket 发送数据
  void sendData(ByteBuf buf) {
    LogUtil.log("send data size = ${buf.couldReadableSize}");
    buf.debugHexPrint();

    if (buf.couldReadableSize <= 0) {
      return;
    }

    // buf.debugPrint();
    try {
      _socket?.add(buf.readAllUint8List());

      //flush不能加  否则多次循环调用的场景下 会引发socket异常 add后 交给网络栈发送即可
      // _socket?.flush().whenComplete((){
      //   LogUtil.log("套接字 flush 完成");
      // });
    } catch (e) {
      LogUtil.log("socket write error ${e.toString()}");
      onSocketClose();
    }
  }

  ///
  /// 清零会话的未读消息
  ///
  void clearUnreadCountBySession(int sessionType , int sessionId){
    _sessionManager.clearUnreadCountBySession(sessionType, sessionId);
  }

  ///
  /// 查询指定会话的未读数量
  ///
  int querySessionUnreadCount(int sessionType , int sessionId){
    return _sessionManager.querySessionUnreadCount(sessionType, sessionId);
  }

  Future<int> removeIMMessage(IMMessage msg ,{RemoveIMMessgaeCallback? cb}) async{
    if(TextUtils.isEmpty(msg.msgId)){
      cb?.call(msg , Result.Error("msg is null"));
      return Future.value(-1);
    }
    
    var result = await _sessionManager.removeIMMessage(msg);
    if(result > 0){ //删除成功
      cb?.call(msg , Result.Success());
    }else{
      cb?.call(msg , Result.Error("remove immessage error!"));
    }
    return result;
  }
  
} //end class
