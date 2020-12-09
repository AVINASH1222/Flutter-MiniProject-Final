import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'post.dart';
import 'package:cached_network_image/cached_network_image.dart';

String commentstring;

class comments extends StatefulWidget {
  Post post;
  comments(this.post);
  @override
  _commentsState createState() => _commentsState(post);
}

class _commentsState extends State<comments> {
  Post post;
  List<commentClass> commentsClass = [];
  bool showspinner = true;
  Users users;
  Users usersRetrieved;

  TextEditingController commentRetrieved = new TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _store = FirebaseFirestore.instance;
  _commentsState(this.post);
  var email_curr;
  var pro_name;
  void initState() {
    if (commentsClass.length == 0) {
      retrievename();
    } else {
      setState(() {
        showspinner = false;
      });
    }
    super.initState();
  }

  Future<void> retrievename() async {
    try {
      await _store
          .collection("posts")
          .doc('${post.email} ${post.productname}')
          .collection("comments")
          .get()
          .then((value) {
        setState(() {
          value.docs.forEach((element) {
            commentRetrieved.text = element.data()['comment'];
            usersRetrieved = Users(
                name: element.data()['name'], imageUrl: element.data()['dp']);
            commentClass c1 = commentClass(
                user1: usersRetrieved, comment: element.data()['comment']);
            commentsClass.add(c1);
          });
        });
      });

      setState(() {
        showspinner = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> upload_post() {
    try {
      setState(() {
        showspinner = true;
      });
      setState(() async {
        await _store
            .collection("users")
            .doc(_auth.currentUser.email)
            .get()
            .then((value) {
          users = new Users(name: value["first name"], imageUrl: value["dp"]);
        });
        await _store
            .collection("posts")
            .doc('${post.email} ${post.productname}')
            .collection("comments")
            .doc('${_auth.currentUser.email} ${DateTime.now()}')
            .set({
          "name": users.name,
          "dp": users.imageUrl,
          "comment": commentstring.toString(),
        });
        await _store
            .collection("users")
            .doc(post.email)
            .collection('posts')
            .doc(post.productname)
            .collection('comments')
            .doc('${_auth.currentUser.email} ${DateTime.now()}')
            .set({
          "name": users.name,
          "dp": users.imageUrl,
          "comment": commentstring.toString(),
        });
        setState(() {
          showspinner = false;
          commentsClass.clear();
          retrievename();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Added Floating Action Button
      floatingActionButton: FloatingActionButton(
        //On pressed BottonSheet will  pops up
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        child: Container(
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              )),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                autofocus: true,
                                textAlign: TextAlign.center,
                                onChanged: (val) {
                                  commentstring = val;
                                },
                              ),
                              RaisedButton(
                                color: Colors.teal,
                                onPressed: () {
                                  //By clicking add comment upload post function will be called which helps to post ur comment
                                  Navigator.pop(context);
                                  upload_post();
                                },
                                child: Text(
                                  "Add comment",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
        },
        tooltip: "Add Comment",
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      //Appbar is added Below
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          color: Colors.white,
          icon: Icon(Icons.arrow_back_sharp),
        ),
        title: Text('Comments'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showspinner,
        child: Container(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  // Below Row is used to display the author's name ,dp and caption(post's author)
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: post.udp,
                          width: 35,
                          height: 35,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        post.uname,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(child: Text(post.caption)),
                      SizedBox(
                        height: 3,
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 12,
                    thickness: 0.6,
                  ),
                  //we used Listview Builder to iterate over the list
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: commentsClass.length,
                        itemBuilder: (context, i) {
                          //display comment will makes UI for the comment
                          return displayComment(
                            commentsClass: commentsClass,
                            i: i,
                          );
                        }),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class displayComment extends StatelessWidget {
  const displayComment({
    Key key,
    @required this.commentsClass,
    @required this.i,
  }) : super(key: key);

  final List<commentClass> commentsClass;
  final int i;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: commentsClass[i].user1.imageUrl == null
                    ? 'https://img.freepik.com/free-photo/abstract-surface-textures-white-concrete-stone-wall_74190-8184.jpg?size=626&ext=jpg'
                    : commentsClass[i].user1.imageUrl,
                width: 35,
                height: 35,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              commentsClass[i].user1.name == null
                  ? 'Username'
                  : commentsClass[i].user1.name,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                  commentsClass[i].comment == null
                      ? "Username"
                      : commentsClass[i].comment,
                  style: TextStyle(
                    color: Colors.black,
                  )),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}

class Users {
  final String name;
  final String imageUrl;

  const Users({
    @required this.name,
    @required this.imageUrl,
  });
}

class commentClass {
  final Users user1;
  final String comment;
  const commentClass({
    @required this.user1,
    @required this.comment,
  });
}
