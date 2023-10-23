import 'dart:typed_data';

import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("bytebuf allocator", () {
    ByteBuf buf = ByteBuf.allocator(size: 2);
    LogUtil.log("limit : ${buf.limit}");

    expect(ByteBuf.initMinSize, buf.limit);
  });

  test("debug print", () {
    ByteBuf buf = ByteBuf.allocator(size: 3);
    buf.debugPrint();
  });

  test("write byte", () {
    ByteBuf buf = ByteBuf.allocator(size: 2);
    buf.writeInt8(255);
    buf.writeInt8(256);
    buf.writeInt8(257);
    buf.writeInt8(258);

    buf.debugPrint();

    expect(buf.getValue(0), 255);
    expect(buf.getValue(1), 0);
    expect(buf.getValue(2), 1);
    expect(buf.getValue(3), 2);

    buf.writeInt8(-1);
    buf.debugPrint();

    expect(buf.writeIndex, 5);
    expect(buf.readIndex, 0);

    buf.reset();

    expect(buf.writeIndex, 0);
    expect(buf.readIndex, 0);
  });

  test("read byte", () {
    ByteBuf buf = ByteBuf.allocator();
    var value = buf.readInt8();
    expect(0, value);

    buf.writeInt8(1);
    buf.writeInt8(2);
    buf.writeInt8(3);
    buf.writeInt8(4);
    buf.writeInt8(5);

    expect(1, buf.readInt8());
    expect(2, buf.readInt8());
    expect(3, buf.readInt8());
    expect(4, buf.readInt8());
    expect(5, buf.readInt8());
    buf.debugPrint();

    expect(0, buf.readInt8());

    expect(0, buf.couldReadableSize);
  });

  test("write uint8List", () {
    ByteBuf buf = ByteBuf.allocator(size: 3);
    buf.writeInt8(7);

    var data1 = Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 25566]);
    buf.writeUint8List(data1);

    expect(12, buf.writeIndex);
    buf.debugPrint();

    expect(0, buf.readIndex);

    int firstValue = buf.readInt8();
    expect(7, firstValue);
  });

  test("read uint8List", () {
    ByteBuf buf = ByteBuf.allocator(size: 3);
    buf.writeInt8(7);
    buf.writeInt8(8);
    buf.writeInt8(9);

    Uint8List list = buf.readUint8List(3);
    expect(7, list[0]);
    expect(8, list[1]);
    expect(9, list[2]);

    expect(3, buf.readIndex);
    expect(3, buf.writeIndex);
    expect(0, buf.couldReadableSize);

    buf.writeInt8(1);
    expect(1, buf.readInt8());

    buf.debugPrint();
  });

  test("read all uint8List", () {
    ByteBuf buf = ByteBuf.allocator(size: 3);
    buf.writeInt8(7);
    buf.writeInt8(8);
    buf.writeInt8(9);

    Uint8List list = buf.readAllUint8List();

    expect(7, list[0]);
    expect(8, list[1]);
    expect(9, list[2]);

    buf.debugPrint();
  });

  test("write int16", () {
    ByteBuf buf = ByteBuf.allocator();
    buf.writeInt16(1000);
    buf.writeInt8(7);
    buf.writeInt16(1000);

    buf.debugPrint();
  });

  test("read int16", () {
    ByteBuf buf = ByteBuf.allocator();
    buf.writeInt8(7);
    buf.writeInt8(1000);
    buf.writeInt16(3333);

    expect(7, buf.readInt8());
    buf.readInt8();
    expect(3333, buf.readInt16());

    buf.reset();

    buf.writeInt16(1);
    buf.writeInt16(2);
    buf.writeInt16(3);
    buf.writeInt16(-1);
    buf.writeInt16(-2);

    buf.debugPrint();

    expect(1, buf.readInt16());
    expect(2, buf.readInt16());
    expect(3, buf.readInt16());
    expect(-1, buf.readInt16());
    expect(-2, buf.readInt16());

    for (int i = 100; i <= 500; i++) {
      buf.writeInt16(i);
    }

    for (int i = 100; i <= 500; i++) {
      expect(i, buf.readInt16());
    }
  });

  test("read write int32", () {
    ByteBuf buf = ByteBuf.allocator();
    buf.writeInt32(65535);

    expect(0, buf.readIndex);
    expect(4, buf.writeIndex);

    buf.debugPrint();
    expect(65535, buf.readInt32());
  });

  test("read write int", () {
    ByteBuf buf = ByteBuf.allocator();
    buf.writeInt(655357788);

    expect(655357788, buf.readInt());
    buf.debugPrint();

    buf.writeInt(-8);
    expect(-8, buf.readInt());
  });

  test("read write float32", () {
    ByteBuf buf = ByteBuf.allocator();
    buf.writeInt(7);
    buf.writeFloat32(3.14);

    expect(7, buf.readInt());
    var vf = buf.readFloat32();
    expect(true, Utils.floatEqual(vf, 3.14));
    buf.debugPrint();
  });

  test("read write int64", () {
    ByteBuf buf = ByteBuf.allocator();
    buf.writeInt(7);
    buf.writeFloat32(3.14);
    buf.writeInt64(1000);

    expect(7, buf.readInt());
    expect(true, Utils.floatEqual(buf.readFloat32(), 3.14));
    expect(1000, buf.readInt64());

    buf.writeFloat32(3.14157);
    buf.writeInt64(7788);
    expect(true, Utils.floatEqual(buf.readFloat32(), 3.14157));
    expect(7788, buf.readInt64());

    buf.debugPrint();
  });

  test("read write float", () {
    ByteBuf buf = ByteBuf.allocator();
    for (int i = 100; i < 2000; i++) {
      buf.writeFloat(i.toDouble());
    }

    for (int i = 100; i < 2000; i++) {
      expect(true, Utils.floatEqual(buf.readFloat(), i));
    }
  });

  test("read write float64", () {
    ByteBuf buf = ByteBuf.allocator();
    for (int i = 100; i < 2000; i++) {
      buf.writeFloat64(i.toDouble());
    }

    for (int i = 100; i < 2000; i++) {
      expect(true, Utils.floatEqual(buf.readFloat64(), i));
    }

    //buf.debugPrint();
  });

  test("copy bytebuf", () {
    ByteBuf buf = ByteBuf.allocator();
    var data = <int>[1, 2, 3, 4];
    buf.writeUint8List(Uint8List.fromList(data));

    var buf2 = buf.copy();

    expect(0, buf2.readIndex);
    Uint8List list = buf.readAllUint8List();
    for (int i = 0; i < data.length; i++) {
      expect(data[i], list[i]);
    }

    buf.reset();
    expect(0, buf.readIndex);

    buf.writeInt32(101);
    buf.writeInt32(102);

    buf.readInt32();

    ByteBuf buf3 = buf.copy();
    expect(4, buf3.couldReadableSize);
  });

  test("write bytebuf", () {
    ByteBuf buf = ByteBuf.allocator();
    var data = <int>[1, 2, 3, 4];
    buf.writeUint8List(Uint8List.fromList(data));
    expect(4, buf.writeIndex);

    ByteBuf buf2 = ByteBuf.allocator();
    var data2 = <int>[5, 6, 7, 8];
    buf2.writeUint8List(Uint8List.fromList(data2));

    buf.writeByteBuf(buf2);

    expect(8, buf.couldReadableSize);
    buf2.readInt8();
    buf.writeByteBuf(buf2);
    buf.debugPrint();

    expect(11, buf.couldReadableSize);
  });

  test("read bytebuf", () {
    ByteBuf buf = ByteBuf.allocator();

    var data = <int>[1, 2, 3, 4, 5, 6, 7, 8];
    buf.writeUint8List(Uint8List.fromList(data));
    buf.readInt8();

    ByteBuf readBuf = buf.readByteBuf(buf.couldReadableSize);
    readBuf.debugPrint();
    expect(0, readBuf.readIndex);
    Uint8List readBufData = readBuf.readAllUint8List();
    for (int i = 1; i < data.length; i++) {
      expect(data[i], readBufData[i - 1]);
    } //end for
    expect(7, readBuf.readIndex);
  });

  test("test compact", (){
    var data = <int>[1, 2, 3, 4, 5, 6, 7, 8];
    ByteBuf buf = ByteBuf.allocator();
    buf.writeUint8List(Uint8List.fromList(data));
    int originDataLen = buf.limit;
    buf.compact();
    expect(buf.limit, originDataLen);

    buf.readInt8();

    buf.compact();
    buf.debugPrint();
    expect(buf.readIndex, 0);
    expect(buf.writeIndex, 7);


    buf.readInt8();
    buf.readInt8();
    buf.readInt8();
    buf.readInt8();
    buf.readInt8();
    buf.readInt8();
    buf.readInt8();
    buf.compact();

    buf.debugPrint();

    expect(buf.limit, originDataLen - data.length);

    buf.writeInt(100);
    buf.writeInt(200);
    buf.writeInt(300);
    buf.compact();
    buf.debugPrint();
    expect(buf.readIndex, 0);
    expect(buf.writeIndex ,12);

    buf.readInt();
    buf.compact();
    expect(buf.readIndex, 0);
    expect(buf.writeIndex ,8);

    buf.readInt();
    buf.compact();
    buf.debugPrint();
    expect(buf.readIndex, 0);
    expect(buf.writeIndex ,4);

    buf.readInt();
    buf.writeInt64(100);
    buf.readInt64();

    buf.compact();

    buf.writeInt(100);
    buf.readInt();

    buf.debugPrint();
    buf.writeInt8(12);
    buf.readInt8();
    buf.compact();
    buf.debugPrint();
    expect(ByteBuf.initMinSize, buf.limit);
  });

  test("show debug" , (){
    ByteBuf buf = ByteBuf.allocator(size:100);
    for(int i = 0 ; i< 100 ;i++){
      buf.writeInt8(i);
    }
    buf.debugHexPrint(columSize: 16);
  });

  test("read size bytebuf" , (){
    var data = <int>[1, 2, 3, 4, 5, 6, 7, 8];
    ByteBuf originBuf  = ByteBuf.allocator();
    originBuf.writeUint8List(Uint8List.fromList(data));

    originBuf.readInt32();

    ByteBuf buf = originBuf.copyWithSize(3);
    expect(5, buf.readInt8());
    expect(6, buf.readInt8());
    expect(7, buf.readInt8());

    expect(4, originBuf.readIndex);

    originBuf.reset();
    originBuf.writeUint8List(Uint8List.fromList(data));
    originBuf.debugPrint();

    ByteBuf buf2 = originBuf.copyWithSize(100);
    expect(8, buf2.writeIndex);
    buf2.debugPrint();

    expect(0, originBuf.readIndex);
  });
  
  test("read write string" , (){
    ByteBuf buf = ByteBuf.allocator();

    buf.writeString("");
    buf.writeString(null);
    buf.writeString("123456789");
    buf.writeString("你好世界 哈哈哈!");
    buf.writeInt64(1001);

    String? v1 = buf.readString();
    print(v1);
    expect(v1, "");

    String? v2 = buf.readString();
    print(v2);
    expect(v2, null);

    String? v3 = buf.readString();
    print("readString1 : $v3");
    expect(v3, "123456789");
    
    String? v4 = buf.readString();
    print("readString2 : $v4");
    expect(v4, "你好世界 哈哈哈!");
        
    expect(1001, buf.readInt64());
  });
}
