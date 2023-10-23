
import 'package:dearim/core/log.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/network/request.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:lpinyin/lpinyin.dart';

///
///联系人数据 全局缓存
///
class ContactsDataCache with ChangeNotifier{
  static final ContactsDataCache _instance = ContactsDataCache();

  static ContactsDataCache get instance => _instance;

  Map<int , ContactModel> contacts = <int , ContactModel>{};

  //增加或更新联系人
  void addOrUpdateContact(ContactModel contact){
    contacts[contact.userId] = contact;
    notifyListeners();
  }

  //移除联系人
  void removeContact(int userId){
    if(contacts.containsKey(userId)){
      contacts.remove(userId);
      notifyListeners();
    }
  }

  //获取联系人
  ContactModel? getContact(int userId){
    return contacts[userId];
  }

  //获取姓名
  String getContactNameFromUid(int userId) => getContact(userId)?.name??userId.toString();

  //重置联系人数据
  void resetContacts(List<ContactModel> list){
    contacts.clear();
    for(ContactModel contact in list){
      contacts[contact.userId] = contact;
    }//end for each
    notifyListeners();
  }

  List<ContactModel> get allContacts {
    List<ContactModel> list = <ContactModel>[];
    for(var key in contacts.keys){
      list.add(contacts[key]!);
    }

    //sort by update time
    list.sort((left, right) {
      String leftPinyin = PinyinHelper.getPinyinE(left.name);
      String rightPinyin = PinyinHelper.getPinyinE(right.name);
      //LogUtil.log("${left.name}   ${right.name} leftPinyin $leftPinyin rightPinyin $rightPinyin");
      return leftPinyin.compareTo(rightPinyin);
    });
    return list;
  }

  //重新获取联系人数据
  void fetchContacts() {
    Request().postRequest(
      "/contacts",
      {},
      Callback(
          successCallback: (data) {
            List list = data["list"];
            List<ContactModel> models = [];
            for (Map item in list) {
              ContactModel model = ContactModel(item["name"], item["uid"]);
              model.avatar = item["avatar"] ?? "";

              model.user.uid = item["uid"];
              model.user.name = item["name"];
              model.user.avatar = item["avatar"] ?? "";
              model.user.account = item["account"] ?? "";
              
              if (item["uid"] == UserManager.getInstance()!.user!.uid) {
                UserManager.getInstance()!.user!.avatar = item["avatar"] ?? "";
              }
              models.add(model);
            }

            ContactsDataCache.instance.resetContacts(models);
          },
          failureCallback: (code, msgStr, data) {}),
    );
  }

}//end class