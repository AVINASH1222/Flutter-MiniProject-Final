import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/edit profile.dart';
import 'package:tech_media/home.dart';
import 'package:tech_media/login.dart';
import 'package:tech_media/setting.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    Widget _createDrawerItem(
        {IconData icon, String text, GestureTapCallback onTap}) {
      return ListTile(
        title: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                text,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        onTap: onTap,
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.teal[900],
        padding: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _createDrawerItem(
                icon: Icons.settings,
                text: 'settings',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Setting()));
                }),
            Divider(),
            _createDrawerItem(
                icon: Icons.edit_attributes,
                text: 'Edit profile',
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => edit_profile()));
                }),
            Divider(),
            _createDrawerItem(
                icon: Icons.logout,
                text: 'logout',
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login(),));
                }),
          ],
        ),
      ),
    );
  }
}
