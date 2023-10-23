
// ignore_for_file: constant_identifier_names

import 'package:dearim/core/log.dart';
import 'package:dearim/core/utils.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/trans.dart';
import 'imcore.dart';
import 'protocol/trans.dart';

class AVChatManager{
  static AVChatManager? instance;

  static AVChatManager getInstance(){
    instance ??= AVChatManager();
    return instance!;
  }

  static const String KEY_SESSION_ID = "sessionId";
  static const String KEY_OFFER = "offer";
  static const String KEY_ANSWER = "answer";
  static const String KEY_SDP = "sdp";
  static const String KEY_TYPE = "type";
  static const String KEY_ICECANDIDATE = "icecandidate";
  static const String KEY_UID = "uid";

  bool _isChatting = false;
  String? _sessionId;
  int? _remoteUid;

  RTCPeerConnection? _peerConnection; 

  bool isChatting() => _isChatting;

  RTCPeerConnection? getPeerConnection(){
    return _peerConnection;
  }

  //发起音视频会话
  bool startChat(int remoteUid){
    if(isChatting()){
      LogUtil.log("is av chatting close");
      return false;
    }

    _remoteUid = remoteUid;
    _sessionId = Utils.genUnique();
    LogUtil.log("start chat session : $_sessionId $_remoteUid $hashCode");
    _isChatting = true;
    
    _sendInviteMessage(remoteUid);
    return true;
  }

  //接受邀请
  bool acceptInvite(){
    if(!isChatting()){
      return false;
    }
    if(_sessionId == null || _remoteUid == null){
      return false;
    }

    _sendAcceptInvite();
    return true;
  }

  void _sendAcceptInvite(){
    Map<String,dynamic> content = {};
    content[KEY_SESSION_ID] = _sessionId;

    LogUtil.log("sendAcceptInvite _remoteUid = $_remoteUid");
    if(_remoteUid != null){
      _doSendControlMessage(_remoteUid! , CustomTransTypes.TYPE_AVCHAT_ACCEPT , content);
    }
  }

  Future<RTCPeerConnection> buildPeerConnection() async{
    if(_peerConnection != null){
      return Future.value(_peerConnection);
    }

    var configuration = <String , dynamic>{};
    const iceServer = {
      "urls" : "turn:101.34.23.152:3478",
      "username": "panyi",
      "credential": "123456"
    };
    configuration['iceServers'] = [iceServer];
    // configuration['iceTransportPolicy'] = "relay";
    _peerConnection = await createPeerConnection(configuration);
    return Future.value(_peerConnection);
  }

  /// 取消邀请
  bool finishAVChat({bool needSendMessage = false}){
    if(!isChatting()){
      LogUtil.log("is av chatting close");
      return false;
    }

    if(needSendMessage){
      _sendHangup();
    }
    close();
    return true;
  }

  ///
  /// 发送IceCandiate
  ///
  void sendIceCandidate(RTCIceCandidate candidate){
    Map<String,dynamic> content = {};
    content[KEY_SESSION_ID] = _sessionId;
    content[KEY_ICECANDIDATE] = candidate.toMap();

    if(_remoteUid != null){
      _doSendControlMessage(_remoteUid! , CustomTransTypes.TYPE_AVCHAT_ICE_CANDIDATE , content);
    }
  }

  ///
  /// 发送answer
  ///
  void sendAnswer(RTCSessionDescription answer){
    Map<String,dynamic> content = {};
    content[KEY_SESSION_ID] = _sessionId;
    content[KEY_SDP] = answer.sdp;
    content[KEY_TYPE] = answer.type;

    if(_remoteUid != null){
      _doSendControlMessage(_remoteUid! , CustomTransTypes.TYPE_AVCHAT_ANSWER , content);
    }
  }

  ///
  /// 发送offer
  ///
  void sendOffer(RTCSessionDescription offer){
    Map<String,dynamic> content = {};
    content[KEY_SESSION_ID] = _sessionId;
    content[KEY_SDP] = offer.sdp;
    content[KEY_TYPE] = offer.type;

    if(_remoteUid != null){
      _doSendControlMessage(_remoteUid! , CustomTransTypes.TYPE_AVCHAT_OFFER , content);
    }
  }

  void _sendHangup(){
    Map<String,dynamic> content = {};
    content[KEY_SESSION_ID] = _sessionId;

    LogUtil.log("_remoteUid = $_remoteUid  $hashCode");
    if(_remoteUid != null){
      _doSendControlMessage(_remoteUid! , CustomTransTypes.TYPE_AVCHAT_HANGUP , content);
    }
  }

  void _sendInviteMessage(int remoteUid){
    LogUtil.log("avchat to $remoteUid");

    Map<String,dynamic> content = {};
    int uid = IMClient.getInstance().uid;
    content[KEY_SESSION_ID] = _sessionId;
    content[KEY_UID] = uid;
    
    _doSendControlMessage(remoteUid , CustomTransTypes.TYPE_AVCHAT_INVITE , content);
  }

  void _doSendControlMessage(int toUid ,int type, dynamic content){
    var inviteData = CustomTransBuilder.build(type, content);
    var inviteTransMessage =
        TransMessageBuilder.create(toUid, inviteData, null);
    IMClient.getInstance().sendTransMessage(inviteTransMessage!);
  }

  bool onReceivedHangupMessage(Map<String , dynamic> jsonData){
    if(!isChatting()){
      LogUtil.log("no chatting quit");
      return false;
    }

    String sessionId = jsonData[KEY_SESSION_ID];
    LogUtil.log("message sessionId: $sessionId ");
    if(sessionId != _sessionId){
      LogUtil.log("message sessionId: $sessionId not equal local $_sessionId");
      return false;
    }

    close();
    return true;
  }

  bool checkMessageInSession(Map<String , dynamic> jsonData){
    if(!isChatting()){
      LogUtil.log("checkMessageInSession no chatting quit");
      return false;
    }

    String sessionId = jsonData[KEY_SESSION_ID];
    LogUtil.log("message sessionId: $sessionId ");
    if(sessionId != _sessionId){
      LogUtil.log("message sessionId: $sessionId not equal local $_sessionId");
      return false;
    }
    return true;
  }

  bool onReceivedAcceptInviteMessage(Map<String , dynamic> jsonData){
    if(!isChatting()){
      LogUtil.log("no chatting quit");
      return false;
    }

    String sessionId = jsonData[KEY_SESSION_ID];
    LogUtil.log("message sessionId: $sessionId ");
    if(sessionId != _sessionId){
      LogUtil.log("message sessionId: $sessionId not equal local $_sessionId");
      return false;
    }
    return true;
  }

  bool onReceivedInviteMessage(Map<String , dynamic> jsonData){
    if(isChatting()){
      LogUtil.log("is av chatting ignore");
      return false;
    }

    _isChatting = true;
    _remoteUid = jsonData[KEY_UID];
    _sessionId = jsonData[KEY_SESSION_ID];

    LogUtil.log("received AV Chat invite: $_sessionId , $_remoteUid");

    return true;
  }

  //关闭会话
  void close(){
    LogUtil.log("AV Chat close sessionid : $_sessionId");
    _sessionId = null;
    _remoteUid = null; 
    _isChatting = false;

    _peerConnection?.close().then((value) => _peerConnection = null);
  }
}

