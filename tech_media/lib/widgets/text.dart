import 'package:flutter/material.dart';
import 'ColumnBuilder.dart';
import '../post.dart';

// ignore: must_be_immutable
class Usercomments extends StatefulWidget {
  List<dynamic> comment;
  Post post;
  Usercomments(this.comment, this.post);
  @override
  _UsercommentsState createState() => _UsercommentsState(comment, post);
}

class _UsercommentsState extends State<Usercomments> {
  List<dynamic> comment;
  Post post;
  _UsercommentsState(this.comment, this.post);
  Widget _build() {
    return ColumnBuilder(
      // ignore: missing_return
      itemBuilder: (context, index) {
        if (index < comment.length) {
          return items(comment[index]);
        }
      },
      itemCount: comment.length, // comment.length,
    );
  }

  Widget items(String comment) {
    return new Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Icon(Icons.person),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Text('@abcd'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(comment),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              _build(),
            ],
          )
        ],
      ),
    );
  }
}
