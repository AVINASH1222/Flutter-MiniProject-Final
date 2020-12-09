import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/fullpost.dart';
import 'package:tech_media/main.dart';
import 'package:tech_media/post.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_thumbnail_generator/video_thumbnail_generator.dart';

class Searchingpost extends StatefulWidget {
  @override
  Searchingpoststate createState() => Searchingpoststate();
}

class Searchingpoststate extends State<Searchingpost> {
  TextEditingController _controller = new TextEditingController();
  FirebaseFirestore _store = FirebaseFirestore.instance;
  String search;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _controller,
              onChanged: (val) {
                setState(() {
                  search = val.toLowerCase();
                });
              },
              decoration: InputDecoration(
                  suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => _controller.clear()),
                  hintText: "Search"),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: (search == null || search.trim() == ' ')
                  ? _store.collection("posts").snapshots()
                  : _store
                      .collection("posts")
                      .where('search', arrayContains: search)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text("Searching");
                  case ConnectionState.none:
                    return Text("NONE");
                  case ConnectionState.done:
                    return Text("DONE");
                  default:
                    return ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        children:
                            snapshot.data.docs.map((DocumentSnapshot document) {
                              // Uint8List bytes;
                              // File file;
                              // VideoPlayerController controller;
                              // setState(() async{
                              //   if(document["type"]=="video"){
                              //     // var thumbnail = await VideoThumbnail.thumbnailFile(
                              //     //   video: document["multimedia"],
                              //     //   imageFormat: ImageFormat.PNG,
                              //     // );
                              //     // file = File(thumbnail);
                              //     // bytes = file.readAsBytesSync();
                                  
                              //     // controller.initialize();
                              //   }
                              // });
                          return ListTile(
                            leading:  (document["type"]=="image")?Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: NetworkImage(document["multimedia"]),
                                    fit: BoxFit.cover),
                                shape: BoxShape.circle,
                              ),
                            ):
                            Container(
                              width: 45,
                              height: 45,
                              child: ThumbnailImage(videoUrl: document["multimedia"])
                            ),
                            title: Text(document['product name']),
                            onTap: () {
                              Post post;
                              setState(() async {
                                await _store
                                    .collection("users")
                                    .doc(document["email"])
                                    .get()
                                    .then((value) {
                                  FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(document["email"] +
                                          " " +
                                          document["product name"])
                                      .collection('likes')
                                      .doc(auth.currentUser.email)
                                      .get()
                                      .then((values) {
                                    post = new Post(
                                      email: document["email"],
                                      productname: document["product name"],
                                      caption: document["content"],
                                      imageUrl: document["multimedia"],
                                      comments: document["comments"],
                                      like: document["like"],
                                      dislike: document["dislike"],
                                      document_name: document["email"] +
                                          " " +
                                          document["product name"],
                                      uname: value["first name"],
                                      udp: value["dp"],
                                      type: document["type"],
                                      action: values.data()['action'],
                                    );
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => fullPost(post),
                                        ));
                                  });
                                });
                              });
                            },
                          );
                        }).toList());
                }
              })
        ],
      )),
    );
  }
}
