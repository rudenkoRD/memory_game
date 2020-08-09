import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/notifiers/pages_notifier.dart';
import 'package:memory_game/notifiers/users_data_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestingScreen extends StatefulWidget {
  final int lastCommitDateTime;

  const TestingScreen({Key key, this.lastCommitDateTime}) : super(key: key);

  @override
  _TestingScreenState createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  UsersDataNotifier userData;
  ScreenNotifier screenNotifier;
  AudioCache audioCache = AudioCache();
  int currentTestingWord = -1;
  String currentAnswer;
  GlobalKey<FormState> answerFormState = GlobalKey<FormState>();

  int getWordNumToTest(UsersDataNotifier userData) {
    for (int i = 0; i < userData.wordList.length; i++) {
      print(
          '${userData.wordList[i].isMemorized} ${userData.wordList[i].mempool} data');

      if (userData.wordList[i].isMemorized == false &&
          userData.wordList[i].mempool == 1) {
        return i;
      }
    }
    return -1;
  }

  @override
  void initState() {
    super.initState();
  }

  checkDay(lastCommitDate) {
    if (lastCommitDate.difference(DateTime.now()).inDays == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showDialog(
            context: context,
            builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: Text(
                        'You have to wait till the next day to test yourself'),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          exit(0);
                        },
                        child: Text(
                          'ok, leave an app',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<UsersDataNotifier>(context);
    screenNotifier = Provider.of<ScreenNotifier>(context);
    if (currentTestingWord == -1) {
      currentTestingWord = getWordNumToTest(userData);
    }

    DateTime lastCommitDate =
        DateTime.fromMillisecondsSinceEpoch(widget.lastCommitDateTime);
    checkDay(lastCommitDate);

    if (lastCommitDate.difference(DateTime.now()).inDays == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Stage Testing'),
        ),
        body: Container(
          color: Colors.white,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text('Testing'),
            FlatButton(
              onPressed: () {
                audioCache.play(
                    'audio/${userData.wordList[currentTestingWord].audioFileName}');
              },
              child: Icon(
                Icons.hearing,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
      body: Builder(
        builder: (context) => Container(
          padding: EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Container(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Image.asset(
                          'assets/images/main_text_images/${userData.wordList[currentTestingWord].mainText}'),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Form(
                    key: answerFormState,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'enter your answer',
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value.isEmpty) return 'please, enter the answer';
                        return null;
                      },
                      onSaved: (answer) {
                        currentAnswer = answer;
                      },
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 5),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();

                    if (answerFormState.currentState.validate()) {
                      answerFormState.currentState.save();
                      answerFormState.currentState.reset();

                      if (currentAnswer.trim().toLowerCase() ==
                          userData.wordList[currentTestingWord].firstValue
                              .toString()
                              .trim()
                              .toLowerCase()) {
                        Scaffold.of(context)
                            .showSnackBar(
                              SnackBar(
                                duration: Duration(milliseconds: 900),
                                backgroundColor: Colors.green,
                                content: Text(
                                  'Well done',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                            .closed
                            .then((value) {

                          currentTestingWord = getWordNumToTest(userData);
                          if (currentTestingWord == -1) {

                            userData.currentDayToRemember =
                                userData.toRememberWordsNum;
                            prefs.setInt('currentDayToRemember',
                                userData.currentDayToRemember);
                            prefs.remove('lastCommitDate');
                            screenNotifier.currentScreen = Screen.COMMIT_SCREEN;
                          }

                          setState(() {});
                        });

                        userData.wordList[currentTestingWord].isMemorized =
                            true;
                        userData.successRememberedWordsNum++;
                        userData.wordList[currentTestingWord].mempool = 0;
                      } else {
                        userData.wordsCommitted--;
                        userData.wordList[currentTestingWord].mempool = 0;
                        Scaffold.of(context)
                            .showSnackBar(
                              SnackBar(
                                duration: Duration(milliseconds: 900),
                                backgroundColor: Colors.red,
                                content: Text(
                                  'Oops that\'s not right',
                                  style: TextStyle(fontSize: 25),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                            .closed
                            .then((value) {
                          currentTestingWord = getWordNumToTest(userData);

                          if (currentTestingWord == -1) {
                            userData.currentDayToRemember =
                                userData.toRememberWordsNum;
                            prefs.setInt('currentDayToRemember',
                                userData.currentDayToRemember);
                            prefs.remove('lastCommitDate');
                            screenNotifier.currentScreen = Screen.COMMIT_SCREEN;
                          }

                          setState(() {});
                        });
                      }

                      prefs.setInt('wordsCommitted', userData.wordsCommitted);
                      prefs.setInt('successRememberedWordsNum',
                          userData.successRememberedWordsNum);

                      List<String> data = List();
                      userData.wordList.forEach((element) {
                        data.add(element.toString());
                        print(element.toString());
                      });
                      prefs.setStringList('words', data);



                      //setState(() {});
                    }
                  },
                  child: Text(
                    'Test me',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
