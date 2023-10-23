// ignore_for_file: file_names, unnecessary_this, no_logic_in_create_state

import 'package:flutter/material.dart';

enum RedPointStyle {
  number, // 数字
  redPoint // 红点
}

// ignore: must_be_immutable
class RedPoint extends StatefulWidget {
  int number;
  RedPointStyle pointStyle;
  Widget child;
  double height;
  double width;
  RedPoint({
    Key? key,
    required this.pointStyle,
    required this.number,
    required this.child,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _RedPointState createState() => _RedPointState(
      this.child, this.pointStyle, this.number, this.width, this.height);
}

class _RedPointState extends State<RedPoint> {
  Widget child;
  int number;
  double height;
  double width;
  RedPointStyle pointStyle = RedPointStyle.number;
  _RedPointState(
      this.child, this.pointStyle, this.number, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    Widget redpoint;
    double space = 5;
    double cornerRadius = 10;
    switch (this.pointStyle) {
      case RedPointStyle.number:
        {
          redpoint = ClipRRect(
              borderRadius: BorderRadius.circular(cornerRadius),
              child: Container(
                color: Colors.red,
                padding: EdgeInsets.fromLTRB(space, 2, space, 2),
                child: Text(
                  this.number.toString(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            );
        }
        break;
      case RedPointStyle.redPoint:
        {
          redpoint = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Text(this.number.toString()),
          );
        }

        break;
      default:
        {
          redpoint = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Text(this.number.toString()),
          );
        }
    }
    
    var _children = [
      Align(
        child: child,
        alignment: Alignment.center,
      )
    ];

    if(number > 0){
      _children.add(Align(child: redpoint,alignment: Alignment.topRight,));
    }

    return SizedBox(
      // color: Colors.blue,
      width: this.width,
      height: this.height,
      child: Stack(
        alignment: Alignment.center,
        children: _children,
      ),
    );
  }
}
