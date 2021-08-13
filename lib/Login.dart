import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController emailPasswordController = TextEditingController();
  bool showPassword = false;

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: Form(
        key: _form,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 80,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Email Login",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: emailAddressController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.blue,
                        style: TextStyle(color: Colors.blue),
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Enter your email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.blue),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      TextFormField(
                        controller: emailPasswordController,
                        keyboardType: TextInputType.text,
                        cursorColor: Colors.blue,
                        style: TextStyle(color: Colors.blue),
                        obscureText: showPassword ? false : true,
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Enter your password";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.blue),
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Theme(
                            data:
                                ThemeData(unselectedWidgetColor: Colors.white),
                            child: Checkbox(
                                value: showPassword,
                                checkColor: Colors.white,
                                onChanged: (value) {
                                  setState(() {
                                    showPassword = value;
                                  });
                                }),
                          ),
                          Text(
                            showPassword ? "Hide Password" : "Show Password",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final isValid = _form.currentState.validate();
                          if (isValid) {
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            var userDetail = 
                              {
                                "EmailAddress":
                                    "${emailAddressController.text}",
                                "EmailPassword":
                                    "${emailPasswordController.text}"
                              }
                            ;
                            sharedPreferences.setString(
                                "UserDetail", json.encode(userDetail));

                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            child: Text(
                              "Login",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      GestureDetector(
                        onTap: () {
                          
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Login with Google ",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                            Icon(Icons.mail_outline, color: Colors.white)
                          ],
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
