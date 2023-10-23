import 'dart:io';

import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/estore/estore.dart';
import 'package:dearim/core/log.dart';
import 'package:flutter_test/flutter_test.dart';

class User with Codec<User> {
  int id = 0;
  String? name;
  int age = -1;
  String? desc;

  @override
  User decode(ByteBuf buf) {
    User result = User();
    result.id = buf.readInt();
    result.name = buf.readString();
    result.age = buf.readInt16();
    result.desc = buf.readString();
    return result;
  }

  @override
  ByteBuf encode() {
    var buf = ByteBuf.allocator();
    buf.writeInt(id);
    buf.writeString(name);
    buf.writeInt16(age);
    buf.writeString(desc);
    return buf;
  }

  @override
  String key() {
    return "user";
  }

  @override
  String tableName() {
    return "user";
  }
}

List<User> createUserList(){
  List<User> list = <User>[];
  for(int i = 0 ; i < 1000 ;i++){
    User user = User();
    user.id = i + 1000;
    user.age = i +10;
    user.name = "name_$i";
    user.desc = "desc_dec_$i my name is ${user.name}";

    list.add(user);
  }//end for i
  return list;
}

void main() {

  test("open estore db", () async {
    EasyStore store = EasyStore.open("test_db");
    await store.init();

    var list = createUserList();
    for(User user in list){
      store.save(user);
    }//end for each

    store.delete();
  });

  test("read estore db", () async {
    EasyStore store = EasyStore.open("test2");
    //var dir = await store.findLocalPath();
    await store.init();

    var list = createUserList();
    for(User user in list){
      store.save(user);
    }//end for each

    List<dynamic> queryList = store.query(User());
    var userList = queryList.cast<User>();

    for(User u in userList){
      LogUtil.log("${u.id}  ${u.name}  ${u.age} ${u.desc}");
    }
  });
}
