import 'dart:convert';

import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class SecureStorage {
  final storage = FlutterSecureStorage();
  //Save Credentials
  Future saveCredentials(AccessToken token, String refreshToken) async {
    print(token.expiry.toIso8601String());
    await storage.write(key: "type", value: token.type);
    await storage.write(key: "data", value: token.data);
    await storage.write(key: "expiry", value: token.expiry.toString());
    await storage.write(key: "refreshToken", value: refreshToken);
  }

  //Get Saved Credentials
  Future<Map<String, dynamic>> getCredential() async {
    var result = await storage.readAll();
    return result;
  }

  //Clear Saved Credentials
  Future clear() {
    return storage.deleteAll();
  }
}

// const _clientId =
//     '1096412623635-63s715t2qdkm129mh0f84kj5e2sr7luo.apps.googleusercontent.com';
// const _clientSecret = 'HWuaPRpQ-8R93u4Q5kiCrgFC';
const _clientId =
    // '183670288267-k6flall0oent8uie5g5rjvs5povk9oi8.apps.googleusercontent.com';
    "708883610263-eeh0jd9003oe0a6061epo991jpa9q55v.apps.googleusercontent.com";
// const _clientSecret = 'XzRGZ5NTDhg4lvm9zikPahB2';
const _clientSecret = 'vn5WqUAxmeG0O3LW1MzvCweW';
const _scopes = [
  // gmail.GmailApi.gmailModifyScope,
  gmail.GmailApi.GmailModifyScope
];

final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
  "email",
  gmail.GmailApi.GmailModifyScope,
]);

class GMail {
  final storage = SecureStorage();

  //Get Authenticated Http Client
  Future<http.Client> getHttpClient() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //Get Credentials
    var credentials = await storage.getCredential();
    if (credentials.isEmpty) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
          ClientId(_clientId, _clientSecret), _scopes, (url) async {
        //Open Url in Browser
        // launch(url);
        await FlutterWebBrowser.openWebPage(url: "$url");
        // _handleSignIn(url);

        List accountDetailList = [];

        if (sharedPreferences.getString("AccountDetailList") == null ||
            sharedPreferences.getString("AccountDetailList") == "") {
          accountDetailList = [];
        } else {
          accountDetailList =
              json.decode(sharedPreferences.getString("AccountDetailList"));
        }

        DateTime dateTime = DateTime.now();

        var accountDetail = {
          "EmailAddress": "$url",
          "Password": "",
          "HostServer": "",
          "ImapServerPort": "",
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
          "LoginType": "GoogleLogin"
        };

        if (accountDetailList
                .where((element) => element["EmailAddress"] == url)
                .toList()
                .length ==
            0) {
          accountDetailList.add(accountDetail);
        } else {
          accountDetailList
              .where((element) => element["EmailAddress"] == url)
              .toList()[0] = accountDetail;
        }
        sharedPreferences.setString(
            "AccountDetailList", json.encode(accountDetailList));
      });

      //Save Credentials
      await storage.saveCredentials(authClient.credentials.accessToken,
          authClient.credentials.refreshToken.toString());
      return authClient;
    } else {
      //Already authenticated
      return authenticatedClient(
          http.Client(),
          AccessCredentials(
              AccessToken(credentials["type"], credentials["data"],
                  DateTime.parse(credentials["expiry"])),
              credentials["refreshToken"],
              _scopes));
    }
  }

  Future<void> _handleSignIn(String url) async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
        clientId:
            "183670288267-k6flall0oent8uie5g5rjvs5povk9oi8.apps.googleusercontent.com",
        scopes: [
          // gmail.GmailApi.gmailModifyScope,
          gmail.GmailApi.GmailModifyScope
        ]);
    try {
      GoogleSignInAccount user = await _googleSignIn.signIn();

      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;

      print(googleSignInAuthentication.accessToken);
      print(googleSignInAuthentication.idToken);
    } catch (error) {
      print("this is error ============> ");
      print(error);
    }
  }

  Future<List<gmail.Message>> getMessage() async {
    List<gmail.Message> data = [];
    //var client = await getHttpClient();
    await _googleSignIn.signInSilently();

    var client = await _googleSignIn.authenticatedClient();
    try {
      var mails = gmail.GmailApi(client);
      print('get message from gmail API');

      gmail.ListMessagesResponse fileList = await mails.users.messages
          .list("me", includeSpamTrash: false, maxResults: 15);
      print('Messages');
      print(fileList.toJson());
      var check = 0;
      for (var i = 0; i < fileList.messages.length; i++) {
        if (check == i)
          await mails.users.messages
              .get("me", "${fileList.messages[i].id}", format: "full")
              .then((res) {
            data.add(res);
            // print("LabelId ==> ${i+1} ${res.labelIds}");
            check = check + 1;
          });
      }
      // for (gmail.Message message in fileList.messages) {
      //   var res = await mails.users.messages
      //     .get("me", "${message.id}", format: "full");
      //   data.add(res);
      // }
    } catch (e) {
      // await this.storage.clear();
      // getMessage();
    }

    return data;
  }

  Future<void> setSeen(id) async {
    var client = await _googleSignIn.authenticatedClient();
    var mails = gmail.GmailApi(client);
    gmail.ModifyMessageRequest mod = gmail.ModifyMessageRequest();
    mod.removeLabelIds = ["UNREAD"];

    await mails.users.messages.modify(mod, "me", "$id").then((value) {
      print("success modify");
    }).catchError((error) {
      print("error modify $error");
    });
  }

  Future<List<gmail.Thread>> getThread() async {
    var client = await _googleSignIn.authenticatedClient();
    var mails = gmail.GmailApi(client);
    List<gmail.Thread> data = [];

    gmail.ListThreadsResponse threadsResponse = await mails.users.threads.list(
      'me',
      includeSpamTrash: false,
      maxResults: 10,
    );
    List<gmail.Thread> list = threadsResponse.threads;
    for (gmail.Thread item in list) {
      print('object');
      var thread = await mails.users.threads.get('me', '${item.id}');
      data.add(thread);
    }

    return data;
  }
}

class GmailMoel {
  final String recieveFrom;
  final String snippet;

  GmailMoel(this.recieveFrom, this.snippet);
}
