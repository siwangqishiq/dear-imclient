import 'package:date_format/date_format.dart';

class TimerUtils {
  static String getMessageFormatTime(int timestamp , {bool detailShow = true}) {
    var todayDate = DateTime.now();
    var todayTime = DateTime(todayDate.year , todayDate.month , todayDate.day ,0 ,0 ,0,0 ,0);
    var yesterDayTime = DateTime(todayDate.year , todayDate.month , todayDate.day -1 ,0 ,0 ,0,0 ,0);
    var dayBeforeYesterTime = DateTime(todayDate.year , todayDate.month , todayDate.day -2 ,0 ,0 ,0,0 ,0);

    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    if(timestamp >= todayTime.millisecondsSinceEpoch){//今天
      return formatDate(time, ["HH", ":", "nn"]);
    }else if(timestamp < todayTime.millisecondsSinceEpoch && timestamp >= yesterDayTime.millisecondsSinceEpoch){//昨天
      return formatDate(time, ["昨天" , "HH", ":", "nn"]);
    }else if(timestamp < yesterDayTime.millisecondsSinceEpoch && timestamp >= dayBeforeYesterTime.millisecondsSinceEpoch){//前天
      return formatDate(time, ["前天" , "HH", ":", "nn"]);
    }

    if(detailShow){
      return formatDate(time, ["yyyy", "年", "mm", "月", "dd", "日", "HH", ":", "nn"]);
    }

    return formatDate(time, ["yyyy", "年", "mm", "月", "dd", "日"]);
  }

  static int getCurrentTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
