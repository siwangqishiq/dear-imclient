import 'package:dearim/core/log.dart';

import '../imcore.dart';
import 'message.dart';
import 'protocol.dart';

///
/// 客户端被其他端抢登
///
class KickOffHandler extends MessageHandler<KickoffMessage>{
  @override
  void handle(IMClient client, KickoffMessage msg) {
    LogUtil.log("被其他端踢掉了");

    client.reconnect.CouldReconnect = false;//被踢掉的  不能重连了
    client.onSocketClose();

    //触发回调
    client.kickoffCallback?.call();
  }
}

class KickoffMessage extends Message{
  KickoffMessage(){
    type = MessageTypes.KICK_OFF;
  }

  @override
  int getType() {
    return MessageTypes.KICK_OFF;
  }
}