import 'message.dart';
import 'protocol.dart';

class PingMessage extends Message{
  @override
  int getType() {
    return MessageTypes.PING;
  }
}

class PongMessage extends Message{
  PongMessage(){
    type = MessageTypes.PONG;
  }

  @override
  int getType() {
    return MessageTypes.PONG;
  }
}
