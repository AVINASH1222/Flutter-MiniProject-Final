import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_media/home.dart';
import 'widgets/style.dart';
import 'register.dart';
import 'Widgets/animation.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: camel_case_types
class login extends StatefulWidget {
  @override
  loginState createState() => loginState();
}

// ignore: camel_case_types
class loginState extends State<login> {
  BorderRadius bRadius = new BorderRadius.circular(32.0);
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool showpass = true;
  var emailvalidator = EmailValidator(errorText: 'enter a valid email address');
  var requiredvalidator = RequiredValidator(errorText: 'password required!');
  final FirebaseAuth fba = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final emailField = TextFormField(
      controller: email,
      validator: emailvalidator,
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

    final passwordField = TextFormField(
      controller: password,
      validator: requiredvalidator,
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

    return Container(
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
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: height - height * 1,
                ),
                FadeAnimation(
                    0.5,
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Text('Login', style: TextStyle(fontSize: 50.0)),
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
                          if (emailvalidator.isValid(email.text) &&
                              requiredvalidator.isValid(password.text)) {
                            final User user = (await fba
                                    .signInWithEmailAndPassword(
                                        email: email.text,
                                        password: password.text)
                                    .catchError((error) {
                              Fluttertoast.showToast(
                                  msg: 'no record found, please register');
                            }))
                                .user;
                            if (user != null) {
                              Fluttertoast.showToast(
                                  msg: 'welcome ${user.email}');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          home()));
                            }
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
                                    builder: (BuildContext context) =>
                                        register()));
                          },
                          child: Text(
                            'new user? register!',
                            style: TextStyle(fontSize: 20.0),
                          )),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
