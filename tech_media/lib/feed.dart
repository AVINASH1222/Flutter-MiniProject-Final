import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tech_media/post.dart';
import 'package:tech_media/postdesign.dart';
import 'package:tech_media/postvideodesign.dart';

// ignore: camel_case_types
FirebaseFirestore _store = FirebaseFirestore.instance;
FirebaseAuth _auth = FirebaseAuth.instance;

bool showprogress = true;

GlobalKey<newsfeedState> feedstate = GlobalKey<newsfeedState>();

class newsfeed extends StatefulWidget {
  newsfeed() : super(key: feedstate);
  @override
  newsfeedState createState() => newsfeedState();
}

// ignore: camel_case_types
TextEditingController uname = TextEditingController();
TextEditingController udp = TextEditingController();

class newsfeedState extends State<newsfeed> {
  List<Post> posts = [];
  Future<List<Post>> retreiveimage() async {
    await _store.collection("posts").get().then((value) {
      value.docs.forEach((element) {
        _store
            .collection("users")
            .doc(element.data()["email"])
            .get()
            .then((val) {
          FirebaseFirestore.instance
              .collection('posts')
              .doc(element.data()["email"] +
                  " " +
                  element.data()["product name"])
              .collection('likes')
              .doc(_auth.currentUser.email)
              .get()
              .then((value) {
            setState(() {
              uname.text = val.data()["first name"];
              udp.text = val.data()["dp"];
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
                udp: udp.text,
                action: value.data()['action'],
              );
              posts.add(allpost);
            });
          });
        });
      });
    });
    setState(() {
      showprogress = false;
    });
    return posts;
  }

  @override
  void initState() {
    if (posts.isNotEmpty) {
      posts.clear();
    }
    retreiveimage();
    super.initState();
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
                    SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final Post post = posts[index];
                        
                        return (post.type=="video")?postvideodesign(post, "feed"):postdesign(post, "feed");
                      },
                      childCount: posts.length,
                    )),
                  ],
                ),
        ));
  }
}
