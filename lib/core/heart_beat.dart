import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import 'protocol/heart_beat_message.dart';
import 'utils.dart';

///
/// 长链接心跳
///
class HeartBeat{
  late IMClient _client;

  final Duration _deltaTime = const Duration(minutes: 2);//代表最大等待时间

  Timer? _timer;

  Timer? _checkExpireTimer;//超时检测timer
  
  int _lastIoTime = -1;//记录上一次io操作时间

  late final StreamSubscription<ConnectivityResult> _streamSubscription;

  HeartBeat(IMClient client){
    _client = client;
    _streamSubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if(result == ConnectivityResult.none){//网络不可用时 立刻发起心跳
        _sendPingPkg(_timer);
      }
    });
  }

  //开始心跳
  void startHeartBeat(){
    _timer?.cancel();
    _timer = null;

    //启动定时器
    _timer = Timer.periodic(_deltaTime, (timer) {
      final int curTime = Utils.currentTime();
      
      if(curTime - _lastIoTime > (_deltaTime.inMilliseconds >> 1)){//超过最大等待时间的一半 发送心跳包
         LogUtil.log("heart beat");
        _sendPingPkg(timer);
      }else{
        LogUtil.log("net is working skip this heart beat tick! delta : ${curTime - _lastIoTime}");
      }
    });
  }

  void _judgeSocketDead(){
    LogUtil.log("heart beat judge socket has die!");
    _client.onSocketClose();
  }

  //停止心跳
  void stopHeartBeat(){
    LogUtil.log("stop heart beat!");
    _timer?.cancel();
    _timer = null;

    _checkExpireTimer?.cancel();
    _checkExpireTimer = null;
  }

  //记录操作当前时间 在有网络交互时
  void recordTime(){
    _lastIoTime = Utils.currentTime();
  }

  void dispose(){
    _streamSubscription.cancel();
  }

  //发送客户端心跳包
  void _sendPingPkg(Timer? timer){
    LogUtil.log("心跳: heart beat ping...");
    final PingMessage pingMsg = PingMessage();
    _client.sendData(pingMsg.encode());
  }
}//end class



