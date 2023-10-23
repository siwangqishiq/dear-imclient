import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';

import 'protocol/sync_offline.dart';

///
/// 同步离线消息
///
class SyncManager{
  final IMClient _client;

  SyncManager(this._client);
  
  //发起同步请求
  void sendSyncOfflineMessageReq(int uid){
    LogUtil.log("$uid 发出同步离线消息请求");
    final SendIMMessageReqMsg syncReq = SendIMMessageReqMsg(uid);
    _client.sendData(syncReq.encode());
  }
}