

import 'dart:ui';

import 'package:flutter/material.dart';

///
/// 桌面端支持的手势操作
///
class SupportDesktopScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => { 
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
  };
}