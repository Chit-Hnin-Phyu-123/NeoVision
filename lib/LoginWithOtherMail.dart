import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enough_mail/enough_mail.dart';
import 'Home.dart';

class LoginWithOtherMail extends StatefulWidget {
  const LoginWithOtherMail({Key key}) : super(key: key);

  @override
  _LoginWithOtherMailState createState() => _LoginWithOtherMailState();
}

class _LoginWithOtherMailState extends State<LoginWithOtherMail> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController hostServerController = TextEditingController();
  TextEditingController imapServerPortController =
      TextEditingController(text: "993");
  TextEditingController emailPasswordController = TextEditingController();
  bool showPassword = false;

  bool loading = false;

  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var body = Form(
      key: _form,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              // decoration: BoxDecoration(
              //     border: Border.all(
              //       color: Colors.white,
              //     ),
              //     borderRadius: BorderRadius.circular(5)),
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
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: emailAddressController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      validator: (text) {
                        if (text.isEmpty) {
                          return "Enter your email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "example.com",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        labelText: "Email",
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 18),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: hostServerController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      validator: (text) {
                        if (text.isEmpty) {
                          return "Enter your host server";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Host Server",
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 18),
                        hintText: "tastysoftcloud.com",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: imapServerPortController,
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      validator: (text) {
                        if (text.isEmpty) {
                          return "Enter your Imap server Port";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Imap Server Port",
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 18),
                        hintText: "993",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: emailPasswordController,
                      keyboardType: TextInputType.text,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      obscureText: showPassword ? false : true,
                      validator: (text) {
                        if (text.isEmpty) {
                          return "Enter your password";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 18),
                        hintText: "password",
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                        border: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Theme(
                          data: ThemeData(unselectedWidgetColor: Colors.white),
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
                        setState(() {
                          loading = true;
                        });
                        final isValid = _form.currentState.validate();
                        if (isValid) {
                          SharedPreferences sharedPreferences =
                              await SharedPreferences.getInstance();
                          var userDetail = {
                            "EmailAddress": "${emailAddressController.text}",
                            "HostServer": "${hostServerController.text}",
                            "ImapServerPort":
                                int.parse(imapServerPortController.text),
                            "EmailPassword": "${emailPasswordController.text}"
                          };
                          sharedPreferences.setString(
                              "UserDetail", json.encode(userDetail));

                          sharedPreferences.setString("LoginType", "ImapLogin");

                          String userName = "${userDetail["EmailAddress"]}";
                          String password = "${userDetail["EmailPassword"]}";
                          String hostServer = "${userDetail["HostServer"]}";
                          int imapServerPort = userDetail["ImapServerPort"];
                          bool isImapServerSecure = true;
                          print("ImapExample");

                          final client = ImapClient(isLogEnabled: false);

                          await client
                              .connectToServer(hostServer, imapServerPort,
                                  isSecure: isImapServerSecure)
                              .then((value) {
                            print("Connected Success");
                            setState(() {
                              loading = false;
                            });
                          }).catchError((error) {
                            print("Connect Fail => $error");
                            setState(() {
                              loading = false;
                            });
                            errorSnackbar("Connect fail!");
                          });
                          await client.login(userName, password).then((value) {
                            print("Login Success");
                            setState(() {
                              loading = false;
                            });

                            List accountDetailList = [];

                            if (sharedPreferences
                                        .getString("AccountDetailList") ==
                                    null ||
                                sharedPreferences
                                        .getString("AccountDetailList") ==
                                    "") {
                              accountDetailList = [];
                            } else {
                              accountDetailList = json.decode(sharedPreferences
                                  .getString("AccountDetailList"));
                            }

                            DateTime dateTime = DateTime.now();

                            var accountDetail = {
                              "EmailAddress": "${userDetail["EmailAddress"]}",
                              "Password": "${userDetail["EmailPassword"]}",
                              "HostServer": "${userDetail["HostServer"]}",
                              "ImapServerPort": userDetail["ImapServerPort"],
                              "LastSignin" : {
                                "Date" : dateTime,
                                "Year" : dateTime.year,
                                "Month" : dateTime.month,
                                "Day" : dateTime.day,
                                "WeekDay" : dateTime.weekday,
                                "Hour" : dateTime.hour,
                                "Minute" : dateTime.minute,
                                "Second" : dateTime.second
                              },
                              "LoginType": "ImapLogin"
                            };

                            if (accountDetailList
                                    .where((element) =>
                                        element["EmailAddress"] == userDetail["EmailAddress"])
                                    .toList()
                                    .length ==
                                0) {
                              accountDetailList.add(accountDetail);
                            } else {
                        accountDetailList
                              .where((element) =>
                                  element["EmailAddress"] ==
                                  userDetail["EmailAddress"])
                              .toList()[0] = accountDetail;
                      }
                            sharedPreferences.setString("AccountDetailList",
                                json.encode(accountDetailList));

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                              (Route<dynamic> route) => false,
                            );
                          }).catchError((error) {
                            print("Login Error");
                            setState(() {
                              loading = false;
                            });
                            errorSnackbar("Login fail!");
                          });

                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => Home()));

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
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
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
    );

    var loadProgress = new Container(
        child: new Stack(children: <Widget>[
      body,
      Container(
        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5)),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: CircularProgressIndicator(
          backgroundColor: Colors.blue,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )),
      ),
    ]));

    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.blue[300],
      body: loading ? loadProgress : body,
    );
  }

  errorSnackbar(name) {
    _scaffoldkey.currentState.showSnackBar(new SnackBar(
      content: new Text(name, textAlign: TextAlign.center),
      backgroundColor: Color(0xffe53935),
      duration: Duration(seconds: 3),
    ));
  }

}
