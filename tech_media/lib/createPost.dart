import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:video_player/video_player.dart';
import 'feed.dart';
import 'home.dart';

import 'main.dart';

// ignore: camel_case_types
class createPost extends StatefulWidget {
  @override
  _createPostState createState() => _createPostState();
}

// ignore: camel_case_types
class _createPostState extends State<createPost> {
  // ignore: non_constant_identifier_names
  TextEditingController product_name = TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController post_review_content = TextEditingController();
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  StorageUploadTask _uploadTask;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  File image;
  File video;
  int checkVideoOrImage=0;
  VideoPlayerController controller;

  double getwidth() {
    return MediaQuery.of(context).size.width;
  }

  capture() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File imagefile = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      checkVideoOrImage=1;
      this.image = imagefile;
    });
  }

  onAlertWithCustomContentPressed(context) {
    Alert(
        context: context,
        title: "UPLOADED",
        buttons: [
          DialogButton(
            color: Colors.black,
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text(
              "close",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  gallery() async {
    Navigator.pop(context);
    // ignore: deprecated_member_use
    File imagefile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      checkVideoOrImage=1;
      this.image = imagefile;
    });
  }

  options(acontext) {
    return showDialog(
        context: acontext,
        builder: (constext) {
          return SimpleDialog(
            title: Text('Select'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('use camera'),
                onPressed: capture,
              ),
              SimpleDialogOption(
                child: Text('use gallery'),
                onPressed: gallery,
              ),
            ],
          );
        });
  }

  // ignore: non_constant_identifier_names
  selectfile(Context) {
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
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.225,
              ),
              Icon(
                Icons.add_a_photo_sharp,
                color: Colors.black,
                size: 100.0,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: RaisedButton(
                    color: Colors.teal[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    onPressed: () {
                      options(context);
                    },
                    child: Text(
                      'Image',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0,left: 10.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: RaisedButton(
                    color: Colors.teal[800],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    onPressed: () {
                      pickvideo(ImageSource.gallery);
                    },
                    child: Text(
                      'Video',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  remove() {
    setState(() {
      image = null;
      video=null;
      checkVideoOrImage=0;
    });
  }

  // ignore: non_constant_identifier_names
  Future<void> upload_post() {
    try {
      String filepath = 'post/${auth.currentUser.email} ${DateTime.now()}.png';
      String pro_name = product_name.text;
      String email_curr = auth.currentUser.email.toString();
      List<String> splitlist = pro_name.split(' ');
      List<String> indexlist = [];
      for (int i = 0; i <splitlist.length; i++) {
        for (int j = 0; j <=splitlist[i].length; j++) {
          indexlist.add(splitlist[i].substring(0, j).toLowerCase());
        }
        indexlist.add(" ");
      }
      setState(() async {
        _uploadTask = await _firebaseStorage
            .ref()
            .child(filepath)
            .putFile(image)
            .onComplete
            // ignore: missing_return
            .then((value) {
          value.ref.getDownloadURL().then((val) {
            users
                .doc(auth.currentUser.email)
                .collection("posts")
                .doc(product_name.text)
                .set({
              'email': email_curr,
              'product name': pro_name,
              'content': post_review_content.text,
              'multimedia': val,
              'like': 0,
              'dislike': 0,
              'type':'image',
              'comments': 'best review',
            });
            print('done');
            posts.doc('$email_curr $pro_name').set({
              'email': email_curr,
              'product name': pro_name,
              'content': post_review_content.text,
              'multimedia': val,
              'like': 0,
              'dislike': 0,
              'type':'image',
              'comments': 'best review',
              'search': indexlist,
            });
            users.get().then((ele) {
              for (int i = 0; i < ele.docs.length; i++) {
                posts
                    .doc('$email_curr $pro_name')
                    .collection('likes')
                    .doc(ele.docs[i].id)
                    .set({
                  "action": 0,
                });
                users
                    .doc(auth.currentUser.email)
                    .collection("posts")
                    .doc(product_name.text)
                    .collection('likes')
                    .doc(ele.docs[i].id)
                    .set({
                  "action": 0,
                });
              }
              ;
            });
          });
        });
      });
    } catch (e) {
      print(e);
    }
    homeKey.currentState.setState(() {
      homeKey.currentState.homeOption[0] = newsfeed();
      homeKey.currentState.selectedIndex = 0;
    });
  }
  pickvideo(ImageSource source)async{
    File selected = await ImagePicker.pickVideo(source: source);
    if(selected!=null){
      setState(() {
        checkVideoOrImage = 2;
        video = selected;
        controller = VideoPlayerController.file(video);
        controller.initialize();
        controller.setLooping(true);
      });
    }
  }
  void _uploadvideo(){
    try{
        String filepath = 'post/${auth.currentUser.email} ${DateTime.now()}.png';
      String pro_name = product_name.text;
      String email_curr = auth.currentUser.email.toString();
      List<String> splitlist = pro_name.split(' ');
      List<String> indexlist = [];
      for (int i = 0; i <splitlist.length; i++) {
        for (int j = 0; j <=splitlist[i].length; j++) {
          indexlist.add(splitlist[i].substring(0, j).toLowerCase());
        }
        indexlist.add(" ");
      }
      setState(() async {
        _uploadTask = await _firebaseStorage
            .ref()
            .child(filepath)
            .putFile(video,StorageMetadata(contentType:'video/mp4'))
            .onComplete
            // ignore: missing_return
            .then((value) {
          value.ref.getDownloadURL().then((val) {
            users
                .doc(auth.currentUser.email)
                .collection("posts")
                .doc(product_name.text)
                .set({
              'email': email_curr,
              'product name': pro_name,
              'content': post_review_content.text,
              'multimedia': val,
              'like': 0,
              'dislike': 0,
              'type':'video',
              'comments': 'best review',
            });
            print('done');
            posts.doc('$email_curr $pro_name').set({
              'email': email_curr,
              'product name': pro_name,
              'content': post_review_content.text,
              'multimedia': val,
              'like': 0,
              'dislike': 0,
              'type':'video',
              'comments': 'best review',
              'search': indexlist,
            });
            users.get().then((ele) {
              for (int i = 0; i < ele.docs.length; i++) {
                posts
                    .doc('$email_curr $pro_name')
                    .collection('likes')
                    .doc(ele.docs[i].id)
                    .set({
                  "action": 0,
                });
                users
                    .doc(auth.currentUser.email)
                    .collection("posts")
                    .doc(product_name.text)
                    .collection('likes')
                    .doc(ele.docs[i].id)
                    .set({
                  "action": 0,
                });
              }
              ;
            });
          });
        });
      });
      onAlertWithCustomContentPressed(context);
    }catch(e){
      print(e);
    }
     homeKey.currentState.setState(() {
      homeKey.currentState.homeOption[0] = newsfeed();
      homeKey.currentState.selectedIndex = 0;
    });
  }
  preview(context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[800],
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: () {
            // Navigator.pop(context);
            remove();
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => home()));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.post_add_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              (checkVideoOrImage==1)?upload_post():_uploadvideo();
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Divider(),
          (checkVideoOrImage==1)?Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width * 0.8,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: FileImage(image), fit: BoxFit.cover),
                ),
              ),
            ),
          ):
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
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
          ),
          Divider(
            color: Colors.purple,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            child: TextField(
              controller: product_name,
              decoration: InputDecoration(
                hintText: 'Product name',
                border: InputBorder.none,
              ),
            ),
          ),
          Divider(
            color: Colors.purple,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            child: TextField(
              controller: post_review_content,
              minLines: 1,
              maxLines: 20,
              decoration: InputDecoration(
                hintText: 'write your review',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  bool isDrawerOpen = false;
  @override
  Widget build(BuildContext context) {
    return checkVideoOrImage == 0 ? selectfile(context) : preview(context);
  }
}
