import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:neo_vision/GetMail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';
import 'LoginWithOtherMail.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController hostServerController = TextEditingController();
  TextEditingController emailPasswordController = TextEditingController();
  bool showPassword = false;

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blue[300],
      body: Form(
        key: _form,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue[300],
                    ),
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        color: Colors.blue[300],
                        size: 80,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Login",
                        style: TextStyle(color: Colors.blue[300], fontSize: 20),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () async {
                          SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                          await GMail().getHttpClient().then((value) {
                            sharedPreferences.setString("LoginType", "GoogleLogin");
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Google",
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                // Icon(Icons.mail_outline, color: Colors.white)
                                Image.asset("assets/google.png", width: 20,)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text("Or", style: TextStyle(color: Colors.blue[300], fontSize: 15)),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginWithOtherMail()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Other",
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.mail_outline,
                                 color: Colors.white)
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
