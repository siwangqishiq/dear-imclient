

import 'package:dearim/models/contact_model.dart';
import 'package:flutter/material.dart';

import '../views/head_view.dart';

class AvChatUserInfoWidget extends StatelessWidget{
  final ContactModel remoteModel;
  const AvChatUserInfoWidget(this.remoteModel, {Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: MediaQuery.of(context).size.width),
        const Divider(height: 40.0),
        HeadView(remoteModel.avatar,
            size: ImageSize.origin, width: 90.0, height: 90.0, circle: 64.0),
        const Divider(height: 8.0),
        Text(
          remoteModel.name,
          style: const TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        const Divider(height: 8.0),
      ],
    );
  }

}
