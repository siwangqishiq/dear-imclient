// ignore_for_file: file_names
import 'package:dearim/core/file_upload.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/protocol.dart';
import 'package:dearim/core/utils.dart';
import 'package:dearim/network/request.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/views/head_view.dart';
import 'package:dearim/views/toast_show_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _avatar;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController nicknameController;

  late FileUploadManager fileUploadManager;

  @override
  void initState() {
    super.initState();
    fileUploadManager = DefaultFileUploadManager();

    usernameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    nicknameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "注册",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: "用户名(必填)"),
                controller: usernameController,
                inputFormatters: [
                  FilteringTextInputFormatter(RegExp("[a-zA-Z]|[0-9]"), allow: true)
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                decoration:const InputDecoration(labelText: "密码(必填)"),
                obscureText: true,
                controller: passwordController,
              ),
              TextField(
                decoration:const InputDecoration(labelText: "确认密码(必填)"),
                obscureText: true,
                controller: confirmPasswordController,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration:const InputDecoration(labelText: "昵称(必填)"),
                controller: nicknameController,
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("头像:"),
              ),
              InkWell(
                onTap: ()=> pickAvatar(),
                child: HeadView(
                  _avatar ,
                  size: ImageSize.origin, 
                  width: 128, 
                  height:128 , 
                  circle: 100, 
                  key: UniqueKey(),
                ),
              ),
              const SizedBox(height: 8),
              MaterialButton(
                onPressed: () => register(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 400,
                    height: 40,
                    color: ColorThemes.themeColor,
                    child: const Center(
                      child: Text(
                        "注册账户",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      )
    );
  }

  void pickAvatar() async{
    FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.image);

    if(pickerResult != null){
      LogUtil.log("用户选择文件 ${pickerResult.files.single.path}");
      String? path = pickerResult.files.single.path;
      
      fileUploadManager.uploadFile(path!, UploadFileType.image, (result, url, attach){
        LogUtil.log("result = $result");
        if(result == Codes.success){
          LogUtil.log("url = $url");
          setState(() {
            _avatar = url;
          });
        }
      });
    }else{
      LogUtil.log("用户选择取消");
    }
  }

  //校验输入
  bool _validateInput(){
    String? account = usernameController.text;
    if(Utils.isTextEmpty(account)){
      ToastShowUtils.show("用户名不能为空", context);
      return false;
    }

    String? password = passwordController.text;
    if(Utils.isTextEmpty(password)){
      ToastShowUtils.show("密码不能为空", context);
      return false;
    }

    String? confirmPassword = confirmPasswordController.text;
    if(password != confirmPassword){
      ToastShowUtils.show("密码输入不一致", context);
      return false;
    }

    String? nickname = nicknameController.text;
    if(Utils.isTextEmpty(nickname)){
      ToastShowUtils.show("昵称不能为空", context);
      return false;
    }

    return true;
  }

  //注册账号
  void register(){
    if(!_validateInput()){
      return;
    }

    String? account = usernameController.text;
    String? password = passwordController.text;
    String? nickname = nicknameController.text;
    String? avatar = _avatar;

    _doRegister(account , password , nickname , avatar);
  }

  //调用注册接口
  void _doRegister(String account , String pwd , String nickname , String? avatar){
    Map<String, dynamic> params = {};
    params["username"] = account;
    params["pwd"] = pwd;
    params["nickname"] = nickname;
    params["avatar"] = avatar;
    params["description"] = null;

    Request().postRequest(
      "createAccount",
      params,
      Callback(
        successCallback: (data) async {
          LogUtil.log("注册接口成功 $data");
          ToastShowUtils.show("注册成功", context);
          Navigator.of(context).pop();
        }, 
        failureCallback: (code, errorStr, data) {
          LogUtil.log("注册接口错误 $data");
          ToastShowUtils.show("$errorStr", context);
        }
      )
    );
  }
}
