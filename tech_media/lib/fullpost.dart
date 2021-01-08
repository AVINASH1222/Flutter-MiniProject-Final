import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tech_media/comments.dart';
import 'package:tech_media/main.dart';
import 'package:tech_media/widgets/text.dart';
import 'package:video_player/video_player.dart';
import 'post.dart';
import 'widgets/text.dart';

// ignore: camel_case_types
class fullPost extends StatefulWidget {
  final Post post;
  fullPost(this.post);
  @override
  _fullPostState createState() => _fullPostState(post);
}

// ignore: camel_case_types
TextEditingController uname = TextEditingController();
TextEditingController uimage = TextEditingController();
int plikes;
int pdislikes;
var likes = 0;
var dislikes = 0;

// ignore: camel_case_types
class _fullPostState extends State<fullPost> {
  final Post post;
  VideoPlayerController controller;
  _fullPostState(this.post);
  @override
  void initState(){
    super.initState();
    setState(() {
      if(post.type=="video")
      {
        controller = VideoPlayerController.network(post.imageUrl);
        controller.initialize();
        controller.setLooping(true);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 5.0),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                first(post),
                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  child: Text(post.caption),
                ),
                post.imageUrl != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: (post.type=="image")?Image(
                          image: NetworkImage(post.imageUrl),
                        ):Container(
                           height: MediaQuery.of(context).size.height / 1.5,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: AspectRatio(
                              aspectRatio: 1/1,
                              child: GestureDetector(
                                onTap: (){
                                  if(controller.value.isPlaying){
                                    controller.pause();
                                  }
                                  else{
                                    controller.play();
                                  }
                                },
                                child: VideoPlayer(controller),
                              ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  child: properties(post),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class first extends StatelessWidget {
  final Post post;
  first(this.post);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: post.imageUrl.length == 0
                        ? AssetImage('assets/icons/profile.png')
                        : NetworkImage(post.udp))),
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.uname,
            ),
          ],
        )
      ],
    );
  }
}

//
// ignore: camel_case_types, must_be_immutable
class properties extends StatefulWidget {
  Post post;
  properties(this.post);
  @override
  _propertiesState createState() => _propertiesState(post);
}

// ignore: camel_case_types
class _propertiesState extends State<properties> {
  Post post;
  _propertiesState(this.post);
  double _rating_star_new;
  double _rating_star_old;
  double _rating_count_old;
  double _rating_user_old;
  bool _getDone = false;
  bool usercheck = false;
  @override
  Widget build(BuildContext context) {
    final popup = BeautifulPopup(
      context: context,
      template: TemplateBlueRocket,
    );
    _ratingBar_new(double start, bool readonly) {
      return SmoothStarRating(
          allowHalfRating: true,
          onRated: (v) {
            _rating_star_new = v;
          },
          starCount: 5,
          rating: start,
          size: 35.0,
          isReadOnly: readonly,
          color: Colors.blue,
          borderColor: Colors.black,
          spacing: 0.0);
    }

    _ratingBar_old(double start, bool readonly) {
      return SmoothStarRating(
          allowHalfRating: true,
          starCount: 5,
          rating: start,
          size: 35.0,
          isReadOnly: readonly,
          color: Colors.blue,
          borderColor: Colors.black,
          spacing: 0.0);
    }

    double avg_rating = 0;
    build_ratingContent() {
      setState(() {
        if (_rating_star_old == null) {
          _rating_star_old = 0.0;
        }
        if (_rating_count_old == null) {
          _rating_count_old = 0.0;
        }
        avg_rating = _rating_star_old / _rating_count_old;
      });
      return Container(
        child: Column(
          children: [
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'rate the product',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            usercheck
                ? Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('already rated!'),
                    ),
                  )
                : _ratingBar_new(0, usercheck),
            Divider(
              thickness: 3.0,
              color: Colors.blue[100],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Average rating for this product',
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            _ratingBar_old(_rating_star_old == 0 ? 0 : avg_rating, true),
            Divider(),
          ],
        ),
      );
    }

    // get the rating if exist
    void get_raing() async {
      final snapShot = await FirebaseFirestore.instance
          .collection("products")
          .doc("${post.productname}")
          .get();
      if (!snapShot.exists) {
        FirebaseFirestore.instance
            .collection("products")
            .doc("${post.productname}")
            .set({
          'user count': 0.0,
          'total stars': 0.0,
        });
      } else {
        var userRinfo = await FirebaseFirestore.instance
            .collection("products")
            .doc("${post.productname}")
            .collection('users')
            .doc(auth.currentUser.email)
            .get();
        if (userRinfo.exists) {
          _rating_user_old = userRinfo.data()['star'];
        } else {
          _rating_user_old = 0;
        }
        setState(() {
          _rating_star_old = snapShot.data()["total stars"];
          _rating_count_old = snapShot.data()["user count"];
        });
      }
      setState(() {
        _getDone = true;
      });
    }

    // save or create product rating document
    void save() async {
      final snapShot = await FirebaseFirestore.instance
          .collection("products")
          .doc('${post.productname}')
          .collection("users")
          .doc(auth.currentUser.email)
          .get();
      if (snapShot.exists) {
        await FirebaseFirestore.instance
            .collection("products")
            .doc("${post.productname}")
            .update({
          'user count': _rating_count_old,
          'total stars': _rating_star_old + _rating_star_new - _rating_user_old,
        });
        await FirebaseFirestore.instance
            .collection("products")
            .doc('${post.productname}')
            .collection("users")
            .doc(auth.currentUser.email)
            .set({
          'rated': true,
          'star': _rating_star_new,
        });
      } else {
        await FirebaseFirestore.instance
            .collection("products")
            .doc("${post.productname}")
            .update({
          'user count': _rating_count_old + 1,
          'total stars': _rating_star_old + _rating_star_new,
        });
        await FirebaseFirestore.instance
            .collection("products")
            .doc('${post.productname}')
            .collection("users")
            .doc(auth.currentUser.email)
            .set({
          'rated': true,
          'star': _rating_star_new,
        });
      }
    }

    // call to build rating widget
    rating() async {
      await get_raing();
      return popup.show(
        title: 'Rating',
        content: _getDone
            ? build_ratingContent()
            : LoadingBouncingGrid.circle(
                size: 50,
                backgroundColor: Colors.blueAccent,
              ),
        actions: [
          popup.button(
            label: 'Submit',
            onPressed: () {
              save();
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }

    void save_like() async {
      if (post.action == 0) {
        setState(() {
          post.like = post.like + 1;
          post.action = 1;
        });
      } else if (post.action == -1) {
        setState(() {
          post.like = post.like + 1;
          post.dislike = post.dislike - 1;
          post.action = 1;
        });
      } else if (post.action == 1) {
        setState(() {
          post.like = post.like - 1;
          post.action = 0;
        });
      }

      await FirebaseFirestore.instance
          .collection("posts")
          .doc('${post.email + " " + post.productname}')
          .collection("likes")
          .doc(FirebaseAuth.instance.currentUser.email)
          .update({
        "action": post.action,
      });
      await FirebaseFirestore.instance
          .collection("posts")
          .doc('${post.email + " " + post.productname}')
          .update({
        "like": post.like,
        "dislike": post.dislike,
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc("${post.email}")
          .collection("posts")
          .doc('${post.productname}')
          .update({"like": post.like, "dislike": post.dislike});
      await FirebaseFirestore.instance
          .collection("users")
          .doc('${post.email}')
          .collection("posts")
          .doc(post.productname)
          .collection("likes")
          .doc(FirebaseAuth.instance.currentUser.email)
          .update({
        "action": post.action,
      });
    }

    void save_dislike() async {
      if (post.action == 0) {
        setState(() {
          post.dislike = post.dislike + 1;
          post.action = -1;
        });
      } else if (post.action == 1) {
        setState(() {
          post.dislike = post.dislike + 1;
          post.like = post.like - 1;
          post.action = -1;
        });
      } else if (post.action == -1) {
        setState(() {
          post.dislike = post.dislike - 1;
          post.action = 0;
        });
      }
      await FirebaseFirestore.instance
          .collection("posts")
          .doc('${post.email + " " + post.productname}')
          .collection("likes")
          .doc(FirebaseAuth.instance.currentUser.email)
          .update({
        "action": post.action,
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc('${post.email}')
          .collection("posts")
          .doc(post.productname)
          .collection("likes")
          .doc(FirebaseAuth.instance.currentUser.email)
          .update({
        "action": post.action,
      });
      await FirebaseFirestore.instance
          .collection("posts")
          .doc('${post.email + " " + post.productname}')
          .update({
        "dislike": post.dislike,
        "like": post.like,
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc("${post.email}")
          .collection("posts")
          .doc('${post.productname}')
          .update({
        "dislike": post.dislike,
        "like": post.like,
      });
    }

    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconButton(
                        color: (post.action == 1) ? Colors.teal : Colors.black,
                        // color: (post.liked)?Colors.blue:Colors.black,
                        icon: Icon(Icons.thumb_up),
                        onPressed: () {
                          save_like();
                        },
                      ),
                    ),
                    Text('${post.like}'),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconButton(
                        color: (post.action == -1) ? Colors.red : Colors.black,
                        //  color: (post.disliked)?Colors.blue:Colors.black,
                        icon: Icon(Icons.thumb_down),
                        onPressed: () {
                          save_dislike();
                        },
                      ),
                    ),
                    Text('${post.dislike}'),
                    // Text('$pdislikes'),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconButton(
                        icon: Icon(Icons.comment),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      comments(post)));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: IconButton(
                        icon: Icon(Icons.rate_review),
                        onPressed: () {
                          rating();
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
