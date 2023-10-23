import 'package:dearim/core/immessage.dart';

enum MessageType {
  text,
  picture,
  share,
  unknow
}


class ChatMessageModel {
  int uid = 0;
  String content = "";
  int createTime = 0;
  int updateTime = 0;
  MessageType msgType = MessageType.text;
  bool isReceived = false;//是否是消息的接收者
  int sessionId = 0;//会话ID
  String? msgId;//
  IMMessage? immessage;
  
  ChatMessageModel();

  
  static MessageType typeOf(int type){
    if(type == IMMessageType.Text){
      return MessageType.text;
    }else if(type == IMMessageType.Image){
      return MessageType.picture;
    }
    return MessageType.unknow;
  }

  factory ChatMessageModel.fromIMMessage(IMMessage msg){
    ChatMessageModel model = ChatMessageModel();

    model.msgId = msg.msgId;
    model.isReceived = msg.isReceived;
    model.sessionId = msg.isReceived?msg.fromId:msg.toId;
    model.content = msg.content??"";
    model.updateTime = msg.updateTime;
    model.createTime = msg.createTime;
    
    model.msgType = typeOf(msg.imMsgType);

    model.immessage = msg;
    //LogUtil.log("messageTyep ${msg.imMsgType} ");
    return model;
  }
}
