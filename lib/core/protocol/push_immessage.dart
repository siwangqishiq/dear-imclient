import 'dart:convert';
import 'dart:typed_data';

import '../byte_buffer.dart';
import '../imcore.dart';
import '../immessage.dart';
import '../log.dart';
import '../utils.dart';
import 'message.dart';
import 'protocol.dart';

///
///
///
class PushIMMessageReqMsg extends Message {
  IMMessage? imMessage;

  factory PushIMMessageReqMsg.from(Message head, ByteBuf buf) {
    PushIMMessageReqMsg imMessageReqMsg = PushIMMessageReqMsg();
    imMessageReqMsg.fill(head);
    imMessageReqMsg.decodeBody(buf, imMessageReqMsg.bodyLength);
    return imMessageReqMsg;
  }

  PushIMMessageReqMsg();

  @override
  dynamic decodeBody(ByteBuf buf, int bodySize) {
    Uint8List rawData = buf.readUint8List(bodySize);
    
    String originJsonStr = Utils.convertUint8ListToString(rawData);
    LogUtil.log(originJsonStr);

    try{
      var jsonMap = jsonDecode(originJsonStr);
      imMessage = IMMessage.fromMap(jsonMap);
    }catch(e){
      LogUtil.errorLog(e.toString());
    }
    return imMessage;
  }

  @override
  int getType() {
    return MessageTypes.PUSH_IMMESSAGE_REQ;
  }
} //end class

//接到推送消息后 反馈已接收
class PushIMMessageResp extends Message{
  String? msgId;//ack msgid

  PushIMMessageResp(this.msgId);

  @override
  ByteBuf encodeBody() {
    Map<String , dynamic> body = {"msgId" : msgId};

    String jsonBody = jsonEncode(body);
    LogUtil.log("jsonBody:$jsonBody");

    Uint8List bodyData = Utils.convertStringToUint8List(jsonBody);
    ByteBuf bodyBuf = ByteBuf.allocator(size: bodyData.length);
    bodyBuf.writeUint8List(bodyData);
    return bodyBuf;
  }

  @override
  int getType() {
    return MessageTypes.PUSH_IMMESSAGE_RESP;
  }
}

///
/// PushIMMessageHandler处理
///
class PushIMMessageHandler extends MessageHandler<PushIMMessageReqMsg> {
  @override
  void handle(IMClient client, PushIMMessageReqMsg msg) {
    LogUtil.log("send immessage resp unique(${msg.uniqueId}) ");

    if(msg.imMessage == null){
      return;
    }

    IMMessage imMessage = msg.imMessage!;
    LogUtil.log("received msg ${imMessage.content}");
    
    List<IMMessage> incomingIMList = <IMMessage>[];
    imMessage.isReceived = true;//是接收到的消息

    incomingIMList.add(imMessage);
    client.receivedIMMessage(incomingIMList);

    //send received push msg ack

    // for test
    // 取消此响应会触发消息重发 for test
    client.sendData(PushIMMessageResp(msg.uniqueId.toString()).encode());
  }
}//end class



