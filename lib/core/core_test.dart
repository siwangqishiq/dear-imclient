import 'package:dearim/core/estore/estore.dart';
import 'package:dearim/core/file_upload.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/protocol.dart';
import 'package:dearim/core/protocol/trans.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'imcore.dart';
import 'utils.dart';

///
/// core测试相关
///
void coreTestRun() {
  runApp(const CoreTestApp());
}

class CoreTestApp extends StatelessWidget {
  const CoreTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dearIM',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TestCoreMain(),
    );
  }
}

class TestCoreMainState extends State<TestCoreMain> {
  String mClientStatus = "init";

  String mIncomingMessage = "";

  StateChangeCallback? _stateChangeCallback;

  IMMessageIncomingCallback? _imMessageIncomingCallback;

  TransMessageIncomingCallback? _tranMsgIncomingCallback;

  late TextEditingController _editController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    EasyStore s = EasyStore.open("test_ppp");

    _editController = TextEditingController(text: "你好世界");
    _focusNode = FocusNode();

    initIM();
  }

  //im client test
  void initIM() {
    _stateChangeCallback ??= (oldState, newState) {
      LogUtil.log("change state $oldState to $newState");

      setState(() {
        mClientStatus = newState.toString();
      });
    };

    IMClient.getInstance().registerStateObserver(_stateChangeCallback!, true);

    _imMessageIncomingCallback ??= (incomingIMMessageList) {
      setState(() {
        mIncomingMessage = incomingIMMessageList.first.content!;
      });
    };

    IMClient.getInstance()
        .registerIMMessageIncomingObserver(_imMessageIncomingCallback!, true);

    _tranMsgIncomingCallback = (transMessage) {
      LogUtil.log("接收透传消息 from:${transMessage.from}");
      LogUtil.log("接收透传消息 content:${transMessage.content}");
    };

    IMClient.getInstance()
        .registerTransMessageObserver(_tranMsgIncomingCallback!, true);
  }

  void login(int uid) {
    String token = "fuckali_$uid";

    IMClient.getInstance().imLogin(uid, token, loginCallback: (result) {
      if (result.result) {
        LogUtil.log("IM登录成功");
      } else {
        LogUtil.log("IM登录失败 原因: ${result.reason}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "TestCore",
            style: TextStyle(color: Colors.white),
          ),
        ),
        // ignore: avoid_unnecessary_containers
        body: Container(
          child: Center(
              child: SizedBox(
            width: 320,
            child: ListView(
              children: <Widget>[
                Text(
                    "status: $mClientStatus  uid: ${IMClient.getInstance().uid}"),
                ElevatedButton(
                  onPressed: () => login(1),
                  child: const Text("登录1"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => login(2),
                  child: const Text("登录2"),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _editController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                    cursorColor: Colors.black,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    focusNode: _focusNode,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => sendTextMessage(1),
                  child: const Text("发送文本消息给1"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => sendTextMessage(2),
                  child: const Text("发送文本消息给2"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => imLogout(),
                  child: const Text("退出IM登录"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => sendTransMessage(2),
                  child: const Text("发送透传消息给2"),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => selectFile(),
                  child: const Text("选择文件"),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text("接收消息 : $mIncomingMessage"),
              ],
            ),
          )),
        ));
  }

  @override
  void dispose() {
    IMClient.getInstance()
        .registerTransMessageObserver(_tranMsgIncomingCallback!, false);
    _editController.dispose();
    _focusNode.dispose();
    IMClient.getInstance().dispose();
    super.dispose();
  }

  //文件选择
  void selectFile() async {
    FilePickerResult? pickerResult = await FilePicker.platform.pickFiles();

    if(pickerResult != null){
      LogUtil.log("用户选择文件 ${pickerResult.files.single.path}");

      String? path = pickerResult.files.single.path;

      FileUploadManager uploadMgr = DefaultFileUploadManager();
      uploadMgr.uploadFile(path!, UploadFileType.file, (result, url, attach){
        LogUtil.log("result = $result");
        if(result == Codes.success){
          LogUtil.log("url = $url");
        }
      });
    }else{
      LogUtil.log("用户选择取消");
    }
  }

  void imLogout() {
    IMClient.getInstance().imLoginOut(loginOutCallback: (r) {
      LogUtil.log("退出登录: ${r.result}");
    });
  }

  void sendTransMessage(int toId) {
    String content = _editController.text;

    TransMessage? msg = TransMessageBuilder.create(toId, content, null);
    if (msg != null) {
      IMClient.getInstance().sendTransMessage(msg,
          callback: (transMessage, result) {
        LogUtil.log("send trans message ${result.code}");
      });
    }
  }

  void sendTextMessage(int toId) {
    String content = _editController.text;

    IMMessage? msg =
        IMMessageBuilder.createText(toId, IMMessageSessionType.P2P, content);
    if (msg != null) {
      IMClient.getInstance().sendIMMessage(msg, callback: (imMessage, result) {
        LogUtil.log("send im message ${result.code}");
      });
    }
  }
}

class TestCoreMain extends StatefulWidget {
  const TestCoreMain({Key? key}) : super(key: key);

  @override
  TestCoreMainState createState() => TestCoreMainState();
}
