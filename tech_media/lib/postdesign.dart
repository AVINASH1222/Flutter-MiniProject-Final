import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:tech_media/comments.dart';
import 'package:tech_media/fullpost.dart';
import 'package:tech_media/home.dart';
import 'package:tech_media/main.dart';
import 'package:tech_media/profile.dart';
import 'post.dart';
import 'package:loading_animations/loading_animations.dart';
import 'widgets/animation.dart';
import 'feed.dart';

// ignore: camel_case_types
class postdesign extends StatefulWidget {
  @override
  _postdesignState createState() => _postdesignState(post, from);
  final Post post;
  final String from;
  postdesign(this.post, this.from);
}

TextEditingController uname = TextEditingController();
TextEditingController uimage = TextEditingController();

var dislikes = 0;
var likes = 0;
bool rated = false;

// ignore: camel_case_types
class _postdesignState extends State<postdesign> {
  final Post post;
  final String from;
  _postdesignState(this.post, this.from);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    delete(Post post) {
      FirebaseFirestore.instance
          .collection("posts")
          .doc('${auth.currentUser.email} ${post.productname}')
          .delete();
      FirebaseFirestore.instance
          .collection("posts")
          .doc('${auth.currentUser.email} ${post.productname}')
          .collection('likes')
          .getDocuments()
          .then((value) {
        for (DocumentSnapshot ds in value.documents) {
          ds.reference.delete();
        }
      });
      FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser.email)
          .collection("posts")
          .doc('${post.productname}')
          .delete();
      FirebaseFirestore.instance
          .collection("users")
          .doc(auth.currentUser.email)
          .collection("posts")
          .doc('${post.productname}')
          .collection('likes')
          .getDocuments()
          .then((value) {
        for (DocumentSnapshot ds in value.documents) {
          ds.reference.delete();
        }
      });
    }

    options(context, Post post) {
      return showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FlatButton(
                      onPressed: () async {
                        delete(post);
                        profileKey.currentState.posts.clear();
                        await profileKey.currentState.retreiveimage();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Delete Post",
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      )),
                ],
              ),
            );
          });
    }

    return FadeAnimation(
        0.01,
        Container(
          margin: EdgeInsets.symmetric(vertical: 5.0),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                      Text(
                        post.uname,
                      ),
                    ],
                  ),
                  from == "profile"
                      ? IconButton(
                          iconSize: 20,
                          icon: Icon(
                            Icons.more_horiz,
                            size: 30.0,
                          ),
                          onPressed: () {
                            //_onAlertWithCustomContentPressed(context);
                            options(context, post);
                          })
                      : Container(),
                ],
              ),
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
                      child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        fullPost(post)));
                          },
                          child: Image(
                            image: NetworkImage(post.imageUrl),
                          )),
                    )
                  : SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                child: properties(post),
              ),
            ],
          ),
        ));
  }
}

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
        if (_rating_user_old == null) {
          _rating_user_old = 0.0;
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
            _ratingBar_new(_rating_user_old, false),
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

    return Column(
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
                      color: post.action == 1 ? Colors.teal : Colors.black,
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
                      color: post.action == -1 ? Colors.red : Colors.black,
                      icon: Icon(Icons.thumb_down),
                      onPressed: () {
                        save_dislike();
                      },
                    ),
                  ),
                  Text('${post.dislike}'),
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
    );
  }
}
