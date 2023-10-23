import 'dart:developer';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/network/request_manager.dart';
import 'package:dearim/user/user_manager.dart';

class TCPManager {
  TCPManager._privateConstructor();

  static final TCPManager _instance = TCPManager._privateConstructor();

  factory TCPManager() {
    IMClient.getInstance().registerStateObserver((oldState, newState) {
      log("change state $oldState to $newState");
    }, true);
    return _instance;
  }

  // 注册状态变化回调
  void registerStateChangeback(StateChangeCallback callback) {
    IMClient.getInstance().registerStateObserver(callback, true);
  }

  // 删除注册
  void unregisterStateChangeback(StateChangeCallback callback) {
    IMClient.getInstance().registerStateObserver(callback, false);
  }

  // 注册消息回调
  void registerMessageCommingCallbck(IMMessageIncomingCallback callback) {
    IMClient.getInstance().registerIMMessageIncomingObserver(callback, true);
  }

  // 删除注册消息回调
  void unregistMessageCommingCallback(IMMessageIncomingCallback callback) {
    IMClient.getInstance().registerIMMessageIncomingObserver(callback, false);
  }

  // 连接tcp
  void connect(int uid, String token) {
    String host = UserManager.getInstance()!.user!.imServer;
    int port = UserManager.getInstance()!.user!.imPort;
    if (RequestManager().networkenv == NetworkEnvironment.online) {
      //TODO: wmy test
      host = "47.99.103.133";
    }

    IMClient.getInstance().imLogin(uid, token, host: host, port: port,
        loginCallback: (result) {
      if (result.result) {
        log("IM登录成功");
      } else {
        log("IM登录失败 原因: ${result.reason}");
      }
    });
  }

  // 取消连接tcp
  void disconnect() {
    IMClient.getInstance().imLoginOut(loginOutCallback: (r) {
      log("退出登录: ${r.result}");
    });
  }

  Future<IMMessage?> sendMessage(String content, int toUid) async {
    IMMessage? msg =
        IMMessageBuilder.createText(toUid, IMMessageSessionType.P2P, content);
    if (msg != null) {
      IMClient.getInstance().sendIMMessage(msg, callback: (imMessage, result) {
        log("send im message ${result.code}");
      });
    }
    return msg;
  }
}
