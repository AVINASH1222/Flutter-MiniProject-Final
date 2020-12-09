import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/profile_info.dart';
import 'package:tech_media/widgets/animation.dart';
import 'widgets/style.dart';
import 'login.dart';
import 'main.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: camel_case_types
class register extends StatefulWidget {
  @override
  _registerState createState() => _registerState();
}

// ignore: camel_case_types
class _registerState extends State<register> {
  final FirebaseAuth fba = FirebaseAuth.instance;
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  BorderRadius bRadius = new BorderRadius.circular(32.0);
  bool showpass = true;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    final emailField = TextField(
      controller: email,
      obscureText: false,
      style: Tstyle(),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          hintStyle: Tstyle(),
          focusedBorder:
              OutlineInputBorder(borderRadius: bRadius, borderSide: Bstyle()),
          enabledBorder:
              OutlineInputBorder(borderRadius: bRadius, borderSide: Bstyle())),
    );

    final passwordField = TextField(
      controller: password,
      obscureText: showpass,
      style: Tstyle(),
      decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                showpass = !showpass;
              });
            },
            icon: showpass
                ? Icon(
                    Icons.visibility,
                  )
                : Icon(
                    Icons.visibility_off,
                  ),
          ),
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          hintStyle: Tstyle(),
          focusedBorder:
              OutlineInputBorder(borderRadius: bRadius, borderSide: Bstyle()),
          enabledBorder:
              OutlineInputBorder(borderRadius: bRadius, borderSide: Bstyle())),
    );

    return FadeAnimation(
        1,
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/background/login.png"),
            fit: BoxFit.cover,
          )),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Form(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: height - height * 1,
                      ),
                      FadeAnimation(
                          0.5,
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0),
                            child: Text('Register',
                                style: TextStyle(fontSize: 50.0)),
                          )),
                      FadeAnimation(
                          1,
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 10.0),
                            child: emailField,
                          )),
                      FadeAnimation(
                          1.5,
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 10.0),
                            child: passwordField,
                          )),
                      FadeAnimation(
                          2,
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 15.0),
                            child: GestureDetector(
                              onTap: () async {
                                final User user = (await fba
                                        .createUserWithEmailAndPassword(
                                            email: email.text,
                                            password: password.text)
                                        .catchError((errMsg) {
                                  Fluttertoast.showToast(
                                      msg: 'email address already in use');
                                }))
                                    .user;
                                if (user != null) {
                                  Map userdata = {
                                    "email": email.text,
                                    "password": password.text,
                                  };
                                  userref.child(user.uid).set(userdata);
                                  Fluttertoast.showToast(
                                      msg: 'registered successfully');
                                  // addUser();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              profile_info()));
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          'some problem occured, try again later!.');
                                }
                              },
                              child: Container(
                                height: 100,
                                width: 100,
                                child: Icon(
                                  Icons.forward,
                                  size: 50.0,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          )),
                      FadeAnimation(
                          2.5,
                          Container(
                            child: FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          // ignore: non_constant_identifier_names
                                          builder: (Context) => login()));
                                },
                                child: Text(
                                  'Existing user? login!',
                                  style: TextStyle(fontSize: 20.0),
                                )),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
