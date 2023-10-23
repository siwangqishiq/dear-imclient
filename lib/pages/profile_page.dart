import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/network/request.dart';
import 'package:dearim/pages/contact_page.dart';
import 'package:dearim/pages/info_update_page.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/views/contact_view.dart';
import 'package:dearim/views/head_view.dart';
import 'package:dearim/views/toast_show_utils.dart';
import 'package:dearim/widget/dialog_helper.dart';
import 'package:flutter/material.dart';

import '../config.dart';

///
/// 我的 页面
///
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          APP_NAME,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          MyInfoWidget(),
        ],
      ),
    );
  }
}

///
/// 个人信息栏
///
class MyInfoWidget extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  MyInfoWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyInfoState();
  }
}

class MyInfoState extends State<MyInfoWidget> {
  String? name;
  String? avatar;
  String? account = "";
  int uid = 0;

  ContactModel _info = ContactModel("", 0);

  late VoidCallback _infoChangeCallback;

  @override
  void initState() {
    super.initState();
    _infoChangeCallback = () {
      LogUtil.log("个人信息页 _infoChangeCallback");
      _displayMyInfo();
    };
    ContactsDataCache.instance.addListener(_infoChangeCallback);

    _displayMyInfo();
  }

  void _displayMyInfo() {
    setState(() {
      uid = IMClient.getInstance().uid;

      ContactModel? info = ContactsDataCache.instance.getContact(uid);
      name = info?.name;
      avatar = info?.avatar;
      account = info?.account;

      _info = info ?? ContactModel("", 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _updateInfo(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            HeadView(
              avatar,
              size: ImageSize.middle,
              width: 150,
              height: 150,
              circle: 100,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              name ?? "",
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(account ?? "",
                style: const TextStyle(fontSize: 16, color: Colors.black)),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 8, 40, 40),
              child: ElevatedButton(
                onPressed: () => loginOut(),
                child: const Text("退出登录"),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                    primary: Colors.redAccent),
              ),
            )
          ],
        ),
      ),
    );
  }

  void loginOut() {
    DialogHelper.showAlertDialog(
        "确定登出吗?", "", context, () => doLoginOut(), () {});
  }

  void doLoginOut() {
    UserManager.getInstance()?.logout(Callback(successCallback: (data) async {
      await UserManager.getInstance()!.user?.clear();
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed("/login");
    }));
  }

  //更新个人信息页
  void _updateInfo() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => InfoUpdatePage(_info)));
  }

  @override
  void dispose() {
    ContactsDataCache.instance.removeListener(_infoChangeCallback);
    super.dispose();
  }
}
