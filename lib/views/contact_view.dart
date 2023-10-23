// ignore_for_file: no_logic_in_create_state

import 'package:dearim/models/contact_model.dart';
import 'package:dearim/pages/explorer_image.dart';
import 'package:dearim/views/head_view.dart';
import 'package:dearim/views/red_point.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ContactView extends StatefulWidget {
  ContactModel model;
  VoidCallback? onPress;
  ContactView(this.model, this.onPress, {Key? key}) : super(key: key);

  @override
  _ContactViewState createState() => _ContactViewState(model, onPress);
}

class _ContactViewState extends State<ContactView> {
  ContactModel model;
  VoidCallback? onPress;
  double imageWidth = 50;
  double leftSpace = 16;
  double rightSpace = 16;
  double space = 8;

  _ContactViewState(this.model, this.onPress);

  @override
  Widget build(BuildContext context) {
    String? imageURL;
    if (model.avatar.isNotEmpty) {
      imageURL = model.avatar;
    }
    //LogUtil.log("contact ${model.name}  $imageURL");
    
    return InkWell(
      onTap: onPress,
      child: SizedBox(
        child: Column(
          children: [
            SizedBox(
              height: space,
            ),
            Row(
              children: [
                SizedBox(width: leftSpace),
                GestureDetector(
                  onTap: ()=>_explorerHeadView(imageURL),
                  child: Hero(
                    tag: imageURL??"",
                    child: RedPoint(
                      width: imageWidth + 10,
                      height: imageWidth + 10,
                      child: HeadView(
                        imageURL,
                        width: imageWidth,
                        height: imageWidth, 
                        size: ImageSize.small,
                        circle: 16,
                      ),
                      number: 0,
                      pointStyle: RedPointStyle.number,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Text(
                      model.name,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(model.message),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _explorerHeadView(String? imageUrl){
    if(imageUrl == null){
      return;
    }
    
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (context) => ExplorerImagePage(imageUrl))
    // );
                    
    Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,Animation<double> secondaryAnimation) {
          return ExplorerImagePage(imageUrl , heroId: imageUrl);
        },
      ),
    );
  }
}
