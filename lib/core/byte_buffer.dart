import 'dart:math';
import 'dart:typed_data';

import 'log.dart';
import 'utils.dart';

///
///
///byteBuf 类
///提供二进制方式的读取 写入
///
class ByteBuf {
  static const int initSize = 32;
  static const int initMinSize = 8;

  static const int bigSize = 4 * 1024; //4k 扩容分配策略 阈值

  static const int int8MoveSize = 1; //1字节 8位
  static const int int16MoveSize = 2; //2字节
  static const int int32MoveSize = 4;
  static const int int64MoveSize = 8;

  Uint8List _data = Uint8List(initMinSize);

  int _readIndex = 0;
  int _writeIndex = 0;

  final Endian _endian = Endian.big; //

  factory ByteBuf.allocator({int size = initSize}) {
    ByteBuf buf = ByteBuf(size);
    return buf;
  }

  factory ByteBuf.from(Uint8List data, int readIndex, int writeIndex) {
    final ByteBuf buf = ByteBuf(2);
    buf._data = data;
    buf._readIndex = readIndex;
    buf._writeIndex = writeIndex;
    return buf;
  }

  ByteBuf(int _initSize) {
    if (_initSize < initMinSize) {
      _initSize = initMinSize;
    }

    _data = Uint8List(_initSize);
  }

  int get readIndex => _readIndex;

  int get writeIndex => _writeIndex;

  int get couldReadableSize => _writeIndex - _readIndex;

  Uint8List get data => _data;

  //
  int get limit => _data.length;

  //是否内部还有可读内容
  bool get hasReadContent => couldReadableSize > 0;

  //取值 不移动读写指针
  int getValue(final int index) {
    return _data[index];
  }

  //重置
  void reset() {
    _readIndex = 0;
    _writeIndex = 0;
  }

  void _ensureSize(int addSize) {
    while (_writeIndex + addSize >= _data.length) {
      _expand(addSize);
    } //end while
  }

  //
  //扩大data容量
  //
  void _expand(int needAddSize) {
    int newSize = _findExpandSize(needAddSize);
    Uint8List newData = Uint8List(newSize);
    for (int i = 0; i < _writeIndex; i++) {
      newData[i] = _data[i];
    } //end for i
    _data = newData;
  }

  /// 计算扩容的容量
  /// 目前策略
  ///   < 阈值 扩容  2*n + 1
  ///   >= 阈值 按需分配
  int _findExpandSize(int needAddSize) {
    final int currentSize = _data.length;
    if (currentSize < bigSize) {
      return ((_data.length) << 1) + 1;
    }
    return _data.length + needAddSize + 1;
  }

  //写入一个字节 8位
  void writeInt8(int byteValue) {
    _ensureSize(int8MoveSize);

    _data[_writeIndex] = byteValue;
    _writeIndex += int8MoveSize;
  }

  //读取一个字节
  int readInt8() {
    if (_readIndex + int8MoveSize <= _writeIndex) {
      //读取在合法范围内
      int result = _data[_readIndex];
      _readIndex += int8MoveSize;
      return result;
    }

    LogUtil.errorLog("Error! read out of range");
    return 0;
  }

  //写入字节数组
  void writeUint8List(Uint8List bits, {bool needCheckSize = true}) {
    final int moveSize = bits.lengthInBytes;
    if (needCheckSize) {
      _ensureSize(moveSize);
    }

    for (int i = 0; i < moveSize; i++) {
      _data[_writeIndex + i] = bits[i];
    } //end for i
    _writeIndex += moveSize;
  }

  //写入字符串
  void writeString(String? str){
    if(str == null){
      writeInt32(-1);
      return;
    }else if(str == ""){
      writeInt32(0);
      return;
    }

    var strBytes = Utils.convertStringToUint8List(str);
    final int strLen = strBytes.length;
    writeInt32(strLen);
    
    writeUint8List(strBytes);
  }

  //读取字符串
  String? readString(){
    final int strLen = readInt32();
    if(strLen < 0){
      return null;
    }else if(strLen == 0){
      return "";
    }

    var strBytes = readUint8List(strLen);
    return Utils.convertUint8ListToString(strBytes);
  }

  //读取指定数量的byte为Uint8List
  Uint8List readUint8List(int readSize) {
    if (readSize < 1) {
      LogUtil.errorLog("Error Read Size invalidate.");
      return Uint8List(1);
    }

    if (_readIndex + readSize <= _writeIndex) {
      //读取在合法范围内
      int start = _readIndex;
      _readIndex += readSize;
      return _data.sublist(start, start + readSize);
    }

    LogUtil.errorLog("Error readUint8List! read out of range.");
    return Uint8List(1);
  }

  ByteBuf readUint8ListAsByteBuf(int readSize){
    Uint8List data = readUint8List(readSize);
    ByteBuf buf = ByteBuf.allocator(size: readSize);
    buf.writeUint8List(data);
    return buf;
  }

  //读取所有剩下的数据为Unit8List
  Uint8List readAllUint8List() {
    return readUint8List(couldReadableSize);
  }

  //写入2字节数据
  void writeInt16(int value) {
    _ensureSize(int16MoveSize);

    Uint16List writeData = Uint16List(1);
    writeData.buffer.asByteData().setInt16(0, value, _endian);
    Uint8List u8List = writeData.buffer.asUint8List();
    writeUint8List(u8List, needCheckSize: false);
  }

  //读取2字节数据
  int readInt16() {
    if (_readIndex + int16MoveSize <= _writeIndex) {
      //读取在合法范围内
      var uList = _data.sublist(_readIndex, _readIndex + int16MoveSize);
      int result = uList.buffer.asByteData().getInt16(0, _endian);
      _readIndex += int16MoveSize;
      return result;
    }

    LogUtil.errorLog("Error! read out of range");
    return 0;
  }

  //写入4字节
  void writeInt32(int value) {
    _ensureSize(int32MoveSize);

    Uint32List writeData = Uint32List(1);
    writeData.buffer.asByteData().setInt32(0, value, _endian);
    Uint8List u8List = writeData.buffer.asUint8List();
    writeUint8List(u8List, needCheckSize: false);
  }

  //读取4字节
  int readInt32() {
    if (_readIndex + int32MoveSize <= _writeIndex) {
      //读取在合法范围内
      var uList = _data.sublist(_readIndex, _readIndex + int32MoveSize);
      int result = uList.buffer.asByteData().getInt32(0, _endian);
      _readIndex += int32MoveSize;
      return result;
    }

    LogUtil.errorLog("Error! read out of range");
    return 0;
  }

  void writeInt(int value) {
    writeInt32(value);
  }

  int readInt() {
    return readInt32();
  }

  void writeFloat(double value) {
    writeFloat32(value);
  }

  double readFloat() {
    return readFloat32();
  }

  void writeFloat32(double value) {
    _ensureSize(int32MoveSize);
    Float32List writeData = Float32List(1);
    writeData.buffer.asByteData().setFloat32(0, value, _endian);
    Uint8List u8List = writeData.buffer.asUint8List();
    writeUint8List(u8List, needCheckSize: false);
  }

  double readFloat32() {
    if (_readIndex + int32MoveSize <= _writeIndex) {
      //读取在合法范围内
      Uint8List uList = _data.sublist(_readIndex, _readIndex + int32MoveSize);
      double result = uList.buffer.asByteData().getFloat32(0, _endian);
      _readIndex += int32MoveSize;
      return result;
    }

    LogUtil.errorLog("Error! read out of range");
    return 0;
  }

  //写入8字节
  void writeInt64(int value) {
    _ensureSize(int64MoveSize);

    Uint64List writeData = Uint64List(1);
    writeData.buffer.asByteData().setInt64(0, value, _endian);
    Uint8List u8List = writeData.buffer.asUint8List();
    writeUint8List(u8List, needCheckSize: false);
  }

  //读取8字节
  int readInt64() {
    if (_readIndex + int64MoveSize <= _writeIndex) {
      //读取在合法范围内
      Uint8List uList = _data.sublist(_readIndex, _readIndex + int64MoveSize);
      int result = uList.buffer.asByteData().getInt64(0, _endian);
      _readIndex += int64MoveSize;
      return result;
    }

    LogUtil.errorLog("Error! read out of range");
    return 0;
  }

  //写入64位浮点数
  void writeFloat64(double value) {
    _ensureSize(int64MoveSize);
    Float64List writeData = Float64List(1);
    writeData.buffer.asByteData().setFloat64(0, value, _endian);
    Uint8List u8List = writeData.buffer.asUint8List();
    writeUint8List(u8List, needCheckSize: false);
  }

  //读取64位浮点数
  double readFloat64() {
    if (_readIndex + int64MoveSize <= _writeIndex) {
      //读取在合法范围内
      Uint8List uList = _data.sublist(_readIndex, _readIndex + int64MoveSize);
      double result = uList.buffer.asByteData().getFloat64(0, _endian);
      _readIndex += int64MoveSize;
      return result;
    }

    LogUtil.errorLog("Error! read out of range");
    return 0;
  }

  //拷贝ByteBuf 相同的读写指针状态
  ByteBuf copy() {
    final ByteBuf copyBuf = ByteBuf.allocator();
    copyBuf._data = data.sublist(0);
    copyBuf._readIndex = readIndex;
    copyBuf._writeIndex = writeIndex;
    return copyBuf;
  }

  //拷贝指定字节数量 到 ByteBuf
  ByteBuf copyWithSize(int copySize) {
    if (copySize <= initMinSize) {
      copySize = initMinSize;
    }

    final ByteBuf copyBuf = ByteBuf.allocator(size: copySize);
    Uint8List cpData =
        _data.sublist(_readIndex, min(_readIndex + copySize, writeIndex));
    copyBuf.writeUint8List(cpData);
    return copyBuf;
  }

  //写入ByteBuf
  void writeByteBuf(ByteBuf buf) {
    Uint8List bufUList = buf._data.sublist(buf.readIndex, buf.writeIndex);
    writeUint8List(bufUList);
  }

  ByteBuf readByteBuf(int readSize) {
    if (readSize < 1) {
      LogUtil.errorLog("Error Read Size invalidate.");
      return ByteBuf.allocator(size: initMinSize);
    }

    if (_readIndex + readSize <= _writeIndex) {
      //读取在合法范围内
      int start = _readIndex;
      _readIndex += _writeIndex;
      return ByteBuf.from(_data.sublist(start, start + readSize), 0, readSize);
    }

    LogUtil.errorLog("Error readUint8List! read out of range.");
    return ByteBuf.allocator(size: initMinSize);
  }

  //重新调整buf 舍弃已读过的数据 释放原有数据节约内存使用
  void compact() {
    if (_readIndex <= 0) {
      return;
    }

    int originReadIndex = _readIndex;
    _readIndex = 0;
    _writeIndex -= originReadIndex;
    _data = _data.sublist(originReadIndex);

    if (_data.length < initMinSize) {
      ByteBuf newBuf = ByteBuf.allocator(size: initMinSize);
      newBuf.writeByteBuf(this);
      _deepCopySelf(newBuf);
    }
  }

  void _deepCopySelf(ByteBuf buf) {
    _readIndex = buf.readIndex;
    _writeIndex = buf.writeIndex;
    _data = buf.data;
  }

  void debugPrint() {
    final String str = "[${_data.join(" ")}]";
    LogUtil.log("$str  r = $_readIndex ,w = $_writeIndex");
  }

  void debugHexPrint({int columSize = 32}) {
    String sb = "";
    sb += "rdx = $_readIndex ,wdx = $_writeIndex \n";
    //stdout.write("rdx = $_readIndex ,wdx = $_writeIndex \n");
    for (int i = 0; i < _writeIndex; i++) {
      if (i != 0 && i % columSize == 0) {
        //stdout.write("\n");
        sb += "\n";
      }
      //stdout.write(Utils.intToHex(_data[i]) +" ");
      sb += (Utils.intToHex(_data[i]) + " ");
    }
    //stdout.write("\n" + ("="*columSize));
    sb += ("\n" + ("=" * columSize));
    LogUtil.log(sb);
  }
} //end class
