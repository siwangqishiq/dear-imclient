// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:typed_data';

import 'package:dearim/core/estore/estore.dart';
import 'package:dearim/core/log.dart';

import '../byte_buffer.dart';

///
/// 存储表
///
class StoreTable {
  late String name;

  late String path;

  late File tableFile;

  static const int STATE_NORMAL = 0;//数据状态 正常
  static const int STATE_DELETE = -1;//数据状态 删除


  StoreTable(this.name, this.path){
    tableFile = File(path);
    if(!tableFile.existsSync()){
      LogUtil.log("创建文件 : ${tableFile.absolute.path}");
      tableFile.createSync();
    }
  }
  
  int dataHeadSize(){
    return 4 + 1;
  }

  int save(Codec codec) {
    ByteBuf buf = ByteBuf.allocator();
    ByteBuf contentByteBuf = codec.encode();

    int contentSize = contentByteBuf.couldReadableSize;
    
    int dataSize = dataHeadSize() + contentSize;
    buf.writeInt32(dataSize);
    buf.writeInt8(STATE_NORMAL);
    buf.writeByteBuf(contentByteBuf);

    RandomAccessFile randomFile = tableFile.openSync(mode:FileMode.append);
    randomFile.writeFromSync(buf.readAllUint8List());
    randomFile.closeSync();
    return 0;
  }

  List<dynamic> query(Codec codec){
    Uint8List rawTableData = tableFile.readAsBytesSync();
    ByteBuf buf = ByteBuf.allocator(size:rawTableData.length + 2);
    buf.writeUint8List(rawTableData);

    List<dynamic> result = [];
    while(buf.hasReadContent){
      int dataSize = buf.readInt32();
      int state = buf.readInt8();
      int itemSize = dataSize - dataHeadSize();
      
      ByteBuf itemDataBuf = buf.readUint8ListAsByteBuf(itemSize);
      var item = codec.decode(itemDataBuf);

      if(state ==  STATE_DELETE){//数据已被删除
        continue;
      }      
      result.add(item);
    }//end while
    return result;
  }
}//end class
