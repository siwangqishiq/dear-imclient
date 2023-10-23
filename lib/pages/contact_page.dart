import 'dart:developer';

import 'package:dearim/pages/chat_page.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/views/contact_view.dart';
import 'package:flutter/material.dart';

import '../user/user.dart';
import '../views/user_title.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  List<ContactModel> models = <ContactModel>[];

  VoidCallback? _contactsChangeCallback;
  @override
  void initState() {
    super.initState();
    //requestChatList();
    
    _resetContacts();
    _contactsChangeCallback = (){
      _resetContacts();
    };
    ContactsDataCache.instance.addListener(_contactsChangeCallback!);
  }

  void _resetContacts(){
    models.clear();
    models.addAll(ContactsDataCache.instance.allContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserInfoWidget(User.getCurrentUser()),
      ),
      body: ListView.builder(
        itemCount: models.length,
        itemBuilder: (BuildContext context, int index) {
          ContactModel contactModel = models[index];
          return Column(
            children: [
              ContactView(contactModel, () {
                //跳转传参
                 Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(contactModel)));
              }),
              const Divider(height: 1,color: Colors.grey,)
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    if(_contactsChangeCallback != null){
      ContactsDataCache.instance.removeListener(_contactsChangeCallback!);
    }
    super.dispose();
  }
  
}
