import 'dart:convert';
import 'dart:io';

import 'package:dearim/config.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/trans.dart';
import 'package:dearim/core/session.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/models/trans.dart';
import 'package:dearim/pages/selector_page.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'session_list_page.dart';
import 'contact_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  UnreadCountChangeCallback? _unreadCountCallback;
  int sessionUnreadCount = 0;

  // 新消息到来监听
  IMMessageIncomingCallback? _immessageIncomingCallback;

  // 自定义透传消息监听
  TransMessageIncomingCallback? _transMessageIncomingCallback;

  MethodChannel nativeChannel = const MethodChannel(NATIVE_CHANNEL);

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      // LogUtil.log("cur ${controller.index}");
      setState(() {});
    });

    _unreadCountCallback = (int oldUnreadCunt, int currentUnreadCount) {
      //LogUtil.log("更新未读数量 $oldUnreadCunt   $currentUnreadCount");
      Future.delayed(const Duration(milliseconds: 200)).then((e) {
        setState(() {
          sessionUnreadCount = currentUnreadCount;
        });
      });
    };
    IMClient.getInstance()
        .registerUnreadCountObserver(_unreadCountCallback!, true);
    sessionUnreadCount = IMClient.getInstance().sessionUnreadCount;
    _fetchContacts();

    _immessageIncomingCallback = (incomingIMMessageList) {
      _onIMMessageIncoming(incomingIMMessageList.last);
    };
    
    IMClient.getInstance().registerIMMessageIncomingObserver(_immessageIncomingCallback! , true);

    _transMessageIncomingCallback = (transMessage){
      _onTransMessageIncoming(transMessage);
    };

    IMClient.getInstance().registerTransMessageObserver(_transMessageIncomingCallback!, true);
  }

  ///
  /// 接收透传消息
  ///
  void _onTransMessageIncoming(TransMessage transMessage){
    String? content = transMessage.content;
    if (content == null) {
      return;
    }

    // LogUtil.log("onTransMessageIncoming content: $content"); 

    Map<String, dynamic> json = jsonDecode(content);
    int type = json[CustomTransTypes.KEY_TYPE];

    switch(type){
      case CustomTransTypes.TYPE_CONTACT_UPDATE:
      case CustomTransTypes.TYPE_CONTACT_CREATE:
        _handleContactUpdate(json);
        break;
    }//end switch
  }

  ///
  /// 联系人更新
  ///
  void _handleContactUpdate(Map<String, dynamic> json){
    _fetchContacts();
  }

  ///
  /// 接到新的IM消息 针对特定平台 做出UI提醒
  ///
  Future<int> _onIMMessageIncoming(IMMessage msg) async{
    if(Platform.isWindows){ //信消息到来时  windows平台任务栏闪烁
      await nativeChannel.invokeListMethod("onReceivedImmessage");
    }else if(Platform.isAndroid){
      var params = <String , String>{};
      ContactModel? contact = ContactsDataCache.instance.getContact(msg.fromId);
      params["name"] = contact?.name??msg.fromId.toString();
      params["content"] = msg.content??"";
      await nativeChannel.invokeListMethod("notifyIMMessage" , params);
    }
    
    return Future.value(0);
  }

  //获取通讯录数据
  void _fetchContacts() {
    ContactsDataCache.instance.fetchContacts();
  }

  @override
  void dispose() {
    // LogUtil.log("main page dispose");
    if(_immessageIncomingCallback != null){
      IMClient.getInstance().registerIMMessageIncomingObserver(_immessageIncomingCallback!, false);
    }

    IMClient.getInstance()
        .registerUnreadCountObserver(_unreadCountCallback!, false);
    IMClient.getInstance().dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double tabSize = 36;
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     APP_NAME,
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
      body: TabBarView(controller: controller, children: const [
        SessionPageWidget(),
        ContactPage(),
        ProfilePage(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            controller.index = index;
          });
        },
        iconSize: tabSize,
        currentIndex: controller.index,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.chat),
                Positioned(
                    right: 0,
                    top: 0,
                    child: AnimatedContainer(
                      padding: const EdgeInsets.all(2),
                      duration: const Duration(milliseconds: 100),
                      width: sessionUnreadCount > 0 ? 20 : 0,
                      height: sessionUnreadCount > 0 ? 20 : 0,
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          sessionUnreadCount.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ))
              ],
            ),
            label: "聊天",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: "通讯录",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "我的",
          ),
        ],
      ),
      //
      // floatingActionButton: FloatingActionButton(
      //   child: const Icon(Icons.adb),
      //   onPressed: () async {
      //     var result = await Navigator.of(context).push(
      //       PageRouteBuilder(
      //         pageBuilder: (BuildContext context, Animation<double> animation,Animation<double> secondaryAnimation) => const SelectorWidget()
      //       ),
      //     );

      //     LogUtil.log("selector result : $result");
      //   },
      // ),

      // bottomNavigationBar: Material(
      //   color: Colors.white,
      //   child: TabBar(
      //     controller: controller,
      //     labelColor: ColorThemes.themeColor,
      //     unselectedLabelColor: ColorThemes.unselectColor,
      //     indicator: const BoxDecoration(),
      //     tabs: const [
      //       Tab(
      //         text: "聊天",
      //         icon: Icon(Icons.chat),
      //         height: tabSize,
      //         iconMargin: tabMargin,
      //       ),
      //       Tab(
      //         text: "通讯录",
      //         icon: Icon(Icons.contact_mail),
      //         height: tabSize,
      //         iconMargin: tabMargin
      //       ),
      //       Tab(
      //         text: "我的",
      //         icon: Icon(Icons.person_outline),
      //         height: tabSize,
      //         iconMargin: tabMargin
      //       ),
      //     ]
      //   ),
      // ),
    );
  }
}
