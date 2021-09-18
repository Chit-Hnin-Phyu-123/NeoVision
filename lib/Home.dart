import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show File, Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'package:path_provider/path_provider.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'ChooseVoice.dart';
import 'GetMail.dart';
import 'Login.dart';
import 'SwitchAccount.dart';
import 'WordToNum.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

enum PopupMenuChoices { setting, voices, version, logout }

class _HomeState extends State<Home> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: [
    "email",
    "https://www.googleapis.com/auth/gmail.modify",
  ]);

  // FlutterTts flutterTts;
  String version = '1.0.16';
  String language;
  String engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  // TtsState ttsState = TtsState.stopped;

  // get isPlaying => ttsState == TtsState.playing;
  // get isStopped => ttsState == TtsState.stopped;
  // get isPaused => ttsState == TtsState.paused;
  // get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  int resultListened = 0;
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();
  List speechList = [];
  bool loading = true;
  bool readNext = true;

  @override
  initState() {
    openWelcomeVoice();
    initSpeechState();
    checkLoginType();
    super.initState();
  }

  Future<void> checkLoginType() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("LoginType") == "ImapLogin") {
      imapExample();
    } else if (sharedPreferences.getString("LoginType") == "GoogleLogin") {
      getMessage();
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    }
  }

  final mails = GMail();
  List<GmailMoel> list = [];

  int count = 0;

  Future getMessage() async {
    await mails.getMessage().then((value) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      value.forEach((message) {
        if (message.labelIds.contains("UNREAD")) {
          unseenEmailList.add(message.id);
        }
        if (message.payload == null) {
          //
        } else {
          // if(message.payload.parts.length == 0) {
          //   //
          // } else {
          //   var emailbody = utf8.decode(base64.decode(message.payload.parts[0].body.data));
          // }

          if (message.payload.headers.length != 0) {
            message.payload.headers.forEach((header) {
              if (header.name == "From" || header.value == "from") {
                var name = header.value.substring(0, header.value.indexOf('<'));
                var res = name.replaceAll('"', "");

                message.payload.headers.forEach((header2) {
                  if (header2.name == "Subject") {
                    var emailsubject = header2.value;

                    message.payload.headers.forEach((header3) {
                      if (header3.name == "Date") {
                        var date = header3.value;
                        DateFormat dateFormat =
                            DateFormat("dd MMM yyyy HH:mm:ss");
                        DateTime dateTime = dateFormat.parse(date.substring(5));
                        String onDate =
                            "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                        String atTime = "${dateTime.hour}:${dateTime.minute}";

                        emailList.add({
                          "Id": "${message.id}",
                          "From": "$res",
                          "Subject": "$emailsubject",
                          "Body": "${message.snippet}",
                          "On": "$onDate",
                          "At": "$atTime"
                        });

                        for (var a = 0; a < unseenEmailList.length; a++) {
                          if (unseenEmailList[a] == message.id) {
                            newEmailList.add({
                              "Id": "${message.id}",
                              "From": "$res",
                              "Subject": "$emailsubject",
                              "Body": "${message.snippet}",
                              "On": "$onDate",
                              "At": "$atTime"
                            });
                          }
                        }

                        print(emailList);
                      }
                    });
                  }
                });
              }

              // if (emailbody.indexOf("<https:") < 0) {
              //   emailbody = emailbody.replaceAll("==", "");
              //   emailList.add({
              //     "Id": "${message.id}",
              //     "From": "$res",
              //     "Subject": "$emailsubject",
              //     "Date": "",
              //     "To": ""
              //   });
              // } else {
              //   List httpList = emailbody.split("<htt");
              //   String realEmailBody = emailbody;
              //   httpList.forEach((element) {
              //     if (element.indexOf("ps://") < 0) {
              //       //
              //     } else {
              //       var httpValue = element.substring(
              //           element.indexOf("ps://"), (element.indexOf(">") + 1));
              //       realEmailBody = realEmailBody.replaceAll(httpValue, "");
              //       realEmailBody = realEmailBody.replaceAll("<htt", "");
              //     }
              //   });
              //   realEmailBody = realEmailBody.replaceAll("==", "");
              //   // this.list.add(GmailMoel("$res", "$realEmailBody"));
              //   emailList.add({
              //     "Id": "${message.id}",
              //     "From": "$res",
              //     "Subject": "$realEmailBody",
              //     "Date": "",
              //     "To": ""
              //   });
              // }
            });
          }
        }
      });
    });
    if (mounted) {
      setState(() {
        this.count = list.length;
      });
    }
  }

  List emailList = [];
  List unseenEmailList = [];
  List newEmailList = [];
  List oldEmailList = [];

  Future<void> imapExample() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userDetail = json.decode(sharedPreferences.getString("UserDetail"));

    // String userName = 'hwy@tastysoftcloud.com';
    // String password = 'htetwaiyanI\$l1tt';
    // String hostServer = "tastysoftcloud.com";
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
    }).catchError((error) {
      print("Connect Fail => $error");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
    await client.login(userName, password).then((value) {
      print("Login Success");
    }).catchError((error) {
      print("Login Error");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
    // final mailboxes = await client.listMailboxes();
    // print('mailboxes: ${mailboxes.result}');
    await client.selectInbox().then((value) {
      print("select inbox success");
    }).catchError((error) {
      print("select inbox fail");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
    List<MimeMessage> subjectList = [];

    await client.searchMessages('UNSEEN').then((value) {
      unseenEmailList = value.result.ids;
      print(value.result.ids);
    });

    await client
        .fetchRecentMessages(
            messageCount: 20, criteria: 'BODY.PEEK[HEADER.FIELDS (SUBJECT)]')
        .then((fetchResult) {
      print("fetchResult success");
      subjectList = fetchResult.result.messages;
    }).catchError((error) {
      print("error ==> $error");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });

    List<MimeMessage> fromList = [];

    await client
        .fetchRecentMessages(
            messageCount: 20, criteria: 'BODY.PEEK[HEADER.FIELDS (FROM)]')
        .then((fetchResult) {
      print("fetchResult success");
      fromList = fetchResult.result.messages;
      // for(var i = 0; i < fromList.length; i++) {
      //   print(fromList[i].from[0].personalName);
      // }
    }).catchError((error) {
      print("error ==> $error");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });

    List<MimeMessage> dateList = [];

    await client
        .fetchRecentMessages(
            messageCount: 20, criteria: 'BODY.PEEK[HEADER.FIELDS (DATE)]')
        .then((fetchResult) {
      print("fetchResult success");
      dateList = fetchResult.result.messages;
    }).catchError((error) {
      print("error ==> $error");
    });

    await getemailList(subjectList, fromList, dateList);
    await client.logout();
  }

  Future<void> getemailList(List<MimeMessage> subjectList,
      List<MimeMessage> fromList, List<MimeMessage> dateList) async {
    for (var i = 0; i < subjectList.length; i++) {
      for (var j = 0; j < fromList.length; j++) {
        if (subjectList[i].sequenceId == fromList[j].sequenceId) {
          for (var k = 0; k < dateList.length; k++) {
            if (subjectList[i].sequenceId == dateList[k].sequenceId) {
              DateTime dateTime = dateList[k].decodeHeaderDateValue("Date");
              String time = DateFormat.jm().format(
                  DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateTime.toString()));
              String time2 = time.substring(0, time.lastIndexOf(":"));
              String time3 = "";
              if (time2.length != 2) {
                time3 = "0" + time;
              } else {
                time3 = time;
              }
              String onDate =
                  "${dateTime.day}/${dateTime.month}/${dateTime.year}";
              String atTime = time3.substring(0, time.length - 3);
              print("$onDate =======> $atTime");

              if (emailList.length == 0) {
                if (subjectList[i].isTextPlainMessage()) {
                  emailList.add({
                    "Id": "${subjectList[i].sequenceId}",
                    "From": fromList[j].from[0].personalName,
                    "Subject": subjectList[i].decodeSubject(),
                    "Body": "",
                    "On": "$onDate",
                    "At": "$atTime",
                  });
                } else {
                  emailList.add({
                    "Id": "${subjectList[i].sequenceId}",
                    "From": fromList[j].from[0].personalName,
                    "Subject": subjectList[i].decodeTextPlainPart(),
                    "Body": "",
                    "On": "$onDate",
                    "At": "$atTime",
                  });
                }
              } else {
                if (emailList
                        .where((element) =>
                            element["From"] ==
                                fromList[j].from[0].personalName &&
                            element["Subject"] ==
                                subjectList[i].decodeSubject())
                        .toList()
                        .length ==
                    0) {
                  if (subjectList[i].isTextPlainMessage()) {
                    emailList.add({
                      "Id": "${subjectList[i].sequenceId}",
                      "From": fromList[j].from[0].personalName,
                      "Subject": subjectList[i].decodeSubject(),
                      "Body": "",
                      "On": "$onDate",
                      "At": "$atTime",
                    });
                  } else {
                    emailList.add({
                      "Id": "${subjectList[i].sequenceId}",
                      "From": fromList[j].from[0].personalName,
                      "Subject": subjectList[i].decodeTextPlainPart(),
                      "Body": "",
                      "On": "$onDate",
                      "At": "$atTime",
                    });
                  }
                }
              }
            }

            if (k == dateList.length - 1) {
              if (j == fromList.length - 1) {
                if (i == subjectList.length - 1) {
                  for (var k = 0; k < emailList.length; k++) {
                    for (var l = 0; l < unseenEmailList.length; l++) {
                      if (emailList[k]["Id"] == '${unseenEmailList[l]}') {
                        newEmailList.add(emailList[k]);
                      }
                    }
                  }
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  String lastSpeechWord = '';

  String chosenVoiceOwner = "";

  Map<String, dynamic> credentials;

  Future<void> getCredentialsFunc() async {
    final storage = SecureStorage();
    var cre = await storage.getCredential();
    if (mounted) {
      setState(() {
        credentials = cre;
      });
    }
  }

  Future openWelcomeVoice() async {
    readNext = false;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("ChooseVoice") == null) {
      chosenVoiceOwner = "Aria";
    } else {
      chosenVoiceOwner = json
          .decode(sharedPreferences.getString("ChooseVoice"))["DisplayName"];
    }

    // await flutterTts
    //     .setVoice({"name": "ja-jp-x-jab-local", "locale": "en-US"}).then((value) {
    //   print("Set Voice ======> $value");
    // });
    // await flutterTts.setVolume(volume);
    // await flutterTts.setSpeechRate(rate);
    // await flutterTts.setPitch(pitch);

    if (checkSpeech == true) {
      if (mounted) {
        setState(() {
          lastWords = "Welcome to Neo Vision";
        });
      }
    }

    checkSpeech = false;

    // await flutterTts.awaitSpeakCompletion(true);
    // await flutterTts.speak("Welcome to neo vision").whenComplete(() {
    //   checkSpeech = true;
    // });

    speak("Welcome to Neo Vision", "", false, "").then((value) {
      checkSpeech = true;
    });
  }

  Future<void> initSpeechState() async {
    requestPermission();
    var hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener, debugLogging: true);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    if (mounted) {
      setState(() {
        _hasSpeech = hasSpeech;
      });
    }
  }

  void startListening() {
    lastWords = '';
    lastError = '';
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 5),
        partialResults: true,
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
  }

  // Future _getDefaultEngine() async {
  //   var engine = await flutterTts.getEngines;
  //   if (engine != null) {
  //     print(engine);
  //   }
  // }

  String remainText;
  List remainTextList = [];

  bool checkSpeech = false;
  var check = 0;
  var valueCheck = 0;

  Future _speak(
      speechFromUser, text, String isReadAll, List readEmailList) async {
    readNext = false;
    // await flutterTts.setVolume(volume);
    // await flutterTts.setSpeechRate(rate);
    // await flutterTts.setPitch(pitch);
    // _stop().then((value) async {
    if (text != null) {
      if (text.isNotEmpty) {
        if (checkSpeech == true) {
          if (mounted) {
            setState(() {
              lastSpeechWord = text;
              lastWords = lastSpeechWord;
            });
          }
        }
        // await flutterTts.awaitSpeakCompletion(true);
        checkSpeech = false;
        if (isReadAll == "readEmailWithDate") {
          check = 0;
          if (isStop == true) {
          } else {

            String speechText =
                "${readEmailList[check]["Subject"]} From ${readEmailList[check]["From"]} On ${readEmailList[check]["On"]} At ${readEmailList[check]["At"]}.\n ${readEmailList[check]["Body"]}";
            
            await speakAll(speechText, speechFromUser,
                    readEmailList[check]["Id"], readEmailList)
                .then((value) {
              print("$speechText ========> $value");
              checkSpeech = true;

              if (mounted) {
                setState(() {
                  lastSpeechWord = speechText;
                  lastWords = lastSpeechWord;
                });
              }
            });

            String getsenderName = speechText.toString().substring(
                speechText.toString().lastIndexOf("From "),
                speechText.toString().length);
            String getSubject = speechText
                .toString()
                .substring(0, speechText.toString().lastIndexOf("From "));
            readEmail = {
              "From": getsenderName.replaceAll(" From ", ""),
              "Subject": getSubject
            };
          }
        } else if (isReadAll == "readall") {
          check = 0;
          valueCheck = 0;

          oldEmailList = emailList;

          List allEmailList = [];

          if (newEmailList.length == 0) {
            if (isStop == true) {
            } else {
              allEmailList = emailList;

              String speechText =
                  "${allEmailList[check]["Subject"]} From ${allEmailList[check]["From"]} On ${allEmailList[check]["On"]} At ${allEmailList[check]["At"]}.\n ${allEmailList[check]["Body"]}";
              // print("$check == $valueCheck");
              // if (check == valueCheck) {
              // if (a.toString() == "0") {
              //   check = 0;
              //   valueCheck = 0;
              // } else {
              //   speechFromUser = "";
              // }
              await speakAll(speechText, speechFromUser,
                      allEmailList[check]["Id"], allEmailList)
                  .then((value) {
                print("$speechText ========> $value");
                checkSpeech = true;

                if (mounted) {
                  setState(() {
                    lastSpeechWord = speechText;
                    lastWords = lastSpeechWord;
                  });
                }
              });

              String getsenderName = speechText.toString().substring(
                  speechText.toString().lastIndexOf("From "),
                  speechText.toString().length);
              String getSubject = speechText
                  .toString()
                  .substring(0, speechText.toString().lastIndexOf("From "));
              readEmail = {
                "From": getsenderName.replaceAll(" From ", ""),
                "Subject": getSubject
              };
              // }
            }
          } else {
            for (var a = 0; a < newEmailList.length; a++) {
              oldEmailList.removeWhere(
                  (element) => element["Id"] == newEmailList[a]["Id"]);

              if (a == newEmailList.length - 1) {
                List readNewEmail = [
                  {"Subject": "Read new emails"}
                ];
                List endOfNewEmail = [
                  {"Subject": "End of new emails"}
                ];

                allEmailList =
                    readNewEmail + newEmailList + endOfNewEmail + oldEmailList;

                String speechText = "";
                if (allEmailList[check]["From"] == null) {
                  speechText = allEmailList[check]["Subject"];
                } else {
                  speechText =
                      "${allEmailList[check]["Subject"]} From ${allEmailList[check]["From"]} On ${allEmailList[check]["On"]} At ${allEmailList[check]["At"]}.\n ${allEmailList[check]["Body"]}";
                }

                if (isStop == true) {
                } else {
                  // print("$check == $valueCheck");
                  // if (check == valueCheck) {
                  // if (a.toString() == "0") {
                  //   check = 0;
                  //   valueCheck = 0;
                  // } else {
                  //   speechFromUser = "";
                  // }
                  await speakAll(speechText, speechFromUser,
                          allEmailList[check]["Id"], allEmailList)
                      .then((value) {
                    print("$speechText ========> $value");
                    checkSpeech = true;

                    if (mounted) {
                      setState(() {
                        lastSpeechWord = speechText;
                        lastWords = lastSpeechWord;
                      });
                    }
                  });

                  String getsenderName = speechText.toString().substring(
                      speechText.toString().lastIndexOf("From "),
                      speechText.toString().length);
                  String getSubject = speechText
                      .toString()
                      .substring(0, speechText.toString().lastIndexOf("From "));
                  readEmail = {
                    "From": getsenderName.replaceAll(" From ", ""),
                    "Subject": getSubject
                  };
                  // }
                }
                // }
              }
            }
          }
        } else if (isReadAll == "readnew") {
          List unreadList = [];
          check = 0;
          print(emailList.length);
          print(unseenEmailList.length);
          for (var a = 0; a < emailList.length; a++) {
            for (var b = 0; b < unseenEmailList.length; b++) {
              if (emailList[a]["Id"].toString() ==
                  unseenEmailList[b].toString()) {
                unreadList.add(emailList[a]);
              }

              if (a == emailList.length - 1) {
                if (b == unseenEmailList.length - 1) {
                  // for (var c = 0; c < unreadList.length; c++) {
                  String speechText =
                      "${unreadList[check]["Subject"]} From ${unreadList[check]["From"]} On ${unreadList[check]["On"]} At ${unreadList[check]["At"]}.\n ${unreadList[check]["Body"]}";

                  if (isStop == true) {
                  } else {
                    // if (a.toString() == "0") {
                    //   check = 0;
                    //   valueCheck = 0;
                    // } else {
                    //   speechFromUser = "";
                    // }
                    // print("One =============> $c == $check");
                    // if (c == check) {
                    //   print("Two ==> $c == $check");
                    await speakNewEmail(speechText, speechFromUser,
                            unreadList[check]["Id"], unreadList)
                        .then((value) {
                      print("$speechText ========> $value");
                      checkSpeech = true;

                      if (mounted) {
                        setState(() {
                          lastSpeechWord = speechText;
                          lastWords = lastSpeechWord;
                        });
                      }
                    });

                    String getsenderName = speechText.toString().substring(
                        speechText.toString().lastIndexOf("From "),
                        speechText.toString().length);
                    String getSubject = speechText.toString().substring(
                        0, speechText.toString().lastIndexOf("From "));
                    readEmail = {
                      "From": getsenderName.replaceAll(" From ", ""),
                      "Subject": getSubject
                    };
                    // }
                  }
                  // }
                }
              }
            }
          }
        } else {
          print("object");
          if (text.toString().lastIndexOf("From ") < 0) {
            await speak(text, speechFromUser, isReadAll, "").whenComplete(() {
              checkSpeech = true;
              remainTextList.removeWhere((element) => element == text);
            });
          } else {
            String getsenderName = text.toString().substring(
                text.toString().lastIndexOf("From "), text.toString().length);

            print(getsenderName);

            String getSubject = text
                .toString()
                .substring(0, text.toString().lastIndexOf(" From "));

            print(getSubject);

            readEmail = {
              "From": getsenderName.replaceAll("From ", ""),
              "Subject": getSubject
            };

            String emailId = "";

            if (emailList
                    .where((element) =>
                        element["Subject"] == getSubject &&
                        element["From"] ==
                            getsenderName.replaceAll("From ", ""))
                    .toList()
                    .length ==
                0) {
              emailId = "";
            } else {
              emailId = emailList
                  .where((element) =>
                      element["Subject"] == getSubject &&
                      element["From"] == getsenderName.replaceAll("From ", ""))
                  .toList()[0]["Id"];
            }

            print("One");

            await speak(text, speechFromUser, isReadAll, emailId)
                .whenComplete(() {
              checkSpeech = true;
              remainTextList.removeWhere((element) => element == text);
            });
          }
        }
      }
    }
    // });
  }

  bool isStop = false;

  AudioPlayer audioPlayer;

  Future _stop() async {
    // var result = await flutterTts.stop();
    // if (result == 1) setState(() => ttsState = TtsState.stopped);
    audioPlayer.stop();
    isStop = true;
    readNext = true;
  }

  var readEmail;

  String userVoiceCommand = "";

  List voiceCommandList = [
    {"VoiceCommand": "check emails", "CurrentUse": false},
    {"VoiceCommand": "read new emails", "CurrentUse": false},
    {"VoiceCommand": "read emails", "CurrentUse": false}
  ];

  int currentVoiceCommand;

  String changeBtnColor;

  bool downloadAudioFile = false;

  Future<void> resultForRead(String text) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isStop = false;
        userVoiceCommand = text;
        if (text.toLowerCase() == "stop") {
          remainText = null;
          _stop();
        }
      });
    }

    if (text.toLowerCase().startsWith("check emails") ||
        text.toLowerCase().startsWith("check email") ||
        text.toLowerCase().startsWith("check my mail") ||
        text.toLowerCase().startsWith("check my mails") ||
        text.toLowerCase().startsWith("check my email") ||
        text.toLowerCase().startsWith("check my emails") ||
        text.toLowerCase().startsWith("check new email") ||
        text.toLowerCase().startsWith("check new emails") ||
        text.toLowerCase().startsWith("read new") ||
        text.toLowerCase().startsWith("read all") ||
        text.toLowerCase().startsWith("read email") ||
        text.toLowerCase().startsWith("read emails") ||
        text.toLowerCase().startsWith("read all email") ||
        text.toLowerCase().startsWith("read all emails") ||
        text.toLowerCase().startsWith("read new email") ||
        text.toLowerCase().startsWith("read new emails") ||
        text.toLowerCase().startsWith("read this") ||
        text.toLowerCase().startsWith("read it") ||
        text.toLowerCase().startsWith("read ") ||
        text.toLowerCase().startsWith("read email from") ||
        text.toLowerCase().startsWith("read emails from") ||
        text.toLowerCase().startsWith("stop") ||
        text.toLowerCase().startsWith("skip") ||
        text.toLowerCase().startsWith("next") ||
        text.toLowerCase().startsWith("Change Account") ||
        text.toLowerCase().startsWith("Switch Account")) {
      List accountDetailList = [];

      if (sharedPreferences.getString("AccountDetailList") == null ||
          sharedPreferences.getString("AccountDetailList") == "") {
        accountDetailList = [];
      } else {
        accountDetailList =
            json.decode(sharedPreferences.getString("AccountDetailList"));
      }

      if (text.toLowerCase() == "Change Account" ||
          text.toLowerCase() == "Switch Account") {
        if (accountDetailList.length == 1) {
          _speak(
              text,
              "You have ${accountDetailList.length} Account. It is ${accountDetailList[0]["EmailAddress"]}. Do you want to Login with this account?",
              "false", []);
        } else {
          String accounts = "";
          for (var j = 0; j < accountDetailList.length; j++) {
            if (j + 2 == accountDetailList.length) {
              accounts =
                  accounts + accountDetailList[j]["EmailAddress"] + " and ";
            } else {
              accounts = accounts + accountDetailList[j]["EmailAddress"] + ". ";
            }

            if (j == accountDetailList.length - 1) {
              _speak(
                  text,
                  "You have ${accountDetailList.length} Accounts. $accounts",
                  "false", []);
            }
          }
        }
      }

      if (userVoiceCommand.toLowerCase() == "change account" ||
          userVoiceCommand.toLowerCase() == "switch account") {
        if (text.toLowerCase() == "yes") {
          if (accountDetailList[0]["LoginType"] == "ImapLogin") {
            if (mounted) {
              setState(() {
                loading = true;
              });
            }

            var userDetail = {
              "EmailAddress": "${accountDetailList[0]["EmailAddress"]}",
              "HostServer": "${accountDetailList[0]["Password"]}",
              "ImapServerPort": accountDetailList[0]["HostServer"],
              "EmailPassword": "${accountDetailList[0]["ImapServerPort"]}"
            };
            sharedPreferences.setString("UserDetail", json.encode(userDetail));

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
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
            }).catchError((error) {
              print("Connect Fail => $error");
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
              _speak(text, "Connect fail!", "false", []);
            });
            await client.login(userName, password).then((value) {
              print("Login Success");
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }

              List accountDetailList = [];

              if (sharedPreferences.getString("AccountDetailList") == null ||
                  sharedPreferences.getString("AccountDetailList") == "") {
                accountDetailList = [];
              } else {
                accountDetailList = json
                    .decode(sharedPreferences.getString("AccountDetailList"));
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
                          element["EmailAddress"] == userDetail["EmailAddress"])
                      .toList()
                      .length ==
                  0) {
                accountDetailList.add(accountDetail);
              } else {
                accountDetailList
                    .where((element) =>
                        element["EmailAddress"] == userDetail["EmailAddress"])
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
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
              _speak(text, "Login fail!", "false", []);
            });
          } else if (accountDetailList[0]["LoginType"] == "GoogleLogin") {
            if (mounted) {
              setState(() {
                loading = true;
              });
            }
            await GMail().getHttpClient().then((value) {
              sharedPreferences.setString("LoginType", "GoogleLogin");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Home()),
                (Route<dynamic> route) => false,
              );
            }).catchError((error) {
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
              _speak(text, "Login fail!", "false", []);
            });
          }
        } else if (text.toLowerCase() == "no") {
          //
        } else if (text.toLowerCase().startsWith("change")) {
          int k = wordToNumber(text.toLowerCase().replaceAll("change ", ""));

          if (k > accountDetailList.length) {
            //
          } else {
            if (accountDetailList[k - 1]["LoginType"] == "ImapLogin") {
              if (mounted) {
                setState(() {
                  loading = true;
                });
              }

              var userDetail = {
                "EmailAddress": "${accountDetailList[k - 1]["EmailAddress"]}",
                "HostServer": "${accountDetailList[k - 1]["Password"]}",
                "ImapServerPort": accountDetailList[k - 1]["HostServer"],
                "EmailPassword": "${accountDetailList[k - 1]["ImapServerPort"]}"
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
                if (mounted) {
                  setState(() {
                    loading = false;
                  });
                }
              }).catchError((error) {
                print("Connect Fail => $error");
                if (mounted) {
                  setState(() {
                    loading = false;
                  });
                }
                _speak(text, "Connect fail!", "false", []);
              });
              await client.login(userName, password).then((value) {
                print("Login Success");
                if (mounted) {
                  setState(() {
                    loading = false;
                  });
                }

                List accountDetailList = [];

                if (sharedPreferences.getString("AccountDetailList") == null ||
                    sharedPreferences.getString("AccountDetailList") == "") {
                  accountDetailList = [];
                } else {
                  accountDetailList = json
                      .decode(sharedPreferences.getString("AccountDetailList"));
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
                          element["EmailAddress"] == userDetail["EmailAddress"])
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
                if (mounted) {
                  setState(() {
                    loading = false;
                  });
                }
                _speak(text, "Login fail!", "false", []);
              });
            } else if (accountDetailList[k - 1]["LoginType"] == "GoogleLogin") {
              if (mounted) {
                setState(() {
                  loading = true;
                });
              }
              await GMail().getHttpClient().then((value) {
                sharedPreferences.setString("LoginType", "GoogleLogin");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                  (Route<dynamic> route) => false,
                );
              }).catchError((error) {
                if (mounted) {
                  setState(() {
                    loading = false;
                  });
                }
                _speak(text, "Login fail!", "false", []);
              });
            }
          }
        } else {
          for (var j = 0; j < accountDetailList.length; j++) {
            if (text.toLowerCase() ==
                accountDetailList[j]["EmailAddress"].toString().toLowerCase()) {
              if (accountDetailList[j]["LoginType"] == "ImapLogin") {
                setState(() {
                  loading = true;
                });

                var userDetail = {
                  "EmailAddress": "${accountDetailList[j]["EmailAddress"]}",
                  "HostServer": "${accountDetailList[j]["Password"]}",
                  "ImapServerPort": accountDetailList[j]["HostServer"],
                  "EmailPassword": "${accountDetailList[j]["ImapServerPort"]}"
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
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }
                }).catchError((error) {
                  print("Connect Fail => $error");
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }
                  _speak(text, "Connect fail!", "false", []);
                });
                await client.login(userName, password).then((value) {
                  print("Login Success");
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }

                  List accountDetailList = [];

                  if (sharedPreferences.getString("AccountDetailList") ==
                          null ||
                      sharedPreferences.getString("AccountDetailList") == "") {
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
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }
                  _speak(text, "Login fail!", "false", []);
                });
              } else if (accountDetailList[j]["LoginType"] == "GoogleLogin") {
                if (mounted) {
                  setState(() {
                    loading = true;
                  });
                }
                await GMail().getHttpClient().then((value) {
                  sharedPreferences.setString("LoginType", "GoogleLogin");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    (Route<dynamic> route) => false,
                  );
                }).catchError((error) {
                  if (mounted) {
                    setState(() {
                      loading = false;
                    });
                  }
                  _speak(text, "Login fail!", "false", []);
                });
              }
            }
          }
        }
      }
      //
      if (text.toLowerCase() == "check email" ||
          text.toLowerCase() == "check emails" ||
          text.toLowerCase() == "check new email" ||
          text.toLowerCase() == "check new emails" ||
          text.toLowerCase() == "check my mail" ||
          text.toLowerCase() == "check my mails" ||
          text.toLowerCase() == "check my email" ||
          text.toLowerCase() == "check my emails") {
        if (unseenEmailList.length == 0) {
          if (mounted) {
            setState(() {
              loading = true;
            });
          }
          if (sharedPreferences.getString("LoginType") == "ImapLogin") {
            imapExample().then((value) {
              if (unseenEmailList.length == 0 || unseenEmailList.length == 1) {
                _speak(text, "There is ${unseenEmailList.length} New Email.",
                    "false", []);
              } else {
                _speak(text, "There are ${unseenEmailList.length} New Emails.",
                    "false", []);
              }
            });
          } else if (sharedPreferences.getString("LoginType") ==
              "GoogleLogin") {
            await mails.getMessage().then((value) {
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
              emailList = [];
              unseenEmailList = [];
              value.forEach((message) {
                if (message.labelIds.contains("UNREAD")) {
                  unseenEmailList.add(message.id);
                }
                if (message.payload == null) {
                  //
                } else {
                  if (message.payload.headers.length != 0) {
                    message.payload.headers.forEach((header) {
                      if (header.name == "From" || header.value == "from") {
                        var name = header.value
                            .substring(0, header.value.indexOf('<'));
                        var res = name.replaceAll('"', "");

                        message.payload.headers.forEach((header2) {
                          if (header2.name == "Subject") {
                            var emailsubject = header2.value;

                            message.payload.headers.forEach((header3) {
                              if (header3.name == "Date") {
                                var date = header3.value;
                                DateFormat dateFormat =
                                    DateFormat("dd MMM yyyy HH:mm:ss");
                                DateTime dateTime =
                                    dateFormat.parse(date.substring(5));
                                String onDate =
                                    "${dateTime.day}/${dateTime.month}/${dateTime.year}";
                                String atTime =
                                    "${dateTime.hour}:${dateTime.minute}";

                                emailList.add({
                                  "Id": "${message.id}",
                                  "From": "$res",
                                  "Subject": "$emailsubject",
                                  "Body": "${message.snippet}",
                                  "On": "$onDate",
                                  "At": "$atTime"
                                });

                                for (var a = 0;
                                    a < unseenEmailList.length;
                                    a++) {
                                  if (unseenEmailList[a] == message.id) {
                                    newEmailList.add({
                                      "Id": "${message.id}",
                                      "From": "$res",
                                      "Subject": "$emailsubject",
                                      "Body": "${message.snippet}",
                                      "On": "$onDate",
                                      "At": "$atTime"
                                    });
                                  }
                                }
                              }
                            });
                          }
                        });
                      }
                    });
                  }
                }
              });

              if (unseenEmailList.length == 0 || unseenEmailList.length == 1) {
                _speak(text, "There is ${unseenEmailList.length} New Email.",
                    "false", []);
              } else {
                _speak(text, "There are ${unseenEmailList.length} New Emails.",
                    "false", []);
              }
            });
          }
        } else {
          if (unseenEmailList.length == 0 || unseenEmailList.length == 1) {
            _speak(text, "There is ${unseenEmailList.length} New Email.",
                "false", []);
          } else {
            _speak(text, "There are ${unseenEmailList.length} New Emails.",
                "false", []);
          }
        }
      }

      if (text.toLowerCase() == "read new" ||
          text.toLowerCase() == "read new email" ||
          text.toLowerCase() == "read new emails") {
        print("The text is ==> " + text);
        await _speak(text, "$text", "readnew", []);
      }
      if (text.toLowerCase() == "read all" ||
          text.toLowerCase() == "read all email" ||
          text.toLowerCase() == "read all emails" ||
          text.toLowerCase() == "read email" ||
          text.toLowerCase() == "read emails") {
        // check = 0;
        print("The text is ==> " + text);
        await _speak(text, "$text", "readall", []);
      } else {
        if (text.toLowerCase() == "read this" ||
            text.toLowerCase() == "read it") {
          _speak(text, "$lastSpeechWord", "false", []);
        }
        if (text.toLowerCase().startsWith("read email from ") &&
            emailList.length != 0) {
          String getsender =
              text.toLowerCase().replaceAll("read email from ", "");
          List specificEmail = emailList
              .where((element) =>
                  element["From"].toString().toLowerCase() ==
                  getsender.toLowerCase())
              .toList();
          if (specificEmail.length == 0) {
            _speak(text, "You have no email from this user.", "false", []);
          } else {
            _speak(text, "${specificEmail[0]["Subject"]}", "false", []);
          }
        } else if (text.toLowerCase().startsWith("read emails from ") &&
            emailList.length != 0) {
          String getsender =
              text.toLowerCase().replaceAll("read emails from ", "");
          List specificEmail = emailList
              .where((element) =>
                  element["From"].toString().toLowerCase() ==
                  getsender.toLowerCase())
              .toList();
          if (specificEmail.length == 0) {
            _speak(text, "You have no email from this user.", "false", []);
          } else {
            _speak(text, "${specificEmail[0]["Subject"]}", "false", []);
          }
        } else if (text.toLowerCase().startsWith("read ") &&
            emailList.length != 0) {
          int indexNum =
              wordToNumber(text.toLowerCase().replaceAll("read ", ""));

          if (indexNum > emailList.length) {
            //
          } else {
            if (indexNum != 0) {
              _speak(
                  text,
                  "${emailList[indexNum - 1]["Subject"]} From ${emailList[indexNum - 1]["From"]}",
                  "false", []);
            }
          }
        }
      }

      if (text.toLowerCase() == "read today email" ||
          text.toLowerCase() == "read today emails" ||
          text.toLowerCase() == "read today's email" ||
          text.toLowerCase() == "read today's emails") {
        DateTime dateTime = DateTime.now();
        String todayDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
        List todayEmail =
            emailList.where((element) => element["On"] == todayDate).toList();
        await _speak(text, "$text", "readEmailWithDate", todayEmail);
      }

      if (text.toLowerCase() == "read yesterday email" ||
          text.toLowerCase() == "read yesterday emails" ||
          text.toLowerCase() == "read yesterday's email" ||
          text.toLowerCase() == "read yesterday's emails") {
        DateTime dateTime = DateTime.now().subtract(Duration(days:1));
        String yesterday = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
        List yesterdayEmail =
            emailList.where((element) => element["On"] == yesterday).toList();
        await _speak(text, "$text", "readEmailWithDate", yesterdayEmail);
      }

      if (text.toLowerCase() == "read the day before yesterday email" ||
          text.toLowerCase() == "read the day before yesterday emails" ||
          text.toLowerCase() == "read the day before yesterday's email" ||
          text.toLowerCase() == "read the day before yesterday's emails") {
        DateTime dateTime = DateTime.now().subtract(Duration(days:2));
        String theDay = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
        List emailOnThatDay =
            emailList.where((element) => element["On"] == theDay).toList();
        await _speak(text, "$text", "readEmailWithDate", emailOnThatDay);
      }

      if (text.toLowerCase() == "read this week email" ||
          text.toLowerCase() == "read this week emails" ||
          text.toLowerCase() == "read this week's email" ||
          text.toLowerCase() == "read this week's emails") {
        List<DateTime> weekDayList = [];
        DateTime firstWeekDay = DateTime.now().subtract(Duration(days:DateTime.now().weekday-1));
        weekDayList.add(firstWeekDay);
        for(var aa = 0; aa < DateTime.now().weekday-1; aa++) {
          DateTime lastWeekDay = firstWeekDay.add(Duration(days: aa+1));
          weekDayList.add(lastWeekDay);
        }

        List emailOnThatDay = [];

        for(var a = 0; a < weekDayList.length; a++) {
          String theDay = "${weekDayList[a].day}/${weekDayList[a].month}/${weekDayList[a].year}";
          emailOnThatDay = emailOnThatDay + emailList.where((element) => element["On"] == theDay).toList();
        }
        
        await _speak(text, "$text", "readEmailWithDate", emailOnThatDay);
      }

      if (text.toLowerCase() == "read this month email" ||
          text.toLowerCase() == "read this month emails" ||
          text.toLowerCase() == "read this month's email" ||
          text.toLowerCase() == "read this month's emails") {
        DateTime dateTime = DateTime.now();
        List emailOnThatDay =
            emailList.where((element) => element["On"].substring(element["On"].indexOf("/")+1, element["On"].lastIndexOf("/")) == dateTime.month).toList();
        await _speak(text, "$text", "readEmailWithDate", emailOnThatDay);
      }

      if ((text.toLowerCase() == "skip" || text.toLowerCase() == "next") &&
          emailList.length != 0) {
        if (readEmail != null &&
            emailList.indexWhere((element) =>
                    element["From"] == readEmail["From"] &&
                    element["Subject"] == readEmail["Subject"]) !=
                emailList.length - 1) {
          _speak(
              text,
              "${emailList[emailList.indexWhere((element) => element["From"] == readEmail["From"] && element["Subject"] == readEmail["Subject"]) + 1]["Subject"]} From ${emailList[emailList.indexWhere((element) => element["From"] == readEmail["From"] && element["Subject"] == readEmail["Subject"]) + 1]["From"]}",
              "false", []);
        } else {
          _speak(
              text,
              "${emailList[0]["Subject"]} From ${emailList[0]["From"]}",
              "false", []);
        }
      }
    } else {
      if (remainTextList.length != 0) {
        for (var b = 0; b < remainTextList.length; b++) {
          if (remainText == null) {
            remainText = remainTextList[b];
          } else {
            remainText = remainText + " " + remainTextList[b];
          }

          if (b == remainTextList.length - 1) {
            if (remainText != null) {
              if (remainText.length != 0) {
                _speak(text, remainText, "false", []);
              }
            }
          }
        }
      }
    }
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   flutterTts.stop();
  // }

  void requestPermission() async {
    PermissionStatus permission;
    permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.microphone]);
    } else if (permission == PermissionStatus.denied) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    }
  }

  DateTime _accessTokenTimestamp;
  String _accessToken;

  Future<String> _getAccessToken() async {
    if (_accessTokenTimestamp == null ||
        (_accessTokenTimestamp.difference(DateTime.now()).inMinutes >= 9)) {
      _accessTokenTimestamp = DateTime.now();
      await _updateAccessToken();
    }
    return _accessToken;
  }

  Future<void> _updateAccessToken() async {
    String url =
        "https://eastasia.api.cognitive.microsoft.com/sts/v1.0/issueToken";
    Map<String, String> headers = {
      'Ocp-Apim-Subscription-Key': "e1c84c3aee8e4c72b03103155178f443"
    };
    http.Response response = await http.post(url, headers: headers);
    _accessToken = response.body;
  }

  ScrollController controller = ScrollController();

  Future<String> speak(String text, String textfromUser, isReadAll, id) async {
    print("The Text is ========> $text");
    if (mounted) {
      setState(() {
        downloadAudioFile = true;
      });
    }
    String xmlLang;
    String xmlGender;
    String xmlName;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("ChooseVoice") == null) {
      xmlLang = "en-US";
      xmlGender = "Female";
      xmlName = "en-US-AriaNeural";
    } else {
      var getChooseVoice =
          json.decode(sharedPreferences.getString("ChooseVoice"));
      xmlLang = "${getChooseVoice["Locale"]}";
      xmlGender = "${getChooseVoice["Gender"]}";
      xmlName = "${getChooseVoice["ShortName"]}";
    }
    xml.XmlBuilder builder = xml.XmlBuilder();
    builder.element('speak', nest: () {
      builder.attribute('version', '1.0');
      builder.attribute('xml:lang', '$xmlLang');
      builder.element('voice', nest: () {
        builder.attribute('xml:lang', '$xmlLang');
        builder.attribute('xml:gender', '$xmlGender');
        builder.attribute('name', '$xmlName');
        builder.text(text);
      });
    });

    String body = builder.build().toXmlString();

    String url =
        "https://eastasia.tts.speech.microsoft.com/cognitiveservices/v1";
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _getAccessToken(),
      'cache-control': 'no-cache',
      'User-Agent': 'TTSPackage',
      'X-Microsoft-OutputFormat': 'riff-24khz-16bit-mono-pcm',
      'Content-Type': 'application/ssml+xml'
    };

    http.Response request = await http.post(url, headers: headers, body: body);

    Uint8List bytes = request.bodyBytes;

    final dir = await getApplicationDocumentsDirectory();
    DateTime dateTime = DateTime.now();
    String newfileName =
        "${dateTime.year}${dateTime.month}${dateTime.day}${dateTime.hour}${dateTime.minute}${dateTime.second}${dateTime.millisecond}";
    final file = new File('${dir.path}/$newfileName.mp3');

    file.writeAsBytesSync(bytes);

    file.exists().then((value) {
      print(value);
      readNext = true;
      if (mounted) {
        setState(() {
          downloadAudioFile = false;
        });
      }
      if (text == "Welcome to Neo Vision") {
        //
        readNext = true;
      } else {
        if (mounted) {
          setState(() {
            speechList.add({"fromApp": "$text", "fromUser": "$textfromUser"});
            if (controller.hasClients == true) {
              controller.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            }
          });
        }
      }

      audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
      AudioPlayer.logEnabled = false;

      audioPlayer.play(file.path, isLocal: true).then((value) {
        print("success =========> $value");
        check = check + 1;
        readNext = true;
        if (sharedPreferences.getString("LoginType") == "GoogleLogin") {
          mails.setSeen(id);
          unseenEmailList.removeWhere((element) => element.toString() == id);
          newEmailList.removeWhere((element) => element.toString() == id);
          oldEmailList.add(emailList[check]);
        } else if (sharedPreferences.getString("LoginType") == "ImapLogin") {
          imapSeen(id, emailList[check]);
        }
      }).catchError((error) {
        print("error =======> $error");
        readNext = true;
      });
    }).catchError((error) {
      if (mounted) {
        setState(() {
          downloadAudioFile = false;
        });
      }
    });

    return "complete";
  }

  Future<String> speakAll(
      String text, String textfromUser, id, List userEmailList) async {
    print("The Text is ========> $text");
    if (mounted) {
      setState(() {
        downloadAudioFile = true;
      });
    }
    String xmlLang;
    String xmlGender;
    String xmlName;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("ChooseVoice") == null) {
      xmlLang = "en-US";
      xmlGender = "Female";
      xmlName = "en-US-AriaNeural";
    } else {
      var getChooseVoice =
          json.decode(sharedPreferences.getString("ChooseVoice"));
      xmlLang = "${getChooseVoice["Locale"]}";
      xmlGender = "${getChooseVoice["Gender"]}";
      xmlName = "${getChooseVoice["ShortName"]}";
    }
    xml.XmlBuilder builder = xml.XmlBuilder();
    builder.element('speak', nest: () {
      builder.attribute('version', '1.0');
      builder.attribute('xml:lang', '$xmlLang');
      builder.element('voice', nest: () {
        builder.attribute('xml:lang', '$xmlLang');
        builder.attribute('xml:gender', '$xmlGender');
        builder.attribute('name', '$xmlName');
        builder.text(text);
      });
    });

    String body = builder.build().toXmlString();

    String url =
        "https://eastasia.tts.speech.microsoft.com/cognitiveservices/v1";
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _getAccessToken(),
      'cache-control': 'no-cache',
      'User-Agent': 'TTSPackage',
      'X-Microsoft-OutputFormat': 'riff-24khz-16bit-mono-pcm',
      'Content-Type': 'application/ssml+xml'
    };

    http.Response request = await http.post(url, headers: headers, body: body);

    Uint8List bytes = request.bodyBytes;

    final dir = await getApplicationDocumentsDirectory();
    DateTime dateTime = DateTime.now();
    String newfileName =
        "${dateTime.year}${dateTime.month}${dateTime.day}${dateTime.hour}${dateTime.minute}${dateTime.second}${dateTime.millisecond}";
    final file = new File('${dir.path}/$newfileName.mp3');

    file.writeAsBytesSync(bytes);

    file.exists().then((value) async {
      if (mounted) {
        setState(() {
          downloadAudioFile = false;
        });
      }
      readEmail = {
        "From": userEmailList[check]["From"],
        "Subject": userEmailList[check]["Subject"]
      };
      if (text == "Welcome to Neo Vision") {
        //
        readNext = true;
      } else {
        if (mounted) {
          setState(() {
            if (check == 0) {
              speechList.add({"fromApp": "$text", "fromUser": "$textfromUser"});
            } else {
              speechList.add({"fromApp": "$text", "fromUser": ""});
            }

            if (controller.hasClients == true) {
              controller.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            }
          });
        }
      }

      audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

      AudioPlayer.logEnabled = false;

      await audioPlayer
          .play(file.path, isLocal: true)
          .then((value) {})
          .catchError((error) {
        print("error =======> $error");
      });

      audioPlayer.onPlayerCompletion.listen((event) async {
        audioPlayer.stop();
        if (sharedPreferences.getString("LoginType") == "GoogleLogin") {
          mails.setSeen(id);
          unseenEmailList.removeWhere((element) => element.toString() == id);
          newEmailList.removeWhere((element) => element.toString() == id);
          oldEmailList.add(userEmailList[check]);
        } else if (sharedPreferences.getString("LoginType") == "ImapLogin") {
          imapSeen(id, userEmailList[check]);
        }
        if (check + 1 != userEmailList.length) {
          check = check + 1;
          valueCheck = valueCheck + 1;
          readNext = true;
          String speechText = "";
          if (userEmailList[check]["From"] == null) {
            speechText = userEmailList[check]["Subject"];
          } else {
            speechText =
                "${userEmailList[check]["Subject"]} From ${userEmailList[check]["From"]} On ${userEmailList[check]["On"]} At ${userEmailList[check]["At"]}.\n ${userEmailList[check]["Body"]}";
          }
          await speakAll(speechText, textfromUser, userEmailList[check]["Id"],
              userEmailList);
        }
      });
    });

    return "complete";
  }

  Future<String> speakNewEmail(
      String text, String textfromUser, id, List emailList) async {
    print("The Text is ========> $text");
    if (mounted) {
      setState(() {
        downloadAudioFile = true;
      });
    }
    String xmlLang;
    String xmlGender;
    String xmlName;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("ChooseVoice") == null) {
      xmlLang = "en-US";
      xmlGender = "Female";
      xmlName = "en-US-AriaNeural";
    } else {
      var getChooseVoice =
          json.decode(sharedPreferences.getString("ChooseVoice"));
      xmlLang = "${getChooseVoice["Locale"]}";
      xmlGender = "${getChooseVoice["Gender"]}";
      xmlName = "${getChooseVoice["ShortName"]}";
    }
    xml.XmlBuilder builder = xml.XmlBuilder();
    builder.element('speak', nest: () {
      builder.attribute('version', '1.0');
      builder.attribute('xml:lang', '$xmlLang');
      builder.element('voice', nest: () {
        builder.attribute('xml:lang', '$xmlLang');
        builder.attribute('xml:gender', '$xmlGender');
        builder.attribute('name', '$xmlName');
        builder.text(text);
      });
    });

    String body = builder.build().toXmlString();

    String url =
        "https://eastasia.tts.speech.microsoft.com/cognitiveservices/v1";
    Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _getAccessToken(),
      'cache-control': 'no-cache',
      'User-Agent': 'TTSPackage',
      'X-Microsoft-OutputFormat': 'riff-24khz-16bit-mono-pcm',
      'Content-Type': 'application/ssml+xml'
    };

    http.Response request = await http.post(url, headers: headers, body: body);

    Uint8List bytes = request.bodyBytes;

    final dir = await getApplicationDocumentsDirectory();
    DateTime dateTime = DateTime.now();
    String newfileName =
        "${dateTime.year}${dateTime.month}${dateTime.day}${dateTime.hour}${dateTime.minute}${dateTime.second}${dateTime.millisecond}";
    final file = new File('${dir.path}/$newfileName.mp3');

    file.writeAsBytesSync(bytes);

    file.exists().then((value) async {
      if (mounted) {
        setState(() {
          downloadAudioFile = false;
        });
      }
      readEmail = {
        "From": emailList[check]["From"],
        "Subject": emailList[check]["Subject"]
      };
      if (text == "Welcome to Neo Vision") {
        //
        readNext = true;
      } else {
        if (mounted) {
          setState(() {
            if (check == 0) {
              speechList.add({"fromApp": "$text", "fromUser": "$textfromUser"});
            } else {
              speechList.add({"fromApp": "$text", "fromUser": ""});
            }

            if (controller.hasClients == true) {
              controller.animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
              );
            }
          });
        }
      }

      audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

      AudioPlayer.logEnabled = false;

      await audioPlayer
          .play(file.path, isLocal: true)
          .then((value) {})
          .catchError((error) {
        print("error =======> $error");
      });

      audioPlayer.onPlayerCompletion.listen((event) async {
        audioPlayer.stop();
        if (sharedPreferences.getString("LoginType") == "GoogleLogin") {
          mails.setSeen(id);
          unseenEmailList.removeWhere((element) => element.toString() == id);
          newEmailList.removeWhere((element) => element.toString() == id);
          oldEmailList.add(emailList[check]);
        } else if (sharedPreferences.getString("LoginType") == "ImapLogin") {
          imapSeen(id, emailList[check]);
        }
        if (check + 1 != emailList.length) {
          check = check + 1;
          valueCheck = valueCheck + 1;
          readNext = true;
          String speechText =
              "${emailList[check]["Subject"]} From ${emailList[check]["From"]} On ${emailList[check]["On"]} At ${emailList[check]["At"]}.\n ${emailList[check]["Body"]}";
          await speakNewEmail(
              speechText, textfromUser, emailList[check]["Id"], emailList);
        }
      });
    });

    return "complete";
  }

  Future imapSeen(id, emaildata) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var userDetail = json.decode(sharedPreferences.getString("UserDetail"));

    // String userName = 'hwy@tastysoftcloud.com';
    // String password = 'htetwaiyanI\$l1tt';
    // String hostServer = "tastysoftcloud.com";
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
    }).catchError((error) {
      print("Connect Fail => $error");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
    await client.login(userName, password).then((value) {
      print("Login Success");
    }).catchError((error) {
      print("Login Error");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });

    await client.selectInbox().then((value) {
      print("select inbox success");
    }).catchError((error) {
      print("select inbox fail");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });

    List<MimeMessage> subjectList = [];

    await client
        .fetchRecentMessages(
            messageCount: 20, criteria: 'BODY.PEEK[HEADER.FIELDS (SUBJECT)]')
        .then((fetchResult) {
      print("fetchResult success");
      subjectList = fetchResult.result.messages;

      for (var i = 0; i < subjectList.length; i++) {
        // print(subjectList[i].flags);

        if (subjectList[i].sequenceId.toString() == id) {
          MessageSequence messageSequence = MessageSequence();
          print("ready to seen function");
          messageSequence.addSequenceId(subjectList[i]);

          client.markSeen(messageSequence).then((value) {
            print("Mark Seen Success");
            unseenEmailList.removeWhere((element) => element.toString() == id);
            newEmailList.removeWhere((element) => element.toString() == id);
            oldEmailList.add(emaildata);
            // print(subjectList[i].flags);
          }).catchError((error) {
            print("Mark Seen Error $error");
          });
        } else {
          // print("not Match");
        }
      }
    }).catchError((error) {
      print("error ==> $error");
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    });
  }

  onMenuSelection(PopupMenuChoices value) async {
    switch (value) {
      case PopupMenuChoices.setting:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SwitchAccount()));
        break;
      case PopupMenuChoices.voices:
        var newVoice = await Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChooseVoice()));

        if (mounted) {
          setState(() {
            chosenVoiceOwner = newVoice;
          });
        }
        break;
      case PopupMenuChoices.version:
        //
        break;
      case PopupMenuChoices.logout:
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.clear();
        final storage = SecureStorage();
        storage.clear();
        try {
          _googleSignIn.disconnect();
        } on Exception catch (e) {
          print(e);
        }
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    getCredentialsFunc();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 10, top: 40),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          loading || downloadAudioFile
                              ? Row(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.5)),
                                      width: 14,
                                      height: 14,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        backgroundColor: Colors.blue,
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      )),
                                    ),
                                    Text(" downloading data ..."),
                                  ],
                                )
                              : Container(),
                          PopupMenuButton<dynamic>(
                            onSelected: (value) => onMenuSelection(value),
                            icon: Icon(Icons.more_vert,
                                size: 30, color: Colors.black),
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem<PopupMenuChoices>(
                                  value: PopupMenuChoices.setting,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.settings,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 10),
                                      Text("Setting",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[600],
                                              fontFamily: "Abel-Regular")),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<PopupMenuChoices>(
                                  value: PopupMenuChoices.voices,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.volume_up,
                                          color: Colors.grey[600]),
                                      SizedBox(width: 10),
                                      Text("Voice [$chosenVoiceOwner]",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[600],
                                              fontFamily: "Abel-Regular")),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<PopupMenuChoices>(
                                  value: PopupMenuChoices.version,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(Icons.cloud_circle,
                                          color: Colors.grey[600]),
                                      SizedBox(width: 10),
                                      Text("Version $version",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[600],
                                              fontFamily: "Abel-Regular")),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<PopupMenuChoices>(
                                  value: PopupMenuChoices.logout,
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.exit_to_app,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 10),
                                      Text("Logout",
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey[600],
                                              fontFamily: "Abel-Regular")),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          )
                        ],
                      ),
                      // Align(
                      //     alignment: Alignment.topRight,
                      //     child: ),
                      Container(
                        height: 130,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: speech.isListening
                              ? Center(
                                  child: Text(
                                    "Listening...",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                )
                              : speechList.length == 0
                                  ? Center(
                                      child: Text("Welcome to Neo Vision.",
                                          style: TextStyle(fontSize: 15)),
                                    )
                                  : ListView(
                                      controller: controller,
                                      reverse: true,
                                      scrollDirection: Axis.vertical,
                                      children: [
                                        for (var a = 0;
                                            a <
                                                speechList.reversed
                                                    .toList()
                                                    .length;
                                            a++)
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              if (speechList.reversed
                                                      .toList()[a]["fromUser"]
                                                      .toString()
                                                      .length !=
                                                  0)
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          color: Colors.blue,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      12)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Text(
                                                          "${speechList.reversed.toList()[a]["fromUser"]}",
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      )),
                                                ),
                                              if (speechList.reversed
                                                      .toList()[a]["fromApp"]
                                                      .toString()
                                                      .length !=
                                                  0)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors
                                                                .grey[300],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: Text(
                                                            "${speechList.reversed.toList()[a]["fromApp"]}",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                            ],
                                          ),
                                      ],
                                    ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            shape: BoxShape.circle),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                splashColor: Colors.blue[100],
                                highlightColor: Colors.transparent,
                                radius: 50,
                                onTap: () {
                                  // print("Top");
                                  // if (readNext == true) {
                                  //   _speak("", "$userVoiceCommand", "false");
                                  // }
                                  _stop();
                                  if (readNext == true) {
                                    if (mounted) {
                                      setState(() {
                                        changeBtnColor = "top";
                                      });
                                    }
                                    if (currentVoiceCommand == null) {
                                      currentVoiceCommand = 0;
                                    } else if (currentVoiceCommand ==
                                        voiceCommandList.length - 1) {
                                      currentVoiceCommand = 0;
                                    } else {
                                      currentVoiceCommand =
                                          currentVoiceCommand + 1;
                                    }
                                    for (var a = 0;
                                        a < voiceCommandList.length;
                                        a++) {
                                      voiceCommandList[a]["CurrentUse"] = false;
                                    }
                                    _speak(
                                        "",
                                        "${voiceCommandList[currentVoiceCommand]["VoiceCommand"]}",
                                        "false", []);
                                  }
                                },
                                child: Container(
                                  height: MediaQuery.of(context).size.width / 3,
                                  child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Icon(
                                        Icons.arrow_drop_up,
                                        color: changeBtnColor == "top"
                                            ? Colors.blue[200]
                                            : Colors.grey,
                                        size: 120,
                                      )),
                                ),
                              ),
                              Container(
                                height: MediaQuery.of(context).size.width / 2.5,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: InkWell(
                                          splashColor: Colors.blue[100],
                                          highlightColor: Colors.transparent,
                                          radius: 50,
                                          onTap: () {
                                            print("Left");
                                            _stop().then((value) {
                                              if (mounted) {
                                                setState(() {
                                                  changeBtnColor = "left";
                                                });
                                              }
                                              if (readNext == true) {
                                                if (emailList.length == 0) {
                                                  _speak(
                                                      "",
                                                      "There is no email.",
                                                      "false", []);
                                                } else {
                                                  if (readEmail != null &&
                                                      emailList.indexWhere((element) =>
                                                              element["From"] ==
                                                                  readEmail[
                                                                      "From"] &&
                                                              element["Subject"] ==
                                                                  readEmail[
                                                                      "Subject"]) !=
                                                          0) {
                                                    _speak(
                                                        "",
                                                        "${emailList[emailList.indexWhere((element) => element["From"] == readEmail["From"] && element["Subject"] == readEmail["Subject"]) - 1]["Subject"]} From ${emailList[emailList.indexWhere((element) => element["From"] == readEmail["From"] && element["Subject"] == readEmail["Subject"]) - 1]["From"]}",
                                                        "false", []);
                                                  } else {
                                                    _speak(
                                                        "",
                                                        "${emailList[0]["Subject"]} From ${emailList[0]["From"]}",
                                                        "false", []);
                                                  }
                                                }
                                              }
                                            });
                                          },
                                          child: Container(
                                            child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Icon(
                                                  Icons.arrow_left,
                                                  color:
                                                      changeBtnColor == "left"
                                                          ? Colors.blue[200]
                                                          : Colors.grey,
                                                  size: 120,
                                                )),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onLongPress: () async {
                                          if (mounted) {
                                            setState(() {
                                              changeBtnColor = "center";
                                            });
                                          }
                                          _stop();
                                          audioPlayer.play("https://www.soundjay.com/buttons/sounds/beep-08b.mp3");
                                          audioPlayer.onPlayerCompletion.listen((event) async {
                                            audioPlayer.stop();
                                            startListening();
                                          });
                                        },
                                        onTap: () {
                                          // center button
                                          _stop();
                                          if (mounted) {
                                            setState(() {
                                              changeBtnColor = "center";
                                            });
                                          }

                                          if (
                                              // voiceCommandList[currentVoiceCommand]["VoiceCommand"] !=
                                              //       userVoiceCommand &&
                                              voiceCommandList[
                                                          currentVoiceCommand]
                                                      ["CurrentUse"] ==
                                                  false) {
                                            voiceCommandList[
                                                    currentVoiceCommand]
                                                ["CurrentUse"] = true;
                                            for (var a = 0;
                                                a < voiceCommandList.length;
                                                a++) {
                                              if (a != currentVoiceCommand) {
                                                voiceCommandList[a]
                                                    ["CurrentUse"] = false;
                                              }
                                            }
                                            resultForRead(voiceCommandList[
                                                    currentVoiceCommand]
                                                ["VoiceCommand"]);
                                          } else {
                                            print("stop");
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.5,
                                          child: Center(
                                              child: Container(
                                            decoration: BoxDecoration(
                                                color:
                                                    changeBtnColor == "center"
                                                        ? Colors.blue[100]
                                                        : Colors.grey[200],
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white)),
                                          )),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          splashColor: Colors.blue[100],
                                          highlightColor: Colors.transparent,
                                          radius: 50,
                                          onTap: () {
                                            _stop().then((value) {
                                              print("Right");
                                              if (mounted) {
                                                setState(() {
                                                  changeBtnColor = "right";
                                                });
                                              }
                                              if (readNext == true) {
                                                if (emailList.length == 0) {
                                                  _speak(
                                                      "",
                                                      "There is no email.",
                                                      "false", []);
                                                } else {
                                                  // print("jjjjjjjjjj=> " + lastReadMail.toString());
                                                  if (readEmail != null &&
                                                      emailList.indexWhere((element) =>
                                                              element["From"] ==
                                                                  readEmail[
                                                                      "From"] &&
                                                              element["Subject"] ==
                                                                  readEmail[
                                                                      "Subject"]) !=
                                                          emailList.length -
                                                              1) {
                                                    // for(var aa = 0; aa< readEmail["Subject"].toString().length; aa++) {
                                                    //   print("aa => ${readEmail["Subject"].toString()[aa]}");
                                                    // }

                                                    // for(var aa = 0; aa< emailList[0]["Subject"].toString().length; aa++) {
                                                    //   print("bb => ${emailList[0]["Subject"].toString()[aa]}");
                                                    // }
                                                    // print("kk=>${readEmail["Subject"]} kk");
                                                    // print("ll=>${emailList[0]["Subject"]} ll");
                                                    // if(readEmail["Subject"] == emailList[0]["Subject"]) {
                                                    //   print("ok");
                                                    // }
                                                    // print(
                                                    //     emailList.where(
                                                    //         (element) =>
                                                    //             element["From"].toString() == readEmail["From"].toString() && element["Subject"].toString() == readEmail["Subject"].toString()));
                                                    // print(emailList.indexWhere(
                                                    //     (element) =>
                                                    //         element["From"] ==
                                                    //             readEmail["From"] &&
                                                    //         element["Subject"] ==
                                                    //             readEmail[
                                                    //                 "Subject"]));
                                                    // print(readEmail);
                                                    // print(emailList);
                                                    // print(emailList.indexWhere((element) => element["From"].toString() == readEmail["From"].toString() && element["Subject"].toString() == readEmail["Subject"].toString()));
                                                    // print("${emailList[emailList.indexWhere((element) => element["From"] == readEmail["From"] && element["Subject"] == readEmail["Subject"]) + 1]["Subject"]} from ${emailList[emailList.indexWhere((element) => element["From"] == readEmail["From"] && element["Subject"] == readEmail["Subject"]) + 1]["From"]}");
                                                    _speak(
                                                        "",
                                                        "${emailList[emailList.indexWhere((element) => element["From"] == readEmail["From"] && element["Subject"] == readEmail["Subject"]) + 1]["Subject"]} From ${emailList[emailList.indexWhere((element) => element["From"] == readEmail["From"] && element["Subject"] == readEmail["Subject"]) + 1]["From"]}",
                                                        "false", []);
                                                  } else {
                                                    _speak(
                                                        "",
                                                        "${emailList[0]["Subject"]} From ${emailList[0]["From"]}",
                                                        "false", []);
                                                  }
                                                }
                                              }
                                            });
                                          },
                                          child: Container(
                                            child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Icon(
                                                  Icons.arrow_right,
                                                  color:
                                                      changeBtnColor == "right"
                                                          ? Colors.blue[200]
                                                          : Colors.grey,
                                                  size: 120,
                                                )),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                splashColor: Colors.blue[100],
                                highlightColor: Colors.transparent,
                                radius: 50,
                                onTap: () {
                                  print("Bottom");
                                  if (mounted) {
                                    setState(() {
                                      changeBtnColor = "bottom";
                                    });
                                  }
                                  if (readNext == true) {
                                    if (lastSpeechWord.length != 0) {
                                      _speak("", lastSpeechWord, "false", []);
                                    }
                                  }
                                },
                                child: Container(
                                  height: MediaQuery.of(context).size.width / 3,
                                  child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: changeBtnColor == "bottom"
                                            ? Colors.blue[200]
                                            : Colors.grey,
                                        size: 120,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "Version $version",
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void errorListener(SpeechRecognitionError error) {
    // print("Received error status: $error, listening: ${speech.isListening}");
    if (mounted) {
      setState(() {
        lastError = '${error.errorMsg} - ${error.permanent}';
      });
    }
  }

  void statusListener(String status) {
    // print(
    // 'Received listener status: $status, listening: ${speech.isListening}');
    if (mounted) {
      setState(() {
        lastStatus = '$status';
      });
    }
  }

  void resultListener(SpeechRecognitionResult result) {
    ++resultListened;
    print('Result listener $resultListened');
    if (mounted) {
      setState(() {
        lastWords = '${result.recognizedWords}';
        print("Last Words ==> $lastWords");

        if (speech.isListening == false) {
          resultForRead(lastWords);
        }
      });
    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    if (mounted) {
      setState(() {
        this.level = level;
      });
    }
  }
}
