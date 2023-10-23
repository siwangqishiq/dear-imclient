import 'dart:convert';
import 'dart:typed_data';

import 'package:dearim/core/imcore.dart';

import '../byte_buffer.dart';
import '../log.dart';
import '../utils.dart';
import 'message.dart';
import 'protocol.dart';

///
/// 透传消息
///

//数据model
class TransMessage {
  int from = 0; // 发出者
  int to = 0; //接收者
  int sendType = 0; //发出端类型
  int updateTime = 0; //更新时间
  bool offline = false; //是否支持
  String msgId = ""; //消息ID
  String? content; //透传内容
  String? attach; //附加信息

  TransMessage();

  //encode编码为Map
  Map<String, dynamic> encodeMap() {
    final Map<String, dynamic> body = <String, dynamic>{};

    body["from"] = from;
    body["to"] = to;
    body["sendType"] = sendType;
    body["updateTime"] = updateTime;
    body["offline"] = offline;
    body["msgId"] = msgId;
    body["content"] = content;
    body["attach"] = attach;

    return body;
  }

  factory TransMessage.fromMap(Map<String, dynamic> map) {
    final TransMessage msg = TransMessage();
    msg.msgId = map["msgId"];
    msg.from = map["from"] ?? 0;
    msg.to = map["to"] ?? 0;
    msg.updateTime = map["updateTime"] ?? 0;
    msg.sendType = map["sendType"] ?? 0;
    msg.offline = map["offline"] ?? false;
    msg.content = map["content"];
    msg.attach = map["attch"];
    return msg;
  }
}

//构造消息体
class TransMessageBuilder {
  static const int MAX_LENGHT = 4 * 1024 * 1024; //4M

  //创建透传消息
  static TransMessage? create(int toUid, String content, String? attach,
      {bool offline = false}) {
    if (toUid <= 0) {
      LogUtil.errorLog("error uid for $toUid");
      return null;
    }

    if (content.length >= MAX_LENGHT ||
        (attach != null && attach.length >= MAX_LENGHT)) {
      LogUtil.errorLog("content or attach too long for trans message");
      return null;
    }

    final TransMessage transMessage = TransMessage();
    transMessage.msgId = Utils.genUniqueMsgId();
    transMessage.from = IMClient.getInstance().uid;
    transMessage.to = toUid;
    transMessage.offline = offline;
    transMessage.sendType = Utils.getClientType();
    transMessage.updateTime = Utils.currentTime();
    transMessage.content = content;
    transMessage.attach = attach;
    return transMessage;
  }
} //end class

///
///
//发送透传消息
///
class SendTransMessageReqMsg extends Message {
  late TransMessage transMessage;

  SendTransMessageReqMsg(this.transMessage);

  @override
  ByteBuf encodeBody() {
    Map<String, dynamic> body = transMessage.encodeMap();

    String jsonBody = jsonEncode(body);
    LogUtil.log("发送透传消息请求 jsonBody:$jsonBody");

    Uint8List bodyData = Utils.convertStringToUint8List(jsonBody);

    ByteBuf bodyBuf = ByteBuf.allocator(size: bodyData.length);
    bodyBuf.writeUint8List(bodyData);
    return bodyBuf;
  }

  @override
  int getType() {
    return MessageTypes.SEND_TRANS_MESSAGE_REQ;
  }
} //end class

//IM消息返回结果
class TransMessageResult extends Result {
  int updateTime = 0;
  String? msgId;
}

///
///发送消息返回
///
class SendTransMessageRespMsg extends Message {
  SendTransMessageRespMsg();

  factory SendTransMessageRespMsg.from(Message head, ByteBuf buf) {
    SendTransMessageRespMsg respMessage = SendTransMessageRespMsg();
    respMessage.fill(head);
    respMessage.decodeBody(buf, respMessage.bodyLength);
    return respMessage;
  }

  TransMessageResult? result;

  @override
  dynamic decodeBody(ByteBuf buf, int bodySize) {
    Uint8List rawData = buf.readUint8List(bodySize);

    String originJsonStr = Utils.convertUint8ListToString(rawData);
    LogUtil.log(originJsonStr);

    try {
      var jsonMap = jsonDecode(Utils.convertUint8ListToString(rawData));

      result = TransMessageResult();
      result?.code = jsonMap["code"] ?? 0;
      result?.result = jsonMap["result"];
      result?.reason = jsonMap["reason"];
      result?.updateTime = jsonMap["updateTime"];
      result?.msgId = jsonMap["msgId"];
    } catch (e) {
      LogUtil.errorLog(e.toString());
    }
    return result;
  }

  @override
  int getType() {
    return MessageTypes.SEND_TRANS_MESSAGE_RESP;
  }
}

class SendTransMessageHandler extends MessageHandler<SendTransMessageRespMsg> {
  @override
  void handle(IMClient client, SendTransMessageRespMsg msg) {
    LogUtil.log("send trans message resp unique(${msg.uniqueId}) ");

    //callback
    if (msg.result != null) {
      TransMessageResult result = msg.result!;

      LogUtil.log("send trans message resp msgId (${result.msgId}) ");
      final TransMessage retTransMessage = TransMessage();
      retTransMessage.updateTime = result.updateTime;
      retTransMessage.msgId = result.msgId ?? "";

      client.sendTransMessageCallbackMap[result.msgId]
          ?.call(retTransMessage, result);

      //remove callback
      client.sendTransMessageCallbackMap.remove(result.msgId);
    }
  }
} //end IMLoginRespHandler class

class PushTransMessageReqMsg extends Message {
  late TransMessage transMessage;

  factory PushTransMessageReqMsg.from(Message head, ByteBuf buf) {
    PushTransMessageReqMsg transMessageReqMsg = PushTransMessageReqMsg();
    transMessageReqMsg.fill(head);
    transMessageReqMsg.decodeBody(buf, transMessageReqMsg.bodyLength);
    return transMessageReqMsg;
  }

  PushTransMessageReqMsg();

  @override
  dynamic decodeBody(ByteBuf buf, int bodySize) {
    Uint8List rawData = buf.readUint8List(bodySize);

    String originJsonStr = Utils.convertUint8ListToString(rawData);
    LogUtil.log(originJsonStr);

    try {
      var jsonMap = jsonDecode(originJsonStr);
      transMessage = TransMessage.fromMap(jsonMap);
    } catch (e) {
      LogUtil.errorLog(e.toString());
    }
    return transMessage;
  }

  @override
  int getType() {
    return MessageTypes.PUSH_TRANS_MESSAGE_REQ;
  }
} //end class

///
/// 接收新的透传消息
///
class PushTransMessageHandler extends MessageHandler<PushTransMessageReqMsg> {
  @override
  void handle(IMClient client, PushTransMessageReqMsg msg) {
    final TransMessage transMessage = msg.transMessage;
    LogUtil.log("received trans msg ${transMessage.content}");

    client.receivedTransMessage(transMessage);

    //send received push msg ack
    if (transMessage.offline) {
      client.sendData(PushTransMessageResp(msg.uniqueId.toString()).encode());
    }
  }
} //end class

//接到推送消息后 反馈已接收
class PushTransMessageResp extends Message {
  String? msgId; //ack msgid

  PushTransMessageResp(this.msgId);

  @override
  ByteBuf encodeBody() {
    Map<String, dynamic> body = {"msgId": msgId};

    String jsonBody = jsonEncode(body);
    LogUtil.log("jsonBody:$jsonBody");

    Uint8List bodyData = Utils.convertStringToUint8List(jsonBody);
    ByteBuf bodyBuf = ByteBuf.allocator(size: bodyData.length);
    bodyBuf.writeUint8List(bodyData);
    return bodyBuf;
  }

  @override
  int getType() {
    return MessageTypes.PUSH_TRANS_MESSAGE_RESP;
  }
}
