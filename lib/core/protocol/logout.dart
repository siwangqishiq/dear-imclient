import 'dart:convert';
import 'dart:typed_data';

import '../byte_buffer.dart';
import '../imcore.dart';
import '../log.dart';
import '../utils.dart';
import 'message.dart';
import 'protocol.dart';

///
///退出登录
///

//退出登录请求
class LogoutReqMessage extends Message {
  String? token;

  LogoutReqMessage(this.token);

  @override
  ByteBuf encodeBody() {
    Map body = {};
    body["token"] = token;

    String jsonBody = jsonEncode(body);
    LogUtil.log("jsonBody:$jsonBody");

    Uint8List bodyData = Utils.convertStringToUint8List(jsonBody);

    ByteBuf bodyBuf = ByteBuf.allocator(size: bodyData.length);
    bodyBuf.writeUint8List(bodyData);
    return bodyBuf;
  }

  @override
  int getType() {
    return MessageTypes.LOGOUT_REQ;
  }
} //end class

//退出登录服务端返回
class LogoutRespMessage extends Message {

  factory LogoutRespMessage.from(Message head, ByteBuf buf) {
    LogoutRespMessage respMessage = LogoutRespMessage();
    respMessage.fill(head);
    respMessage.decodeBody(buf, respMessage.bodyLength);
    return respMessage;
  }

  Result? _result;

  Result? get result => _result;

  @override
  dynamic decodeBody(ByteBuf buf, int bodySize) {
    Uint8List rawData = buf.readUint8List(bodySize);
    
    String originJsonStr = Utils.convertUint8ListToString(rawData);
    LogUtil.log(originJsonStr);

    try{
      var jsonMap = jsonDecode(Utils.convertUint8ListToString(rawData));
      
      _result = Result();
      _result?.code = jsonMap["code"]??0;
      _result?.result = jsonMap["result"];
      _result?.reason = jsonMap["reason"];
    }catch(e){
      LogUtil.errorLog(e.toString());
    }
    return _result;
  }
  
  LogoutRespMessage();
}

//退出登录处理
class LogoutRespHandler extends MessageHandler<LogoutRespMessage> {
  @override
  void handle(IMClient client, LogoutRespMessage msg) {
    LogUtil.log("logout resp unique(${msg.uniqueId}) ");

    if(msg.result != null && msg.result!.result){
      client.afterLogout(msg.result!.result);
    }

    //callback
    if(client.logoutCallback != null){
      client.logoutCallback!(msg.result!);
    }
  }
}//end IMLoginRespHandler class
