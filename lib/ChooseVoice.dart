import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'VoiceList.dart';

class ChooseVoice extends StatefulWidget {
  const ChooseVoice({Key key}) : super(key: key);

  @override
  _ChooseVoiceState createState() => _ChooseVoiceState();
}

class _ChooseVoiceState extends State<ChooseVoice> {
  List<String> localList = ["All"];

  @override
  void initState() {
    super.initState();
    getLocalList();
  }

  String dropDownValue = "All";
  List onchangedVoiceList = [];

  var chosenVoice;

  Future<void> getLocalList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.getString("ChooseVoice") == null) {
        chosenVoice = voiceList
            .where((element) => element["ShortName"] == "en-US-AriaNeural")
            .toList()[0];
      } else {
        chosenVoice = json.decode(sharedPreferences.getString("ChooseVoice"));
      }
      onchangedVoiceList = voiceList;
      for (var a = 0; a < voiceList.length; a++) {
        if (localList.length == 0) {
          localList.add("${voiceList[a]["Locale"]}");
        }
        if (localList
                .where((element) => element == voiceList[a]["Locale"])
                .toList()
                .length ==
            0) {
          localList.add("${voiceList[a]["Locale"]}");
        }
      }
    });
  }

  void dropDownOnChanged() {
    setState(() {
      if (dropDownValue == "All") {
        onchangedVoiceList = voiceList;
      } else {
        onchangedVoiceList = voiceList
            .where((element) =>
                element["Locale"].toString() == dropDownValue.toString())
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue[400],
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context, chosenVoice["DisplayName"]);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(
                        "$dropDownValue",
                        style: TextStyle(color: Colors.white),
                      ),
                      iconEnabledColor: Colors.white,
                      items: localList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          dropDownValue = newValue;
                        });
                        dropDownOnChanged();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: ListView.builder(
              itemCount: onchangedVoiceList.length,
              itemBuilder: (BuildContext context, int i) {
                return Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: Column(
                      children: <Widget>[
                        if (i != 0)
                          SizedBox(
                            height: 10,
                          ),
                        GestureDetector(
                          onTap: () async {
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();

                            sharedPreferences.setString("ChooseVoice",
                                json.encode(onchangedVoiceList[i]));
                            setState(() {
                              chosenVoice = onchangedVoiceList[i];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: chosenVoice.toString() ==
                                            onchangedVoiceList[i].toString()
                                        ? Colors.blue
                                        : Colors.grey),
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 25),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "${onchangedVoiceList[i]["DisplayName"]}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: chosenVoice.toString() ==
                                                onchangedVoiceList[i].toString()
                                            ? Colors.blue
                                            : Colors.black),
                                  ),
                                  if (chosenVoice.toString() ==
                                      onchangedVoiceList[i].toString())
                                    GestureDetector(
                                      onTap: () {
                                        speak(onchangedVoiceList[i]);
                                      },
                                      child: Icon(
                                        Icons.volume_up,
                                        color: Colors.blue,
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ));
              })),
    );
  }

  Future<void> speak(voice) async {
    xml.XmlBuilder builder = xml.XmlBuilder();
    builder.element('speak', nest: () {
      builder.attribute('version', '1.0');
      builder.attribute('xml:lang', '${voice["Locale"]}');
      builder.element('voice', nest: () {
        builder.attribute('xml:lang', '${voice["Locale"]}');
        builder.attribute('xml:gender', '${voice["Gender"]}');
        builder.attribute('name', '${voice["ShortName"]}');
        builder.text("Hi!I am ${voice["DisplayName"]}.");
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
    String newfileName = "${dateTime.year}${dateTime.month}${dateTime.day}${dateTime.hour}${dateTime.minute}${dateTime.second}${dateTime.millisecond}";
    final file = new File('${dir.path}/$newfileName.mp3');

    file.writeAsBytesSync(bytes);

    file.exists().then((value) {
      AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
      AudioPlayer.logEnabled = true;

      audioPlayer.play(file.path);
    });
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
}
