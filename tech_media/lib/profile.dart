import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tech_media/post.dart';
import 'package:tech_media/postdesign.dart';
import 'package:tech_media/postvideodesign.dart';

import 'edit profile.dart';

// ignore: camel_case_types
FirebaseFirestore _store = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;

bool showprogress = true;

class profile extends StatefulWidget {
  profile() : super(key: profileKey);
  @override
  profileState createState() => profileState();
}

GlobalKey<profileState> profileKey = GlobalKey<profileState>();
// ignore: camel_case_types
TextEditingController uname = TextEditingController();
TextEditingController udp = TextEditingController();

class profileState extends State<profile> {
  String dp, name;
  int tlikes = 0, tdislikes = 0;
  List<Post> posts = [];
  Future<List<Post>> retreiveimage() async {
    await _store
        .collection("users")
        .doc(_auth.currentUser.email)
        .get()
        .then((value) {
      uname.text = value["first name"];
      udp.text = value["dp"];
    });
    await _store
        .collection("users")
        .doc(_auth.currentUser.email)
        .collection("posts")
        .get()
        .then((value) {
      value.docs.forEach((element) {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(element.data()["email"] + " " + element.data()["product name"])
            .collection('likes')
            .doc(_auth.currentUser.email)
            .get()
            .then((values) {
          setState(() {
            Post allpost = new Post(
                email: element.data()["email"],
                productname: element.data()["product name"],
                caption: element.data()["content"],
                imageUrl: element.data()["multimedia"],
                comments: element.data()["comments"],
                like: element.data()["like"],
                dislike: element.data()["dislike"],
                document_name: element.data()["email"] +
                    " " +
                    element.data()["product name"],
                uname: uname.text,
                type: element.data()["type"],
                action: values.data()['action'],
                udp: udp.text);

            posts.add(allpost);
          });
        });
      });
    });
    setState(() {
      showprogress = false;
    });
    return posts;
  }

  retrievename() async {
    await _store
        .collection('users')
        .doc(_auth.currentUser.email)
        .get()
        .then((value) {
      setState(() {
        dp = value.data()['dp'];
        name = value.data()['first name'] + " " + value.data()['last name'];
      });
    });
  }

  @override
  void initState() {
    retrievename();
    if (posts.length > 0) {
      posts.clear();
    }
    retreiveimage();
    super.initState();
  }

  void clearlist() {
    setState(() {
      posts.clear();
    });
  }

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;
  @override
  Widget build(BuildContext cx) {
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
          body: showprogress
              ? Center(
                  child: LoadingBouncingGrid.circle(
                    size: 70,
                    backgroundColor: Colors.blueAccent,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      dp == null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: Image.asset(
                                                "assets/images/profile.png",
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ))
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              child: CachedNetworkImage(
                                                imageUrl: dp,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                      Column(
                                        children: [
                                          Text(
                                            "${posts.length}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                          ),
                                          Text("Posts")
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            tlikes.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                          ),
                                          Text("Total Likes")
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            tdislikes.toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                          ),
                                          Text("Total Dislikes")
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        name == null ? " " : name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  RaisedButton(
                                      color:
                                          Colors.teal[800], //Color(0xff3257A6),
                                      child: Text(
                                        "Edit Profile",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          edit_profile()));
                                        });
                                      })
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Divider(
                              thickness: 0.3,
                              color: Colors.grey,
                              height: 0.4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final Post post = posts[index];
                        return postdesign(post, "profile");
                      },
                      childCount: posts.length,
                    )),
                  ],
                ),
        ));
  }
}
