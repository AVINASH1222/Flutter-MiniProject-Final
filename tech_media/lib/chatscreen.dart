import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chathome.dart';

class chatScreen extends StatefulWidget {
  userprofile user;
  chatScreen(this.user);
  @override
  _chatScreenState createState() => _chatScreenState(user);
}

class _chatScreenState extends State<chatScreen> {
  @override
  void initState() {
    namecopy();
    super.initState();
  }

  final control = TextEditingController();
  List<String> combinename = [];
  FirebaseFirestore _store = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  userprofile user;
  bool showspinner = true;
  String message;
  _chatScreenState(this.user);
  String namejoin, finalname = "";

  namecopy() async {
    if (finalname.length == 0) {
      final doc =
          await _store.collection("users").doc(_auth.currentUser.email).get();
      setState(() {
        namejoin =
            doc.data()['first name'] + doc.data()['last name'] + user.name;
        combinename = namejoin.split('');
        combinename.sort();
        for (int i = 0; i < combinename.length; i++) {
          finalname = finalname + combinename[i];
        }
        return finalname;
      });
      setState(() {
        showspinner = false;
      });
    }
  }

  name() async {
    if (finalname.length == 0) {
      final doc =
          await _store.collection("users").doc(_auth.currentUser.email).get();
      setState(() {
        namejoin =
            doc.data()['first name'] + doc.data()['last name'] + user.name;
        combinename = namejoin.split('');
        combinename.sort();
        for (int i = 0; i < combinename.length; i++) {
          finalname = finalname + combinename[i];
        }
        print(finalname);
        return finalname;
      });
    }
    print(message);
    await _store
        .collection('chats')
        .doc(finalname)
        .collection('messages')
        .doc('${DateTime.now()}')
        .set({
      "sender": _auth.currentUser.email,
      "message": message,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // homeKey.currentState.setState(() {
            //   homeKey.currentState.selectedIndex = 3;
            // });
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: user.dp == null
                    ? 'https://img.freepik.com/free-photo/abstract-surface-textures-white-concrete-stone-wall_74190-8184.jpg?size=626&ext=jpg'
                    : user.dp,
                width: 35,
                height: 35,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              user.name == null ? 'Username' : user.name,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: finalname.length != 0
                    ? _store
                        .collection('chats')
                        .doc(finalname)
                        .collection('messages')
                        .snapshots()
                    : null,
                // ignore: missing_return
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  if (snapshot.hasData) {
                    final messagereceived = snapshot.data.documents.reversed;
                    List<MessageBubble> messagewidget = [];
                    for (var msg1 in messagereceived) {
                      final msg2 = MessageBubble(
                        text: msg1.data()['message'],
                        sender: msg1.data()['sender'],
                        isme: msg1.data()['sender'] == _auth.currentUser.email,
                      );
                      messagewidget.add(msg2);
                    }
                    return Expanded(
                      flex: finalname.length != 0 ? 7 : 4,
                      child: ListView(
                        reverse: true,
                        padding: EdgeInsets.only(top: 15),
                        children: messagewidget,
                      ),
                    );
                  }
                }),
            finalname.length != 0
                ? Container(
                    child: Expanded(
                        flex: finalname.length != 0 ? 1 : 1,
                        child: TextField(
                          controller: control,
                          onChanged: (value) {
                            //Do something with the user input.
                            message = value;
                          },
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              hintText: 'Type your message here...',
                              border: InputBorder.none,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  control.clear();
                                  name();
                                },
                                icon: Icon(Icons.send),
                              )),
                        )),
                  )
                : Container(
                    child: Center(
                      child: Text("No messages"),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

class userprofile {
  final String name;
  final String dp;

  const userprofile({
    @required this.name,
    @required this.dp,
  });
}

class MessageBubble extends StatelessWidget {
  MessageBubble({
    this.sender,
    this.text,
    this.isme,
  });
  final String sender;
  final bool isme;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment:
              isme ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Material(
                elevation: 5.0,
                borderRadius: isme
                    ? BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0))
                    : BorderRadius.only(
                        topRight: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0)),
                color: isme ? Colors.white : Color(0xff3257A6),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 15.0,
                        color: isme ? Colors.black : Colors.white),
                  ),
                )),
          ],
        ));
  }
}
