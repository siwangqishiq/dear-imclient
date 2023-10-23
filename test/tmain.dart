import 'package:dearim/core/log.dart';
import 'package:uuid/uuid.dart';

void main() {
  //print("Hello 你好 世界");

  // ByteBuf buf = ByteBuf.allocator(100);
  // print("buffer size = ${buf.data?.length}");

  // print(Endian.host == Endian.little);

  // Uint8List bits = Uint8List.fromList([7, 0, 0, 0]);
  // int value = bits.buffer.asInt32List()[0];
  // print("value = $value");

  //Uint8List data = Uint8List(7);
  //print(data.length);

  //List<Uint8> data = <Uint8>[];

  // int? s = 11;
  // // s = null;
  // int b = s??22;
  // print("b = $b");

  const Uuid uuid = Uuid();

  for (int i = 0; i < 100; i++) {
    LogUtil.log(uuid.v1());
  }
}
