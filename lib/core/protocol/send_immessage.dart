import 'dart:convert';
import 'dart:typed_data';

import 'package:dearim/core/immessage.dart';

import '../byte_buffer.dart';
import '../imcore.dart';
import '../log.dart';
import '../utils.dart';
import 'message.dart';
import 'protocol.dart';

///
///
//发送IM消息
///
class SendIMMessageReqMsg extends Message {
  IMMessage? imMessage;

  SendIMMessageReqMsg(this.imMessage);

  @override
  ByteBuf encodeBody() {
    Map<String , dynamic> body = imMessage?.encodeMap()??{};

    String jsonBody = jsonEncode(body);
    LogUtil.log("jsonBody:$jsonBody");

    Uint8List bodyData = Utils.convertStringToUint8List(jsonBody);

    ByteBuf bodyBuf = ByteBuf.allocator(size: bodyData.length);
    bodyBuf.writeUint8List(bodyData);
    return bodyBuf;
  }

  @override
  int getType() {
    return MessageTypes.SEND_IMMESSAGE_REQ;
  }
} //end class


///
///发送消息返回
///
class SendIMMessageRespMsg extends Message{

  SendIMMessageRespMsg();

  factory SendIMMessageRespMsg.from(Message head, ByteBuf buf) {
    SendIMMessageRespMsg respMessage = SendIMMessageRespMsg();
    respMessage.fill(head);
    respMessage.decodeBody(buf, respMessage.bodyLength);
    return respMessage;
  }

  IMMessageResult? result;

  @override
  dynamic decodeBody(ByteBuf buf, int bodySize) {
    Uint8List rawData = buf.readUint8List(bodySize);
    
    String originJsonStr = Utils.convertUint8ListToString(rawData);
    LogUtil.log(originJsonStr);

    try{
      var jsonMap = jsonDecode(Utils.convertUint8ListToString(rawData));
      
      result = IMMessageResult();
      result?.code = jsonMap["code"]??0;
      result?.result = jsonMap["result"];
      result?.reason = jsonMap["reason"];

      result?.createTime = jsonMap["createTime"];
      result?.updateTime = jsonMap["updateTime"];
      result?.msgId = jsonMap["msgId"];
    }catch(e){
      LogUtil.errorLog(e.toString());
    }
    return result;
  }

  @override
  int getType() {
    return MessageTypes.SEND_IMMESSAGE_RESP;
  }
}

class SendIMMessageHandler extends MessageHandler<SendIMMessageRespMsg> {
  @override
  void handle(IMClient client, SendIMMessageRespMsg msg) {
    LogUtil.log("send immessage resp unique(${msg.uniqueId}) ");
    
    //callback
    if(msg.result != null){
      IMMessageResult result = msg.result!;

      LogUtil.log("send immessage resp msgId (${result.msgId}) ");

      final IMMessage retIMMessage = IMMessage();
      retIMMessage.createTime = result.createTime;
      retIMMessage.updateTime = result.updateTime;
      retIMMessage.msgId = result.msgId??"";

      client.sendIMMessageCallbackMap[result.msgId]?.call(retIMMessage , result);

      //remove callback
      client.sendIMMessageCallbackMap.remove(result.msgId);
    }
  }
}//end IMLoginRespHandler class


