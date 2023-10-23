// ignore_for_file: non_constant_identifier_names

import 'package:uuid/uuid.dart';

import '../byte_buffer.dart';
import 'protocol.dart';

class Message {
  static Uuid uuid = const Uuid();

  int magicNumber = ProtocolConfig.MagicNumber;
  int version = ProtocolConfig.Version;
  int length = 0;
  int type = MessageTypes.UNDEF;
  int bodyEncode = BodyEncodeTypes.JSON;
  int uniqueId = 0;
  
  int bodyLength = 0;

  //build from bytebuf
  factory Message.fromBytebuf(ByteBuf buf) {
    final Message msg = Message();
    msg.magicNumber = buf.readInt32();
    msg.version = buf.readInt32();
    msg.length = buf.readInt64();
    msg.type = buf.readInt32();
    msg.bodyEncode = buf.readInt32();
    msg.uniqueId = buf.readInt64();
    
    msg.bodyLength = msg.length - headerSize();
    return msg;
  }

  Message() {
    uniqueId = genUniqueId();
  }

  static int genUniqueId() {
    return uuid.v1().hashCode;
  }

  //消息类型 子类继承
  int getType() {
    return type;
  }

  void fill(Message otherMsg) {
    magicNumber = otherMsg.magicNumber;
    version = otherMsg.version;
    length = otherMsg.length;
    type = otherMsg.type;
    bodyEncode = otherMsg.bodyEncode;
    uniqueId = otherMsg.uniqueId;

    bodyLength = otherMsg.bodyLength;
  }

  //默认实现 由子类继承
  ByteBuf encodeBody() {
    return ByteBuf.allocator();
  }

  //解码消息体 子类实现
  dynamic decodeBody(ByteBuf buf, int bodySize) {
    return null;
  }

  static int headerSize() {
    return 4 + 4 + 8 + 4 + 4 + 8;
  }

  //编码消息体为ByteBuf
  ByteBuf encode() {
    ByteBuf bodyBuf = encodeBody();
    length = headerSize() + bodyBuf.couldReadableSize;

    ByteBuf buf = ByteBuf.allocator(size: 1024);
    buf.writeInt32(magicNumber);
    buf.writeInt32(version);
    buf.writeInt64(length);
    buf.writeInt32(getType());
    buf.writeInt32(bodyEncode);
    buf.writeInt64(uniqueId);
    
    if (bodyBuf.hasReadContent) {
      buf.writeByteBuf(bodyBuf);
    }

    //buf.debugPrint();
    return buf;
  }
} //end class

class Result {
  factory Result.Error(String _msg){
    final Result result = Result();
    result.result = false;
    result.reason = _msg;
    result.code = Codes.error;
    return result;
  }

  factory Result.Success(){
    final Result error = Result();
    error.result = true;
    error.code = Codes.success;
    return error;
  }

  factory Result.update(){
    final Result result = Result();
    result.result = true;
    result.code = Codes.update;
    return result;
  }

  Result(){
    code = 0;
    result = false;
    reason = null;
  }

  int code = 0;
  bool result = false;
  String? reason;

  int extra = 0;

  //是否成功
  bool isSuccess() => code == Codes.success;
}//end class
