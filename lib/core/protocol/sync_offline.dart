import 'dart:convert';
import 'dart:typed_data';

import '../byte_buffer.dart';
import '../log.dart';
import '../utils.dart';
import 'message.dart';
import 'protocol.dart';

///
/// 同步离线消息 发出同步请求  等待服务端推送同步消息
///
class SendIMMessageReqMsg extends Message {
  int uid;
  
  SendIMMessageReqMsg(this.uid);

  @override
  ByteBuf encodeBody() {
    Map<String , dynamic> body = {};
    body["uid"] = uid;

    String jsonBody = jsonEncode(body);
    LogUtil.log("SendIMMessageReqMsg jsonBody:$jsonBody");

    Uint8List bodyData = Utils.convertStringToUint8List(jsonBody);
    ByteBuf bodyBuf = ByteBuf.allocator(size: bodyData.length);
    bodyBuf.writeUint8List(bodyData);
    return bodyBuf;
  }

  @override
  int getType() {
    return MessageTypes.SYNC_MESSAGE_REQ;
  }
} //end class