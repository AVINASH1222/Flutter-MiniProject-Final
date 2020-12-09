import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'chatscreen.dart';
import 'home.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class chatHome extends StatefulWidget {
  @override
  _chatHomeState createState() => _chatHomeState();
}

class _chatHomeState extends State<chatHome> {
  FirebaseFirestore _store = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool showSpinner = true;
  List<userprofile> users = [];
  @override
  void initState() {
    if (users.length == 0) {
      getusers();
    } else {
      setState(() {
        showSpinner = false;
      });
    }
    super.initState();
  }

  getusers() async {
    try {
      await _store.collection("users").get().then((value) {
        value.docs.forEach((element) {
          setState(() {
            String fullname =
                element.data()['first name'] + element.data()['last name'];
            userprofile user =
                new userprofile(name: fullname, dp: element.data()["dp"]);
            if (element.id != _auth.currentUser.email) {
              users.add(user);
            }
          });
        });
      });

      setState(() {
        showSpinner = false;
      });
    } catch (e) {
      print(e);
    }
  }

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      transform: Matrix4.translationValues(xOffset, yOffset, 0)
        ..scale(scaleFactor)
        ..rotateY(isDrawerOpen ? -0.5 : 0),
      duration: Duration(milliseconds: 250),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal[800],
          leading: isDrawerOpen
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      xOffset = 0;
                      yOffset = 0;
                      scaleFactor = 1;
                      isDrawerOpen = false;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.menu),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      xOffset = 150;
                      yOffset = 43;
                      scaleFactor = 0.85;
                      isDrawerOpen = true;
                    });
                  }),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: ModalProgressHUD(
              inAsyncCall: showSpinner,
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, left: 15.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Messages",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: users.length,
                        itemBuilder: (context, i) {
                          return Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: CachedNetworkImage(
                                              imageUrl: users[i].dp == null
                                                  ? 'https://img.freepik.com/free-photo/abstract-surface-textures-white-concrete-stone-wall_74190-8184.jpg?size=626&ext=jpg'
                                                  : users[i].dp,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            users[i].name == null
                                                ? 'Username'
                                                : users[i].name,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                          iconSize: 18,
                                          icon: Icon(
                                            Icons.message_outlined,
                                            color: Color(0xff3257A6),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        chatScreen(users[i])));
                                            //_onAlertWithCustomContentPressed(context);
                                          })
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
