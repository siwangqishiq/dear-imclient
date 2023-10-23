//消息类型
// ignore_for_file: constant_identifier_names

class MessageTypes {
  static const int UNDEF = 0;
  static const int LOGIN_REQ = 1; //登录请求
  static const int LOGIN_RESP = 2; //登录返回

  static const int LOGOUT_REQ = 3;//退出登录 请求
  static const int LOGOUT_RESP = 4;//退出登录 响应

  static const int SEND_IMMESSAGE_REQ = 5;//发送消息 请求
  static const int SEND_IMMESSAGE_RESP = 6;//发送消息 响应

  static const int PUSH_IMMESSAGE_REQ = 7;//接收推送消息
  static const int PUSH_IMMESSAGE_RESP = 8;//接收推送消息 响应
  
  //心跳包
  static const int PING = 10;// 心跳包 请求
  static const int PONG = 11;// 心跳包 响应

  static const int SYNC_MESSAGE_REQ = 12;//同步消息 请求
  static const int SYNC_MESSAGE_RESP = 13;//同步消息 响应

  static const int SEND_TRANS_MESSAGE_REQ = 14;//透传消息 发送请求
  static const int SEND_TRANS_MESSAGE_RESP = 15;//透传消息 发送后响应

  static const int PUSH_TRANS_MESSAGE_REQ = 16;//接收透传消息 
  static const int PUSH_TRANS_MESSAGE_RESP = 17;//接收透传消息 响应

  static const int KICK_OFF = 400;//踢出 来自其他端抢登
}

class BodyEncodeTypes {
  static const int JSON = 1;
}

class ProtocolConfig {
  static const int MagicNumber = 900523; //
  static const int Version = 1;
  static const int BodyEncodeType = BodyEncodeTypes.JSON;
}

class Codes {
  static const int success = 200; //响应成功
  static const int error = 500;//响应失败
  static const int failed = 400;

  static const int update = 201;//状态更新

  static const int errorState = 501;//状态不正确
}
