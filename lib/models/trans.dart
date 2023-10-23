// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';

///
/// 自定义透传消息
///
class CustomTransTypes {
  static const String KEY_TYPE = "type";
  static const String KEY_CONTENT = "content";

  static const int TYPE_INPUTTING = 10; //正在输入中
  static const int TYPE_CONTACT_CREATE = 101; //通讯录有新增
  static const int TYPE_CONTACT_UPDATE = 102; //通讯录有更新

  static const int TYPE_AVCHAT_INVITE = 201; //邀请音视频通话
  static const int TYPE_AVCHAT_REJECT = 202; //拒绝音视频通话
  static const int TYPE_AVCHAT_ACCEPT = 203; //接受音视频通话
  static const int TYPE_AVCHAT_OFFER = 204;//webrtc offer消息
  static const int TYPE_AVCHAT_ANSWER = 205;//webrtc answer消息
  static const int TYPE_AVCHAT_ICE_CANDIDATE = 206;// webrtc ice candidate消息
  static const int TYPE_AVCHAT_HANGUP = 210; //挂断通话
}

class CustomTransBuilder {
  static String build(int type, dynamic content) {
    Map<String, dynamic> json = {};
    json[CustomTransTypes.KEY_TYPE] = type;

    if (content != null) {
      json[CustomTransTypes.KEY_CONTENT] = content;
    }
    return jsonEncode(json);
  }
}
