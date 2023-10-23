// ignore_for_file: prefer_const_constructors_in_immutables

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EmojiPanView extends StatefulWidget {
  EmojiPanView({Key? key}) : super(key: key);

  @override
  _EmojiPanViewState createState() => _EmojiPanViewState();
}

class _EmojiPanViewState extends State<EmojiPanView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
        ),
        itemCount: 111,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              log("$index msg");
            },
            child: Image.asset(
              "assets/emoji/${index + 1}.gif",
              width: 40,
              height: 40,
            ),
          );
        },
      ),
    );
  }
}
