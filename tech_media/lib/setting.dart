import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tech_media/home.dart';



class Setting extends StatefulWidget{
  @override
  SettingsState createState() =>SettingsState();
}

class SettingsState extends State<Setting>{
  FirebaseAuth _auth = FirebaseAuth.instance;
  var alertstyling = AlertStyle(
    backgroundColor: Colors.white,
    alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
        side: BorderSide(
          color: Colors.grey,
        ),
      ),
  );
  _onAlertWithCustomContentPressed(context) {
    Alert(
        context: context,
        style: alertstyling,
        title: "RESET LINK SENT TO MAIL",
        buttons: [
          DialogButton(
            color: Colors.black,
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>home()));
            },
            child: Text(
              "CLOSE",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),

          )
        ]).show();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text("Change Password"),
                trailing: Icon(Icons.edit),
                onTap: ()async{
                  await _auth.sendPasswordResetEmail(email: _auth.currentUser.email);
                  _onAlertWithCustomContentPressed(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}