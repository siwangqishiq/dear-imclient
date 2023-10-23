import 'package:dearim/config.dart';

enum NetworkEnvironment {
  online,
  daily,
}

class RequestManager {
  NetworkEnvironment networkenv = NetworkEnvironment.daily;
  String _hostName = "";
  RequestManager._privateConstructor();

  static final RequestManager _instance = RequestManager._privateConstructor();

  factory RequestManager() {

    // _instance.networkenv = NetworkEnvironment.daily;
    // _instance._hostName = "http://192.168.31.230:9090/"; // mac
    // _instance._hostName = "http://192.168.31.37:9090/"; // windows
    _instance._hostName = "http://$HOST:9090/";
    // _instance._hostName = "http://101.34.247.16:9090/";//online
    
    return _instance;
  }

  String hostName() {
    return _hostName;
  }
}
