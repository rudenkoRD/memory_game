import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
  UsersDataNotifier usersDataNotifier;
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
    usersDataNotifier = Provider.of<UsersDataNotifier>(context);
    screenNotifier = Provider.of<ScreenNotifier>(context);
    if (currentTestingWord == -1) {
      currentTestingWord = getWordNumToTest(usersDataNotifier);
    }

    DateTime lastCommitDate =
        DateTime.fromMillisecondsSinceEpoch(widget.lastCommitDateTime);
    checkDay(lastCommitDate);

    if (lastCommitDate.difference(DateTime.now()).inDays == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Testing'),
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
                    'audio/${usersDataNotifier.wordList[currentTestingWord].audioFileName}');
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
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: AutoSizeText(
                      '${usersDataNotifier.wordList[currentTestingWord].mainText}',
                      minFontSize: 10,
                      maxFontSize: 100,
                      maxLines: 1,
                      style: TextStyle(fontSize: 100),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
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
                margin: EdgeInsets.only(bottom: 20),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () async {
                    if (answerFormState.currentState.validate()) {
                      answerFormState.currentState.save();
                      answerFormState.currentState.reset();

                      if (currentAnswer.trim().toLowerCase() ==
                          usersDataNotifier
                              .wordList[currentTestingWord].firstValue
                              .toString()
                              .trim()
                              .toLowerCase()) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('Well done', style: TextStyle(fontSize: 25,), textAlign: TextAlign.center,),
                          ),
                        );

                        usersDataNotifier
                            .wordList[currentTestingWord].isMemorized = true;
                        usersDataNotifier.successRememberedWordsNum++;
                        usersDataNotifier.wordList[currentTestingWord].mempool =
                            0;
                      } else {
                        usersDataNotifier.wordsCommitted--;
                        usersDataNotifier.wordList[currentTestingWord].mempool =
                            0;
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Oops that\'s not right',
                                style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
                          ),
                        );
                      }

                      final prefs = await SharedPreferences.getInstance();

                      prefs.setInt(
                          'wordsCommitted', usersDataNotifier.wordsCommitted);
                      prefs.setInt('successRememberedWordsNum',
                          usersDataNotifier.successRememberedWordsNum);

                      List<String> data = List();
                      usersDataNotifier.wordList.forEach((element) {
                        data.add(element.toString());
                        print(element.toString());
                      });
                      prefs.setStringList('words', data);

                      currentTestingWord = getWordNumToTest(usersDataNotifier);
                      if (currentTestingWord == -1) {
                        usersDataNotifier.currentDayToRemember =
                            usersDataNotifier.toRememberWordsNum;
                        prefs.setInt('currentDayToRemember',
                            usersDataNotifier.currentDayToRemember);
                        prefs.remove('lastCommitDate');
                        screenNotifier.currentScreen = Screen.COMMIT_SCREEN;
                      }

                      setState(() {});
                    }
                  },
                  child: Text(
                    'test me',
                    style: TextStyle(color: Colors.white, fontSize: 30),
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
