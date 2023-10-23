// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class ToastShowUtils {

  ///
  /// 显示toast msg
  ///
  static void show(String _msg, BuildContext context) {
    // if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    //   ScaffoldMessenger.of(context).hideCurrentSnackBar();
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_msg)));
    // } else {
    //   Fluttertoast.showToast(msg: _msg);
    // }

    // FlutterToastr
    FlutterToastr.show(_msg, context);
  }

  
}
