import 'dart:convert';

import 'package:dearim/app.dart';
import 'package:dearim/config.dart';
import 'package:dearim/core/avchat.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/pages/login_page.dart';
import 'package:dearim/pages/main_page.dart';
import 'package:dearim/pages/register_page.dart';
import 'package:dearim/routers/routers.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/user/user.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/utils/device_utils.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';
import 'core/immessage.dart';
import 'core/log.dart';
import 'core/protocol/trans.dart';
import 'models/trans.dart';
import 'pages/avchat_page.dart';
import 'tcp/tcp_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(isDeskTop()){
    await deskTopInit();
  }

  runApp(
    MaterialApp(
      home: MyApp(),
    )
  );
  // coreTestRun();
}

Future<void> deskTopInit() async {
 await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(App.WINDOW_WIDTH, App.WINDOW_HEIGHT),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  await windowManager.setPosition(Offset.zero);

  App.isBackground = false;

  await localNotifier.setup(
    appName: APP_NAME,
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget with WindowListener {
  MyApp({Key? key}) : super(key: key);

  TransMessageIncomingCallback? tranMsgObserver;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Routers().addRouter("/login", (context) => const LoginPage());
    Routers().addRouter("/main", (context) => const MainPage());
    Routers().addRouter("/register" , (context) => const RegisterPage());
    
    if(isDeskTop()){
      windowManager.addListener(this);
    }

    tranMsgObserver = 
      (TransMessage transMessage) => _onReceivedTransMessage(context, transMessage);
    IMClient.getInstance().registerTransMessageObserver(tranMsgObserver! , true);

    IMClient.getInstance()
      .registerIMMessageIncomingObserver((incomingIMMessageList){
        _onReceivedIMMessages(incomingIMMessageList);
      } , true);

    // Routers().addRouter("/chat", (context, {model}) => ChatPage(model: model));
    return MaterialApp(
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        primarySwatch: ColorThemes.themeColor,
        fontFamily: "cn",
      ),
      home: FutureBuilder(
        future: getUser(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.data == null) {
            //todo 显示一个欢迎页
            return Scaffold(
              body: Container(
                color: ColorThemes.themeColor,
                child: const Center(
                  child: Text(
                    "Welcome iM",
                    style: TextStyle(
                      fontSize: 30.0, 
                      color: Colors.white , 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            );
          }
          return nextPage(snapshot.data!);
        },
      ),
      routes: Routers().routers,
    );
  }

  ///
  /// 收取IM消息
  ///
  void _onReceivedIMMessages(List<IMMessage> incomingIMMessageList){
    LogUtil.log("main _onReceivedIMMessages ${incomingIMMessageList.length}");
    for(var msg in incomingIMMessageList){
      _handleIMMessage(msg);
    }
  }

  // 
  void _handleIMMessage(IMMessage msg){
    LogUtil.log("isDeskTop(): ${isDeskTop()}  ,  isBackground ${App.isBackground}");
    if(!isDeskTop() || !App.isBackground){
      return;
    }

    if(msg.sessionType == IMMessageSessionType.P2P){
      var name = ContactsDataCache.instance.getContactNameFromUid(msg.fromId);
      var content = msg.content;

      LocalNotification notification = LocalNotification(
        title: name,
        body:content,
      );
      notification.show();
    }
  }

  void _onReceivedTransMessage(BuildContext context, TransMessage transMessage){
    String? content = transMessage.content;
    if (content == null) {
      return;
    }

    // LogUtil.log("main.dart onTransMessageIncoming content: $content"); 
    Map<String, dynamic> json = jsonDecode(content);
    int type = json[CustomTransTypes.KEY_TYPE];
    switch(type){
      case CustomTransTypes.TYPE_AVCHAT_INVITE:
      _handleOnAVChatInvite(context , json);
      break;
    }//end switch
  }

  ///
  /// 接收到音视频通话邀请
  ///
  void _handleOnAVChatInvite(BuildContext context , Map<String, dynamic> json){
    var inviteUserMap = json[CustomTransTypes.KEY_CONTENT];
    int inviteUserId = inviteUserMap['uid'];

    var inviteContact = ContactsDataCache.instance.getContact(inviteUserId);
    if(inviteContact == null){
      return;
    }
  
    var receivedSuccess = AVChatManager.getInstance()
        .onReceivedInviteMessage(inviteUserMap);

    if(receivedSuccess){
      LogUtil.log("发起音视频通话 uid ${inviteContact.userId}  ${inviteContact.name}");
      Navigator.of(context)
        .push(MaterialPageRoute(builder: 
        (context) => AvChatPage(inviteContact , caller: false,)));
    }
  }

  bool isNeedShowDebug() {
    if (kDebugMode) {
      return true;
    }
    return false;
  }

  Future<User> getUser() async {
    User user = User();
    await user.restore();
    UserManager.getInstance()?.user = user;

    return user;
  }

  Widget nextPage(User user) {
    //print("是否可以自动登录: ${user.canAutoLogined()}");
    if (user.canAutoLogined()) {
      // 连接TCP
      TCPManager().connect(user.uid, user.token);
      return const MainPage();
    }
    return const LoginPage();
  }
  
  // @override
  // void onWindowEvent(String eventName){
  //   LogUtil.log("onWindowEvent $eventName");
  // }

  @override
  void onWindowMinimize(){
    App.isBackground = true;
    LogUtil.log("onWindowMinimize");
  }
  
  @override
  void onWindowFocus() {
    App.isBackground = false;
    LogUtil.log("onWindowFocus ${App.isBackground}");
  }
}

//适配桌面端的鼠标拖动
class MyCustomScrollBehavior extends MaterialScrollBehavior{
  @override
  Set<PointerDeviceKind> get dragDevices => { 
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
