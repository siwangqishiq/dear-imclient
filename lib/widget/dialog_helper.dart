//被踢出事件回调
import 'package:flutter/material.dart';

typedef OnDialogItemClick = Function(BuildContext context);

///
/// List对话框 显示内容 及 点击操作
///
class DialogItemAction{
  int id = -1;
  late String name;
  OnDialogItemClick? onClickAction;

  DialogItemAction(this.name, {this.onClickAction});
}

///
/// 对话框相关辅助类
///
class DialogHelper{

  ///
  /// 显示操作对话框
  ///
  static void displayItemListDialog(BuildContext context , List<DialogItemAction>? itemActions){
    if(itemActions == null || itemActions.isEmpty){
      return;
    }

    showDialog(
      context: context, 
      builder: (BuildContext ctx){
        return _createItemListDialog(ctx , itemActions);
      }
    ); 
  }

  static Dialog _createItemListDialog(BuildContext ctx , List<DialogItemAction> itemActions){
    List<Widget> list = [];
    for(DialogItemAction item in itemActions){
      list.add(_buildListDialogItemWidget(ctx ,item));
    }
    
    return Dialog(
      child: ListView(
        shrinkWrap: true, 
        children: list,
      )
    );
  }

  // 创建对话框菜单
  static Widget _buildListDialogItemWidget(BuildContext ctx ,DialogItemAction itemAction){
    return Column(
      children: [
        InkWell(
          onTap: () async {
            //先关闭对话框  再做菜单逻辑
            Navigator.of(ctx).pop();
            
            await itemAction.onClickAction?.call(ctx);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(itemAction.name , style: const TextStyle(fontSize: 16 , color: Colors.black)),
            ),
          ),
        ),
        const Divider(height: 0.5,color: Colors.black12)
      ],
    );
  }

  ///
  /// 确认 取消 对话框
  /// 
  static void showAlertDialog(String title, String content, BuildContext context,
      VoidCallback? sureCallback, VoidCallback? cancelCallback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
          ),
          content: Text(content),
          actions: <Widget>[
            Container(
              decoration:const BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.white, width: 1.0),
                      top: BorderSide(color: Colors.white, width: 1.0))),
              child: TextButton(
                child: const Text("确定"),
                onPressed: () {
                  Navigator.pop(context);
                  if (sureCallback != null) {
                    sureCallback();
                  }
                },
              ),
            ),
            Container(
              decoration:const BoxDecoration(
                  border:
                      Border(top: BorderSide(color: Colors.white, width: 1.0))),
              child: TextButton(
                child: const Text("取消"),
                onPressed: () {
                  Navigator.pop(context);
                  if (cancelCallback != null) {
                    cancelCallback();
                  }
                },
              ),
            )
          ],
        );
      },
    );
  }
}