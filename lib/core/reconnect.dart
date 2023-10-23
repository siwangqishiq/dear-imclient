// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';

///
///client断线重连机制
///

class Reconnect{
  static const int MAX_DELAY_SECONDS_TIME = 120;

  late final IMClient _client;

  bool _isReconnecting = false;

  bool _couldReconnect = false;

  set CouldReconnect(bool s) => _couldReconnect = s;

  int _delaySeconds = 1;//延迟时间(秒)

  Timer? _task;

  late final StreamSubscription<ConnectivityResult> _streamSubscription;
  
  Reconnect(IMClient client){
    _client = client;
    _streamSubscription = Connectivity().onConnectivityChanged.listen(_onConnectiveChangedCallback);
  }

  void _onConnectiveChangedCallback(ConnectivityResult event){
    //LogUtil.log("连接状态改变 : $event");
    if(event == ConnectivityResult.wifi 
        || event == ConnectivityResult.mobile 
        || event == ConnectivityResult.ethernet){//新连接建立 立刻启动重连
      instantReconnect();
    }
  }

  void tiggerReconnect(){
    LogUtil.log("_isReconnecting = $_isReconnecting");
    if(_isReconnecting){//防止重复调用
      return;
    }
    _isReconnecting = true;

    doReconnect();
  }

  void stopReconnect(){
    _isReconnecting = false;
    _delaySeconds = 1;
    _task?.cancel();
    _task = null;
  }

  //立即启动重连
  void instantReconnect(){
    stopReconnect();
    doReconnect();
  }

  //
  void doReconnect(){
    if(!_couldReconnect){
      return;
    }

    LogUtil.log("do reconnect.");

    if(_client.state != ClientState.unconnect){
      return;
    }

    int curDelay = _delaySeconds;
    LogUtil.log("开始重连... delay : $_delaySeconds");
    _client.autoReconnect();
    
    nextDelaySeconds();
    _task = Timer(Duration(seconds: curDelay) , (){
      doReconnect();
    });
  }

  void dispose(){
    _streamSubscription.cancel();
  }

  //计算下一次重连delay时间
  void nextDelaySeconds(){
    _delaySeconds = _delaySeconds << 1;
    if(_delaySeconds > MAX_DELAY_SECONDS_TIME){
      _delaySeconds = MAX_DELAY_SECONDS_TIME;
    }
  }
}//end class