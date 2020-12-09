import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:tech_media/home.dart';
import 'widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';

// ignore: camel_case_types
class profile_info extends StatefulWidget {
  @override
  _profile_infoState createState() => _profile_infoState();
}

// ignore: camel_case_types
class _profile_infoState extends State<profile_info> {
  // selecting DP
  File dp;
  Future<void> gallery() async {
    // ignore: deprecated_member_use
    File imagefile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    print('$imagefile selected');
    setState(() {
      dp = imagefile;
    });
  }

  var firstColor = Color(0xff5b86e5), secondColor = Color(0xff36d1dc);
  BorderRadius bRadius = new BorderRadius.circular(32.0);
  // ignore: non_constant_identifier_names
  TextEditingController f_name = TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController l_name = TextEditingController();
  TextEditingController age = TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController phone_no = TextEditingController();
  // ignore: non_constant_identifier_names
  // ignore: unused_field
  StorageUploadTask _uploadTask;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  bool show = false;
  
  
  void addinfo() {
    try {
      String filepath = 'profile_picture/${auth.currentUser.email}.png';

      setState(() async {
        _uploadTask =
            await _firebaseStorage.ref().child(filepath).putFile(dp).onComplete
                // ignore: missing_return
                .then((value) {
          value.ref.getDownloadURL().then((val) {
            // print(val);
            users.doc(auth.currentUser.email).set({
              'first name': f_name.text,
              'last name': l_name.text,
              'age': age.text,
              'phone number': phone_no.text,
              'dp': val,
            });
            users.get().then((value) {
              for(int i=0;i<value.docs.length;i++){
                users.doc(value.docs[i].id).collection("posts").get().then((val) {
                  for(int j=0;j<val.docs.length;j++){
                    users.doc(value.docs[i].id).collection("posts").doc(val.docs[j].id).collection("likes").doc(FirebaseAuth.instance.currentUser.email).set({
                      'action':0
                    });
                  }
                });
              }
            });
            FirebaseFirestore.instance.collection("posts").get().then((value){
              for(int i=0;i<value.docs.length;i++){
                FirebaseFirestore.instance.collection("posts").doc(value.docs[i].id).collection("likes").doc(FirebaseAuth.instance.currentUser.email).set({
                  'action':0
                });
              }
            });
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // name text input
    nameInput(String type) {
      return TextFormField(
        controller: type == 'first name'
            ? f_name
            : type == 'last name'
                ? l_name
                : type == 'age'
                    ? age
                    : phone_no,
        obscureText: false,
        style: Tstyleinfo(),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: type,
            hintStyle: Tstyleinfo(),
            focusedBorder: OutlineInputBorder(
                borderRadius: bRadius, borderSide: Bstyleinfo()),
            enabledBorder: OutlineInputBorder(
                borderRadius: bRadius, borderSide: Bstyleinfo())),
      );
    }

    // ignore: non_constant_identifier_names
    Widget button_submit(String info) {
      return NiceButton(
        radius: 40,
        width: 150.0,
        text: info,
        gradientColors: [secondColor, firstColor],
        background: null,
        fontSize: 22,
        textColor: Colors.black,
        onPressed: () {
          if((f_name.text.isEmpty)||(l_name.text.isEmpty)||(age.text.isEmpty)||(phone_no.text.isEmpty)||(dp==null)){
            Fluttertoast.showToast(
                  msg: 'All Fields And Image Required');
          }
          else{
            setState(() {
              show = true;
            });
            addinfo();
            print('info added!');
            Future.delayed(Duration(seconds: 10),(){
              setState(() {
                Navigator.pushReplacement(context,MaterialPageRoute(builder: (BuildContext context) => home()));
                show = false;
              });
            });
          }
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
            inAsyncCall: show,
            child: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    // gradient: LinearGradient(
                    // colors: [secondColor, firstColor],
                    //),
                    ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // DP container
                        Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: dp != null
                                    ? FileImage(dp)
                                    : AssetImage('assets/icons/profile.png'),
                              )),
                        ),
                        // add image button
                        Positioned(
                          bottom: (MediaQuery.of(context).size.width * 0.3) * 0.2,
                          right: 0,
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                                width: 46.0,
                                height: 47.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.elliptical(23.0, 23.5)),
                                  color: Colors.white,
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.black,
                                  ),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.add_a_photo_rounded),
                                  onPressed: () async {
                                    await gallery();
                                  },
                                )),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            // image: DecorationImage(
                            //   image: AssetImage('assets/images/info_back.jpg'),
                            //   fit: BoxFit.cover,
                            // )
                            color: Colors.white),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.025,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 10.0),
                              child: nameInput("first name"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 10.0),
                              child: nameInput("last name"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 10.0),
                              child: nameInput("age"),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 10.0),
                              child: nameInput("phone number"),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                button_submit("submit"),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
