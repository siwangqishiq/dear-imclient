import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/user/user.dart';

class ChatDataManager {
  static ChatDataManager? _instance;
  User? user;

  static ChatDataManager? getInstance() {
    // ignore: prefer_conditional_assignment
    if (_instance == null) {
      _instance = ChatDataManager();
    }
    return _instance;
  }

  final Map<int /*uid*/, List<ChatMessageModel>> _messageMap = {};
  final Map<int /*uid*/, User> _userMap = {};
  // 添加message
  void addMessage(ChatMessageModel model, User user) {
    List<ChatMessageModel>? list = _messageMap[user.uid];
    if (list == null) {
      list = <ChatMessageModel>[];
      _messageMap[user.uid] = list;
    }
    list.add(model);
    _addUser(user);
  }

  void _addUser(User user) {
    _userMap[user.uid] = user;
  }

  List<ChatMessageModel> getMsgModels(int uid) {
    List<ChatMessageModel>? models = _messageMap[uid];
    if (models == null) {
      return [];
    }
    return models;
  }

  User? getUser(int uid) {
    return _userMap[uid];
  }
}
