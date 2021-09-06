import 'dart:convert';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'GetMail.dart';
import 'Home.dart';

class SwitchAccount extends StatefulWidget {
  const SwitchAccount({Key key}) : super(key: key);

  @override
  _SwitchAccountState createState() => _SwitchAccountState();
}

class _SwitchAccountState extends State<SwitchAccount> {
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();
  List accountDetailList = [];
  DateTime dateTime = DateTime.now();
  bool loading = false;
  Future<void> getAccount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("AccountDetailList") == null ||
        sharedPreferences.getString("AccountDetailList") == "") {
      accountDetailList = [];
    } else {
      accountDetailList =
          json.decode(sharedPreferences.getString("AccountDetailList"));
    }
  }

  @override
  initState() {
    super.initState();
    getAccount();
  }

  @override
  Widget build(BuildContext context) {
    var body = accountDetailList.length == 0
        ? Center(
            child: Text(
              "No Account",
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            itemCount: accountDetailList.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () async {
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  if (accountDetailList[i]["LoginType"] == "ImapLogin") {
                    setState(() {
                      loading = true;
                    });

                    var userDetail = {
                      "EmailAddress": "${accountDetailList[i]["EmailAddress"]}",
                      "HostServer": "${accountDetailList[i]["Password"]}",
                      "ImapServerPort": accountDetailList[i]["HostServer"],
                      "EmailPassword": "${accountDetailList[i]["ImapServerPort"]}"
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

                      if (sharedPreferences.getString("AccountDetailList") ==
                              null ||
                          sharedPreferences.getString("AccountDetailList") ==
                              "") {
                        accountDetailList = [];
                      } else {
                        accountDetailList = json.decode(
                            sharedPreferences.getString("AccountDetailList"));
                      }

                      DateTime dateTime = DateTime.now();

                      var accountDetail = {
                        "EmailAddress": "${userDetail["EmailAddress"]}",
                        "Password": "${userDetail["EmailPassword"]}",
                        "HostServer": "${userDetail["HostServer"]}",
                        "ImapServerPort": userDetail["ImapServerPort"],
                        "LastSignin": {
                          "Date": dateTime,
                          "Year": dateTime.year,
                          "Month": dateTime.month,
                          "Day": dateTime.day,
                          "WeekDay": dateTime.weekday,
                          "Hour": dateTime.hour,
                          "Minute": dateTime.minute,
                          "Second": dateTime.second
                        },
                        "LoginType": "ImapLogin"
                      };

                      if (accountDetailList
                              .where((element) =>
                                  element["EmailAddress"] ==
                                  userDetail["EmailAddress"])
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
                      sharedPreferences.setString(
                          "AccountDetailList", json.encode(accountDetailList));

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
                  } else if (accountDetailList[i]["LoginType"] ==
                      "GoogleLogin") {
                    setState(() {
                      loading = true;
                    });
                    await GMail().getHttpClient().then((value) {
                      sharedPreferences.setString("LoginType", "GoogleLogin");
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                        (Route<dynamic> route) => false,
                      );
                    }).catchError((error) {
                      setState(() {
                        loading = false;
                      });
                      errorSnackbar("Login fail!");
                    });
                  }
                },
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Text("${accountDetailList[i]["EmailAddress"]}"),
                      Row(
                        children: <Widget>[
                          Text("Last Sing in - "),
                          dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inSeconds <= 1
                              ? Text(
                                  "${dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inSeconds} second ago")
                              : dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inSeconds < 60
                                  ? Text(
                                      "${dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inSeconds} seconds ago")
                                  : dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inMinutes <= 1
                                      ? Text(
                                          "${dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inMinutes} minute ago")
                                      : dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inMinutes > 1 &&
                                              dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inMinutes <
                                                  60
                                          ? Text(
                                              "${dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inMinutes} minutes ago")
                                          : dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inHours <= 1
                                              ? Text(
                                                  "${dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inHours} hour ago")
                                              : dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inHours > 1 && dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inHours < 24
                                                  ? Text(
                                                      "${dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inHours} hours ago")
                                                  : dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inDays <= 1
                                                      ? Text(
                                                          "${dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inDays} day ago")
                                                      : dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inDays > 1 && dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inDays < 30
                                                          ? Text("${dateTime.difference(accountDetailList[i]["LastSignin"]["Date"]).inDays} days ago")
                                                          : Text("${accountDetailList[i]["LastSignin"]["Day"] / accountDetailList[i]["LastSignin"]["Month"] / accountDetailList[i]["LastSignin"]["Year"]}"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });

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
      appBar: AppBar(
        centerTitle: true,
        title: Text("Accounts"),
      ),
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
