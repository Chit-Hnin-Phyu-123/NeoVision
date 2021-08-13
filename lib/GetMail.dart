import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    '183670288267-k6flall0oent8uie5g5rjvs5povk9oi8.apps.googleusercontent.com';
const _clientSecret = 'XzRGZ5NTDhg4lvm9zikPahB2';
const _scopes = [
  // gmail.GmailApi.gmailModifyScope,
  gmail.GmailApi.GmailModifyScope
];

class GMail {
  final storage = SecureStorage();
  //Get Authenticated Http Client
  Future<http.Client> getHttpClient() async {
    //Get Credentials
    var credentials = await storage.getCredential();
    if (credentials.isEmpty) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
          ClientId(_clientId, _clientSecret), _scopes, (url) {
        //Open Url in Browser
        launch(url);
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

  Future<List<gmail.Message>> getMessage() async {
    List<gmail.Message> data = [];
    var client = await getHttpClient();
    try {
      var mails = gmail.GmailApi(client);
      print('w');
      gmail.ListMessagesResponse fileList = await mails.users.messages
          .list("me", includeSpamTrash: false, maxResults: 15);
      print(fileList.toJson());
      for (gmail.Message message in fileList.messages) {
        var res = await mails.users.messages
            .get("me", "${message.id}", format: "full");
        data.add(res);
      }
    } catch (e) {
      // await this.storage.clear();
      // getMessage();
    }

    return data;
  }

  Future<List<gmail.Thread>> getThread() async {
    var client = await getHttpClient();
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



