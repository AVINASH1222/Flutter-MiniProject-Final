import 'package:flutter/material.dart';
import 'package:tech_media/chathome.dart';
import 'package:tech_media/feed.dart';
import 'package:tech_media/search1.dart';
import 'package:tech_media/widgets/drawer.dart';
import 'createPost.dart';
import 'profile.dart';

GlobalKey<homeState> homeKey = GlobalKey<homeState>();

// ignore: camel_case_types
class home extends StatefulWidget {
  home() : super(key: homeKey);
  @override
  homeState createState() => homeState();
}

// ignore: camel_case_types
class homeState extends State<home> {
  int selectedIndex = 0;
  // ignore: non_constant_identifier_names
  // user_info current_user_info = new user_info();
  List<Widget> homeOption = <Widget>[
    new Container(
      child: newsfeed(),
    ),
    new Container(
      child: createPost(),
    ),
    new Container(
      child: Searchingpost(),
    ),
    new Container(
      child: chatHome(),
    ),
    new Container(
      child: profile(),
    )
  ];
  @override
  Widget build(BuildContext context) {
    void _onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal,
        ),
        child: Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                backgroundColor: Colors.teal[800],
                icon: Icon(
                  Icons.rss_feed,
                  color: Colors.white,
                ),
                label: 'feed',
              ),
              BottomNavigationBarItem(
                  backgroundColor: Colors.teal[800],
                  icon: Icon(
                    Icons.add_a_photo_sharp,
                    color: Colors.white,
                  ),
                  label: 'post'),
              BottomNavigationBarItem(
                  backgroundColor: Colors.teal[800],
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  label: 'search'),
              BottomNavigationBarItem(
                  backgroundColor: Colors.teal[800],
                  icon: Icon(
                    Icons.message_outlined,
                    color: Colors.white,
                  ),
                  label: 'Message'),
              BottomNavigationBarItem(
                  backgroundColor: Colors.teal[800],
                  icon: Icon(
                    Icons.account_box,
                    color: Colors.white,
                  ),
                  label: 'profile'),
            ],
            currentIndex: selectedIndex,
            selectedItemColor: Colors.white,
            onTap: _onItemTapped,
          ),
          body: Stack(
            children: [DrawerScreen(), homeOption.elementAt(selectedIndex)],
          ),
        ),
      ),
    );
  }
}
