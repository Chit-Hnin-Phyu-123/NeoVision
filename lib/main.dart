import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home.dart';
import 'Login.dart';

var isLogin;
void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      isLogin = sharedPreferences.getString("LoginType");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neo Vision',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isLogin == null ? Login() : Home(),
      // home: Login(),
    );
  }
}
