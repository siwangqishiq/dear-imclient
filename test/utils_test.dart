
import 'dart:convert';
import 'dart:typed_data';

import 'package:dearim/core/utils.dart';

void main(){
  Map<String , dynamic> map = {};
  map["code"] = 100;
  map["data"] = "你好世界";

  String jsonStr = jsonEncode(map);

  Uint8List raw = Utils.convertStringToUint8List(jsonStr);

  String json = Utils.convertUint8ListToString(raw);
  print(json);
}

