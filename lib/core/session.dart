import 'dart:collection';
import 'dart:ffi';
import 'dart:io';

import 'package:dearim/core/estore/estore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';

import 'estore/im_table.dart';
import 'utils.dart';
import 'package:sqlite3/open.dart';

///
///会话
///

//最近会话
class RecentSession {
  int sessionId = 0; //会话ID
  int sessionType = IMMessageSessionType.P2P; //会话类型

  int unreadCount = 0; //会话未读数量
  // List<IMMessage> imMsgList = <IMMessage>[]; //消息列表
  IMMessage? imMessage;//最新的一条IM消息
  String? custom; //用户自定义数据
  String? attach; //附件信息
  String? msgId;

  //最近IM消息消息
  IMMessage? get lastIMMessage => imMessage;

  //会话时间
  int get time => (lastIMMessage?.updateTime) ?? -1;

  //更新session未读数量
  void updateUnReadCount(IMMessage msg) {
    // if (msg.isReceived) {
    //   unreadCount += msg.readState;
    // }
  }
}

//未读消息记录
class UnreadSession {
  int sessionType = -1;
  int sessionId = -1;
  int unreadCount = 0;
  String? custom;

  UnreadSession();

  factory UnreadSession.build(int type , int id , int count){
    UnreadSession result = UnreadSession();
    result.sessionType = type;
    result.sessionId = id;
    result.unreadCount = count;
    return result;
  }

  String get key => genKey(sessionType , sessionId);

  static String genKey(int type , int id) => "$type/$id";
}

typedef RecentSessionChangeCallback = Function(List<RecentSession> sessionList);

//未读数量改变回调
typedef UnreadCountChangeCallback = Function(int oldUnreadCunt , int currentUnreadCount);

// 会话管理
class SessionManager {
  int _uid = -1;

  int get uid => _uid;

  final List<RecentSession> _recentSessionList = <RecentSession>[];

  final List<UnreadCountChangeCallback> _unreadCountChangeCallbackList = <UnreadCountChangeCallback>[];

  final Map<String, RecentSession> _recentSessionMap =
      <String, RecentSession>{};

  final List<RecentSessionChangeCallback> _changeCallbackList =
      <RecentSessionChangeCallback>[];

  //EasyStore? _store;

  IMDatabase? imDb;

  //im消息ID集
  Set<String> immessageIds = <String>{};

  //总未读数
  int totalUnreadCount = 0;

  final Map<String , UnreadSession> unreadSessionData = <String , UnreadSession>{};

  SessionManager(){
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
  }

  Future<int> loadUid(int id) async{
    //debug 模拟加载不出最近联系人场景
    // LogUtil.log("session loadData delay $id");
    // await Future.delayed(const Duration(seconds: 5));
    // LogUtil.log("session loadData delay fininsh $id");

    //uid
    _uid = id;

    loadData();
    return Future.value(0);
  }

  void loadData() async {
    // _store = EasyStore.open("${_uid}db");
    // await _store!.init();
    
    // List<dynamic> list = _store!.query(IMMessage());
    // LogUtil.log("用户$_uid 查询本地历史消息 ${list.length}条记录");

    immessageIds.clear();//清理原有IMMessage ID集合

    //open 打开数据库 
    await _openDatabase();

    List<String> msgIdList = await _queryAllIMMessageIds();
    LogUtil.log("消息总数:${msgIdList.length}");
    for(String id in msgIdList){
      immessageIds.add(id);
    }//end for each

    //查询未读
    await _queryAllUnreadData();

    //构造最近会话列表 
    _buildRecentSessionList();

    //
    _updateAndFireCbUnreadSessionData();
  }

  /// 构造最近会话列表 
  void _buildRecentSessionList() async{
    _recentSessionList.clear();
    _recentSessionMap.clear();

    var recentList = await _queryRecentSessionFromDb();
    // LogUtil.log("_queryRecentSessionFromDb list size ${recentList.length}");
    if(recentList.isEmpty){
      var msgList = await _queryAllIMMessages();
      _rebuildRecentSession(msgList);

      //批量保存
      imDb?.batchInsertRecentSession(_recentSessionList);
    }else{
      _recentSessionList.addAll(recentList);
      for(var recent in _recentSessionList){
        _recentSessionMap[_getRecentSessionKeyFromSession(recent)] = recent;
      }//end for each
    }
    _updateRecentSessionUnreadCount();

    //重新排序
    _sortRecentSessionList();

    //触发回调
    _fireRecentSessionChangeCallback();
  }

  void _updateRecentSessionUnreadCount(){
    for(RecentSession recent in _recentSessionList){
      recent.unreadCount = querySessionUnreadCount(recent.sessionType , recent.sessionId);
    }//end for each
  }

  Future<List<RecentSession>> _queryRecentSessionFromDb() async{
    var list = await imDb?.queryRecentSessionList()??[];
    List<String> msgIdList = <String>[];
    Map<String , RecentSession> recentMap = {};
    for(RecentSession recent in list){
      if(recent.msgId != null){
        msgIdList.add(recent.msgId!);
        recentMap[recent.msgId!] = recent;
      }
    }//end for each

    List<IMMessage>? imList = await imDb?.queryIMMessageByMsgIds(msgIdList)??[];
    for(IMMessage imMsg in imList){
      recentMap[imMsg.msgId]?.imMessage = imMsg;
    }

    LogUtil.log("_queryRecentSessionFromDb list size ${list.length}");
    return list;
  }


  //打开本地数据库
  Future<int> _openDatabase() async{
    //关闭之前打开的db
    if(imDb != null ){ //&& imDb?.uid != _uid
      await imDb?.close();
    }

    imDb = IMDatabase(_uid); 
    return Future.value(0);
  } 

  //查询所有的IM消息  
  //todo 需要优化
  Future<List<IMMessage>> _queryAllIMMessages() async{
    List<IMMessage> list = await imDb?.queryAllIMMessage()??[];   
    return list;
  }

  ///
  /// 查询所有消息ID 
  ///
  Future<List<String>> _queryAllIMMessageIds() async {
    List<String> list = await imDb?.queryAllIMMessageIds()??[];   
    return list;
  }

  //查询未读会话数量记录
  Future<int> _queryAllUnreadData() async{
    List<UnreadSession> list = await (imDb?.queryAllUnreadSessionRecords())??[];
    unreadSessionData.clear();
    for(var record in list){
      if(record.sessionType < 0 || record.sessionId < 0){
        continue;
      }
      unreadSessionData[record.key] = record;
    }    
    return Future.value(0);
  }

  ///
  /// 查询会话未读消息数量
  ///
  int querySessionUnreadCount(int sessionType , int sessionId){
    return (unreadSessionData[UnreadSession.genKey(sessionType, sessionId)]?.unreadCount)??0;
  }

  //windows上打开sqlite
  DynamicLibrary _openOnWindows(){
    final scriptDir = File(Platform.script.toFilePath()).parent;
    final libraryNextToScript = File('${scriptDir.path}\\sqlite3.dll');
    //print("libraryNextToScript : ${libraryNextToScript.path}");
    return DynamicLibrary.open(libraryNextToScript.path);
  }

  //获取最近消息列表
  List<RecentSession> findRecentSessionList() {
    return _recentSessionList;
  }

  RecentSession? findRecentSessionByIMMessageId(String msgId){
    for(var recent in _recentSessionList){
      if(recent.msgId == msgId){
        return recent;
      }
    }//end for each
    return null;
  }

  //查询用户IM消息列表
  Future<List<IMMessage>> queryIMMessageByUid(int sessionType, int sessionId 
    ,int flagTime , int limitSize) async {
    LogUtil.log("查询消息记录 sessionType : $sessionType , sessionId:$sessionId , flagTime: $flagTime limitSize: $limitSize");
    // var result = _recentSessionMap[key]?.imMsgList ?? [];
    List<IMMessage> result = await imDb?.queryIMMessageListFromTypeAndSession(sessionType,   sessionId, flagTime , limitSize)??[];
    LogUtil.log("查询消息记录 size : ${result.length}");
    return result;
  }

  ///
  /// 注册/解绑未读消息改变 观察者
  ///
  bool registerUnreadChangeObserver(UnreadCountChangeCallback callback , bool register){
    if (register) {
      //注册
      if (!Utils.listContainObj(_unreadCountChangeCallbackList, callback)) {
        _unreadCountChangeCallbackList.add(callback);
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_unreadCountChangeCallbackList, callback)) {
        _unreadCountChangeCallbackList.remove(callback);
        return true;
      }
    }
    return false;
  }

  //注册 或 解绑 状态改变事件监听
  bool registerRecentSessionObserver(
      RecentSessionChangeCallback callback, bool register) {
    if (register) {
      //注册
      if (!Utils.listContainObj(_changeCallbackList, callback)) {
        _changeCallbackList.add(callback);
        LogUtil.log("添加最近会话 Ok ${_changeCallbackList.length}");
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_changeCallbackList, callback)) {
        _changeCallbackList.remove(callback);
        LogUtil.log("解绑最近会话 Ok ${_changeCallbackList.length}");
        return true;
      }
    }
    return false;
  }

  //重构会话列表
  void _rebuildRecentSession(List<IMMessage> msgList) {
    _recentSessionList.clear();
    _recentSessionMap.clear();

    for (final IMMessage msg in msgList) {
      // LogUtil.log("rebuild recent session ${msg.content} ${msg.fromId} ${msg.toId} ${msg.isReceived}");
      _updateRecentSession(msg);
    } //end for each

    _sortRecentSessionList();
    //触发回调
    _fireRecentSessionChangeCallback();
  }

  void _fireRecentSessionChangeCallback() {
    for (RecentSessionChangeCallback callback in _changeCallbackList) {
      callback.call(findRecentSessionList());
    }
  }

  //增加未读消息数
  void _incrementUnreadRecord(IMMessage msg){
    final String key = UnreadSession.genKey(msg.sessionType, msg.sessionId);
    UnreadSession? unreadRecord = unreadSessionData[key];
    bool isCreate = false;
    if(unreadSessionData[key] == null){
      unreadRecord = UnreadSession.build(msg.sessionType, msg.sessionId, 0);
      unreadSessionData[unreadRecord.key] = unreadRecord;
      isCreate = true;
    }

    unreadRecord?.unreadCount++;

    //持久化保存
    if(isCreate){
      imDb?.insertUnreadCountSession(unreadRecord!);
    }else{
      imDb?.updateUnreadCountSession(unreadRecord!);
    }
  }

  

  ///
  /// 根据会话类型 清理未读消息
  ///
  void clearUnreadCountBySession(int sessionType , int sessionId){
    final String key = UnreadSession.genKey(sessionType, sessionId);
    UnreadSession? unreadRecord = unreadSessionData[key];

    if(unreadRecord == null){
      return;
    }

    //此会话下的未读消息 清空为0
    unreadRecord.unreadCount = 0;
    _updateAndFireCbUnreadSessionData();

    //更新最近会话列表
    final String sessionKey = "${sessionType}_$sessionId";
    //LogUtil.log("根据会话类型 清理未读消息 $sessionKey");
    _recentSessionMap[sessionKey]?.unreadCount = querySessionUnreadCount(unreadRecord.sessionType, unreadRecord.sessionId);
    //LogUtil.log("根据会话类型 清理未读消息222 ${_recentSessionMap[sessionKey]?.unreadCount}");

    //callback
    // _fireRecentChangeCallback();

    //持久化保存
    imDb?.updateUnreadCountSession(unreadRecord);
  }

  //接收新的IM消息
  void onReceivedIMMessage(final IMMessage msg){
    if(immessageIds.contains(msg.msgId)){//已接收过此条消息 重复消息 丢弃
      return;
    }
    immessageIds.add(msg.msgId);

    //更新未读数据
    _incrementUnreadRecord(msg);

    _updateRecentSession(msg, recentSort: true, fireCallback: true , saveRecentSession: true);

    //保存消息到本地
    // _store?.save(msg);
    imDb?.saveIMMessage(msg);
    
    _updateAndFireCbUnreadSessionData();
  }

  ///
  /// 更新未读数量 触发回调
  ///
  void _updateAndFireCbUnreadSessionData(){
    //统计未读总数量
    int total = 0;
    for(var key in unreadSessionData.keys){
      UnreadSession unreadRecord = unreadSessionData[key]!;
      total += unreadRecord.unreadCount;
    }//end for each

    LogUtil.log("未读数修改: old = $totalUnreadCount new = $total");
    int oldUnreadCount = totalUnreadCount;
    totalUnreadCount = total;
    if(totalUnreadCount != oldUnreadCount){
      for(var cb in _unreadCountChangeCallbackList){
        cb.call(oldUnreadCount , totalUnreadCount);
      }//end for each
    }
  }

  //发送新IM消息
  void onSendIMMessage(final IMMessage msg , {bool saveLocal = true}){
    _updateRecentSession(msg,
      recentSort: true, 
      fireCallback: true,
      saveRecentSession: true);

    //保存消息到本地
    if(saveLocal){
      // _store?.save(msg);
      imDb?.saveIMMessage(msg);
    }
  }

  ///
  /// 通过消息 更新最近联系人会话
  ///
  RecentSession _updateRecentSession(
      final IMMessage msg,
      {bool recentSort = false, 
      bool fireCallback = false , 
      bool saveRecentSession = false,
      bool ignoreUpdateRecentTime = false}) {
    final String key = _getRecentSessionKey(msg);

    final RecentSession recent;
    bool update = false;
    if (_recentSessionMap.containsKey(key)) {
      //已经包含
      recent = _recentSessionMap[key]!;
      if(ignoreUpdateRecentTime){
        recent.imMessage = msg;
        recent.msgId = msg.msgId;
      }else{
        addIMMessageByUpdateTime(recent, msg);
      }

      update = true;
    } else {
      recent = RecentSession();
      recent.sessionId = msg.sessionId;
      recent.sessionType = msg.sessionType;
      recent.imMessage = msg;
      recent.msgId = msg.msgId;

      _recentSessionMap[key] = recent;
      _recentSessionList.add(recent);

      update = false;
    }
    

    //更新未读数量
    recent.unreadCount = querySessionUnreadCount(recent.sessionType, recent.sessionId);

    if (recentSort) {
      //重新排序
      _sortRecentSessionList();
    }

    if (fireCallback) { //触发回调
      _fireRecentSessionChangeCallback();
    }

    if(saveRecentSession){ // save to db
      _saveRecentSession(recent , update);
    }
    return recent;
  }

  ///
  /// 更新最近联系人数据
  ///
  void _saveRecentSession(RecentSession recent , bool update) async {
    if(update){
      imDb?.updateRecentSession(recent);
    }else{
      imDb?.insertRecentSession(recent);
    }
  }

  //删除消息 session更新
  // void onRemoveIMMessage(final IMMessage msg) {
  //   final String key = _getRecentSessionKey(msg);
  //   if (_recentSessionMap.containsKey(key)) {
  //     final RecentSession recent = _recentSessionMap[key]!;
  //     recent.imMsgList.remove(msg);

  //     _sortRecentSessionList();
  //     _fireRecentChangeCallback();
  //   }
  // }

  //重新排序会话列表
  void _sortRecentSessionList() {
    _recentSessionList.sort((left, right) {
      return right.time - left.time;
    });
  }

  static void addIMMessageByUpdateTime(RecentSession session, IMMessage msg) {
    // for(int i = list.length - 1 ; i>= 0 ;i++){
    //   if(msg.updateTime > list[i].updateTime){
    //     list.insert(i + 1, msg);
    //     return;
    //   }
    // }//end for i
    // list.insert(0, msg);
    // list.add(msg);
    // list.sort((left, right) {
    //   return left.updateTime - right.updateTime;
    // });

    if(session.imMessage == null){
      session.imMessage = msg;
      session.msgId = msg.msgId;
    }else if(session.imMessage!.updateTime <= msg.updateTime){
      session.imMessage = msg;
      session.msgId = msg.msgId;
    }
  }

  //快速检索数据
  String _getRecentSessionKey(IMMessage message) {
    return "${message.sessionType}_${message.sessionId}";
  }

  //Key值生成
  String _getRecentSessionKeyFromSession(RecentSession recent) {
    return "${recent.sessionType}_${recent.sessionId}";
  }

  //关闭
  void dispose() {
    _recentSessionList.clear();
  }

  //删除IM消息
  Future<int> removeIMMessage(IMMessage msg) async {
    var imDbResult = await imDb?.removeIMMessage(msg.msgId)??0;
    LogUtil.log("删除IM消息 ${msg.msgId} updatetime : ${msg.updateTime} createTime:${msg.createTime} result = $imDbResult");
    if(imDbResult <= 0){
      return Future.value(-1);
    }

    var relationRecentSession = findRecentSessionByIMMessageId(msg.msgId);
    if(relationRecentSession == null){
      LogUtil.log("relationRecentSession is null");
      return Future.value(1);
    }

    var imList =await imDb?.queryIMMessageListFromTypeAndSession(
      msg.sessionType, 
      msg.sessionId, 
      msg.createTime, 
      2
    );
    LogUtil.log("imList size : ${imList?.length??0}");
    if(imList != null && imList.isNotEmpty){
      var previousMsg = imList.first;
      _updateRecentSession(
        previousMsg,
        recentSort: true,
        fireCallback:true,
        saveRecentSession:true,
        ignoreUpdateRecentTime: true
      );
    }else{
      relationRecentSession.msgId = null;
      relationRecentSession.imMessage = null;
      _sortRecentSessionList();//重新排序
      _fireRecentSessionChangeCallback();
    }
    // _updateRecentSession(msg);
    return Future.value(1);
  }
}
