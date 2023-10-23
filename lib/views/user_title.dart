import 'package:dearim/models/contact_model.dart';
import 'package:flutter/material.dart';

import 'head_view.dart';

class UserInfoWidget extends StatelessWidget{
  final ContactModel? contactModel;
  const UserInfoWidget(this.contactModel , {Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32.0,
      height: 32.0,
      child: HeadView(
        contactModel?.avatar??"",
        size: ImageSize.small,
        circle: 32.0,
      ),
    );
  }
}

