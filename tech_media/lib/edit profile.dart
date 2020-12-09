import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:tech_media/home.dart';
import 'package:tech_media/user_info.dart';
import 'widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';

// ignore: must_be_immutable , camel_case_types
class edit_profile extends StatefulWidget {
  @override
  _edit_profileState createState() => _edit_profileState();
}

// ignore: non_constant_identifier_names
TextEditingController f_name = TextEditingController();
// ignore: non_constant_identifier_names
TextEditingController l_name = TextEditingController();
TextEditingController age = TextEditingController();
// ignore: non_constant_identifier_names
TextEditingController phone_no = TextEditingController();
// ignore: must_be_immutable , camel_case_types
TextEditingController image = TextEditingController();

// ignore: camel_case_types
class _edit_profileState extends State<edit_profile> {
  // ignore: non_constant_identifier_names

  // selecting DP
  user_info curr;
  @override
  void initState() {
    super.initState();
    users.doc(auth.currentUser.email).get().then((DocumentSnapshot value) {
      curr = new user_info(value["first name"], value["last name"],
          value["age"], value["phone number"], value["dp"]);
      setState(() {
        f_name.text = curr.firstname;
        l_name.text = curr.lastname;
        age.text = curr.age;
        phone_no.text = curr.phone_number;
        image.text = curr.url;
      });
    });
  }

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

  Future<void> updateinfo() async {
    try {
      setState(() async {
        await users.doc(auth.currentUser.email).set({
          'first name': f_name.text,
          'last name': l_name.text,
          'age': age.text,
          'phone number': phone_no.text,
          'dp': dp,
        });
        print('$f_name.text');
      });
    } catch (e) {
      print('error da $e');
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
    Widget button_cancel(String info) {
      return NiceButton(
        radius: 40,
        width: 150.0,
        text: info,
        gradientColors: [secondColor, firstColor],
        background: null,
        fontSize: 22,
        textColor: Colors.black,
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => home()));
        },
      );
    }

    // ignore: non_constant_identifier_names
    Widget button_save(String info) {
      return NiceButton(
        radius: 40,
        width: 150.0,
        text: info,
        gradientColors: [secondColor, firstColor],
        background: null,
        fontSize: 22,
        textColor: Colors.black,
        onPressed: () async {
          await updateinfo();
          print('info updated!');
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (BuildContext context) => home()));
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
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
                                    : NetworkImage(image.text.toString()))),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              button_cancel("cancel"),
                              button_save("save"),
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
    );
  }
}
