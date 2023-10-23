import 'dart:convert';
import 'dart:io';

import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/message.dart';
import 'package:dearim/utils/text_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';

import 'estore/estore.dart';
import 'utils.dart';

///
/// IM消息
///
// ignore_for_file: constant_identifier_names

//im消息体
class IMMessage with Codec<IMMessage>{
  static const int CODE_RECEIVED = 1;//消息接收
  static const int CODE_SEND = 0;//消息发出

  int size = 0; //消息总大小
  String msgId = ""; //消息唯一标识
  int fromId = 0; //发送人ID
  int toId = 0; //接收人ID
  int createTime = 0;
  int updateTime = 0;

  int imMsgType = 0; //消息类型
  int sessionType = IMMessageSessionType.P2P;
  int msgState = 0; //消息状态
  int readState = 1; //已读状态 0已读  1未读
  int fromClient = 0;
  int toClient = 0;

  String? content; //消息内容
  String? url; //资源Url
  int attachState = 0; //附件状态
  String? attachInfo; //附件信息
  String? localPath; //资源本地路径
  String? custom; //自定义扩展字段

  bool isReceived = false; //是否是接收消息 此字段不参与传输
  int id = -1;//本地存储时数据库的ID 此字段不参与传输

  IMMessage();

  factory IMMessage.fromMap(Map<String, dynamic> map) {
    final IMMessage msg = IMMessage();
    msg.size = map["size"] ?? 0;
    msg.msgId = map["msgId"];
    msg.fromId = map["fromId"] ?? 0;
    msg.toId = map["toId"] ?? 0;
    msg.createTime = map["createTime"] ?? 0;
    msg.updateTime = map["updateTime"] ?? 0;

    msg.imMsgType = map["imMsgType"] ?? 0;
    msg.sessionType = map["sessionType"] ?? 0;
    msg.msgState = map["msgState"] ?? 0;
    msg.readState = map["readState"] ?? 0;
    msg.fromClient = map["fromClient"] ?? 0;
    msg.toClient = map["toClient"] ?? 0;
    
    msg.content = map["content"];
    msg.url = map["url"];
    msg.attachState = map["attachState"] ?? 0;
    msg.attachInfo = map["attachInfo"];
    msg.custom = map["custom"];

    return msg;
  }

  //encode编码为Map
  Map<String, dynamic> encodeMap() {
    final Map<String, dynamic> body = <String, dynamic>{};
    body["size"] = size;
    body["msgId"] = msgId;
    body["fromId"] = fromId;
    body["toId"] = toId;
    body["createTime"] = createTime;
    body["updateTime"] = updateTime;

    body["imMsgType"] = imMsgType;
    body["sessionType"] = sessionType;
    body["msgState"] = msgState;
    body["readState"] = readState;
    body["fromClient"] = fromClient;
    body["toClient"] = toClient;

    body["content"] = content;
    body["url"] = url;
    body["attachState"] = attachState;
    body["attachInfo"] = attachInfo;
    body["custom"] = custom;

    return body;
  }

  //会话ID
  int get sessionId => isReceived ? fromId : toId;

  //消息资源 是否需要上传 文件相关消息需要
  bool get needUpload => imMsgType == IMMessageType.Image && TextUtils.isEmpty(url);

  //需要资源上传的消息
  bool get reourceNeedUpload => imMsgType == IMMessageType.Image || imMsgType == IMMessageType.File;

  @override
  IMMessage decode(ByteBuf buf) {
    final IMMessage msg  = IMMessage();
    msg.size = buf.readInt32();
    msg.msgId = buf.readString()??"";
    msg.fromId = buf.readInt64();
    msg.toId = buf.readInt64();
    msg.createTime = buf.readInt64();
    msg.updateTime = buf.readInt64();

    msg.imMsgType = buf.readInt32();
    msg.sessionType = buf.readInt32();
    msg.msgState = buf.readInt32();
    msg.readState = buf.readInt32();
    msg.fromClient = buf.readInt32();
    msg.toClient = buf.readInt32();

    msg.content = buf.readString();
    msg.url = buf.readString();
    msg.attachState = buf.readInt32();
    msg.attachInfo = buf.readString();
    msg.custom = buf.readString();

    msg.isReceived = (buf.readInt8() == CODE_RECEIVED);
    return msg;
  }

  @override
  ByteBuf encode() {
    ByteBuf buf = ByteBuf.allocator(size: 256);

    buf.writeInt32(size);
    buf.writeString(msgId);
    buf.writeInt64(fromId);
    buf.writeInt64(toId);
    buf.writeInt64(createTime);
    buf.writeInt64(updateTime);

    buf.writeInt32(imMsgType);
    buf.writeInt32(sessionType);
    buf.writeInt32(msgState);
    buf.writeInt32(readState);
    buf.writeInt32(fromClient);
    buf.writeInt32(toClient);

    buf.writeString(content);
    buf.writeString(url);
    buf.writeInt32(attachState);
    buf.writeString(attachInfo);
    buf.writeString(custom);

    buf.writeInt8(isReceived?CODE_RECEIVED:CODE_SEND);
    return buf;
  }

  @override
  String key() => msgId;

  @override
  String tableName() {
    return "immessage";
  }
} //end class

class IMMessageType {
  static const int Text = 1; //文本消息
  static const int Image = 2;//图片消息
  static const int File = 4;//文件
}

class IMMessageSessionType {
  static const int P2P = 1;
  static const int TEAM = 2;
}

class AttachState {
  static const int UNUPLOAD = 0;//未上传
  static const int UPLOADING = 1;//上传中
  static const int UPLOADED = 2;//上传完成
}

//消息状态
class IMMessageState{
  static const int INITED = 0;//
  static const int SENDED = 200;//发送成功
}

//IM消息返回结果
class IMMessageResult extends Result {
  int createTime = 0;
  int updateTime = 0;
  String? msgId;
}

//构造消息体
class IMMessageBuilder {
  static const int TEXT_MAX_LENGHT = 300;

  //创建文本消息
  static IMMessage? createText(int toUid, int sessionType, String content) {
    if (toUid <= 0) {
      LogUtil.errorLog("error uid for $toUid");
      return null;
    }

    if (content.length >= TEXT_MAX_LENGHT || Utils.isTextEmpty(content)) {
      LogUtil.errorLog("content too long or empty for text immessage");
      return null;
    }

    IMMessage imMessage = initIMMessage();
    
    imMessage.sessionType = sessionType;
    imMessage.toId = toUid;
    imMessage.imMsgType = IMMessageType.Text;
    imMessage.content = content;
    return imMessage;
  }

  //创建图片消息
  static Future<IMMessage?> createImage(int toUid ,int sessionType, String imagePath) async{
    if (toUid <= 0) {
      LogUtil.errorLog("error uid for $toUid");
      return null;
    }

    final File file = File(imagePath);
    if(imagePath.isEmpty || !file.existsSync()){
      LogUtil.errorLog("$imagePath file not exist");
      return null;
    }

    IMMessage imMessage = initIMMessage();

    imMessage.sessionType = sessionType;
    imMessage.toId = toUid;
    imMessage.localPath = imagePath;
    imMessage.imMsgType = IMMessageType.Image;
    imMessage.content = "[图片]";

    Map<String , dynamic> info = {};
    var imageInfo = await decodeImageFromList(await file.readAsBytes());
    LogUtil.log("图片大小 ${imageInfo.width} x ${imageInfo.height}");
    info["w"] = imageInfo.width;
    info["h"] = imageInfo.height;
    info["size"] = file.lengthSync();
    info["mime"] = lookupMimeType(file.path);
    info["md5"] = await MD5Utils.genFileMd5(file.path);
    imMessage.attachInfo = jsonEncode(info);
    imMessage.attachState = AttachState.UNUPLOAD;//未上传附件

    LogUtil.log("attach: ${imMessage.attachInfo}");

    return imMessage;
  }

  ///
  /// 生成转发IM消息
  ///
  static IMMessage? createForwardIMMessage(IMMessage msg , 
      int toUid , int toSessionType){
    if (toUid <= 0) {
      LogUtil.errorLog("error uid for $toUid");
      return null;
    }

    final IMMessage forwardMessage = initIMMessage();

    forwardMessage.sessionType = toSessionType;
    forwardMessage.toId = toUid;
    forwardMessage.localPath = msg.localPath;
    forwardMessage.imMsgType = msg.imMsgType;
    forwardMessage.content = msg.content;
    forwardMessage.attachInfo = msg.attachInfo;
    forwardMessage.attachState = msg.attachState;
    
    forwardMessage.url = msg.url;

    return forwardMessage;
  }

  //初始化一个IMMessage
  static IMMessage initIMMessage() {
    IMMessage imMessage = IMMessage();
    imMessage.fromId = IMClient.getInstance().uid;
    imMessage.isReceived = false;
    imMessage.fromClient = Utils.getClientType();
    int time = Utils.currentTime();
    imMessage.createTime = time;
    imMessage.updateTime = time;

    imMessage.readState = 1;//未读 

    return imMessage;
  }
} //end class
