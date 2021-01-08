import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tech_media/home.dart';
import 'package:tech_media/login.dart';

bool showprogress = true;

class Autologin extends StatefulWidget{
  @override
  AutologinState createState() =>AutologinState();
}


class AutologinState extends State<Autologin>{
  Timer timer;
  @override
  void initState(){
    super.initState();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
        if(FirebaseAuth.instance.currentUser!=null){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => home(),));
          setState(() {
            showprogress = false;
          });
          timer.cancel();
        }
        else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login(),));
          setState(() {
            showprogress = false;
          });
          timer.cancel();
        }
     });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(inAsyncCall: showprogress, child: Container()),
    );
  }
}