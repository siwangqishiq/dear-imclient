// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class GridItemModel {
  String image = "";
  String name = "";
  GridItemModel(this.image, this.name);
}

class ChatKeyboard extends StatefulWidget {
  late List<GridItemModel> itemModels;
  ChatKeyboard(this.itemModels, {Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  _ChatKeyboardState createState() => _ChatKeyboardState(itemModels);
}

class _ChatKeyboardState extends State<ChatKeyboard> {
  late List<GridItemModel> itemModels;

  _ChatKeyboardState(this.itemModels);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          // mainAxisSpacing: 10.0,
          // crossAxisSpacing: 20.0,
          childAspectRatio: 1.1,
        ),
        itemCount: itemModels.length,
        itemBuilder: (BuildContext context, int index) {
          return GridItem(itemModels[index]);
        },
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  GridItemModel itemModel;
  GridItem(this.itemModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      // height: 60,
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Image.network(
            itemModel.image,
            width: 50,
            height: 50,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            itemModel.name,
            // ignore: prefer_const_constructors
            style: TextStyle(
              color: Colors.blue,
              backgroundColor: Colors.yellow,
            ),
          ),
        ],
      ),
    );
  }
}
