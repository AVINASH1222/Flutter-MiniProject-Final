import 'package:flutter/material.dart';

class Post {
  String uname;
  String udp;
  String email;
  String productname;
  String caption;
  String imageUrl;
  int like;
  String document_name;
  String comments;
  int dislike;
  String type;
  int action;
  Post({
    @required this.productname,
    @required this.caption,
    @required this.imageUrl,
    @required this.comments,
    @required this.uname,
    @required this.udp,
    @required this.like,
    @required this.dislike,
    @required this.document_name,
    @required this.action,
    @required this.type,
    this.email,
  });
}
