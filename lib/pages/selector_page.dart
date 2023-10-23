import 'package:dearim/core/log.dart';
import 'package:flutter/material.dart';

import '../core/imcore.dart';
import '../models/contact_model.dart';
import '../user/contacts.dart';
import '../views/contact_view.dart';

///
/// 联系人选择器
///
class SelectorWidget extends StatefulWidget{
  const SelectorWidget({Key? key}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() => SelectorState();
}

class SelectorState extends State<SelectorWidget>{
  List<ContactSelectWrap> contactList = <ContactSelectWrap>[];

  @override
  void initState() {
    super.initState();
    initContactListData();
  }

  void initContactListData(){
    contactList.clear();
    var list = ContactsDataCache.instance.allContacts;
    int uid = IMClient.getInstance().uid;
    for(ContactModel item in list){
      if(uid == item.userId){
        continue;
      }
      contactList.add(ContactSelectWrap(item));
    }//end for each
  }

  String _selectedContacts(){
    String displayNames = "";
    bool isFirst = true;
    for(ContactSelectWrap item in contactList){
      if(item.selected){
        if(isFirst){
          displayNames += item.contact?.name??"";
        }else{
          displayNames += ",${item.contact?.name??""}";
        }
        isFirst = false;
      }
    }//end for each
    return displayNames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "选择人员",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (BuildContext context, int index) {
                ContactModel contactModel = contactList[index].contact??ContactModel("",0);
                return Column(
                  children: [
                    CheckboxMenuButton(
                      value: contactList[index].selected,
                      onChanged: (bool? value) {
                        setState(() {
                          contactList[index].selected = value??false;
                        });
                      },
                      child: ContactView(contactModel, null),
                    ),
                    const Divider(height: 1,color: Colors.grey,)
                  ],
                );
              },
            ),
          ),
          Container(
            height: 64.0,
            color: Colors.white,
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(_selectedContacts())
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed:_confirmButtonCallback(), 
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey
                  ),
                  child: const Text("确定"),
                ),
                const SizedBox(width: 16),
              ],
            ),
          )
        ],
      )
    );
  }
  
  VoidCallback? _confirmButtonCallback(){
    int selectedCount = 0; 
    for(ContactSelectWrap item in contactList){
      if(item.selected){
        selectedCount++;
      }
    }//end for each
    return selectedCount == 0?null:()=>_selectContactAsResult();
  }

  ///
  /// 选择完联系人 返回
  ///
  void _selectContactAsResult(){
    LogUtil.log("选择联系人返回");
    var selectedIds = <int>[];
    for(ContactSelectWrap item in contactList){
      if(item.selected && item.contact?.userId != null){
        selectedIds.add(item.contact?.userId??-1);
      }
    }//end for each
    LogUtil.log("selected contacts ${selectedIds.length}");
    
    Navigator.of(context).pop(selectedIds);
  }
}

class ContactSelectWrap{
  bool selected = false;
  ContactModel? contact;
  ContactSelectWrap(this.contact , {this.selected = false});
}
