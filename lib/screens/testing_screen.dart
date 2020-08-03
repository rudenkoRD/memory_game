import 'package:audioplayers/audio_cache.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/notifiers/pages_notifier.dart';
import 'package:memory_game/notifiers/users_data_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestingScreen extends StatefulWidget {
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
      print('${userData.wordList[i].isMemorized} ${userData.wordList[i].mempool} data');
      if (userData.wordList[i].isMemorized == false && userData.wordList[i].mempool == 1 && currentTestingWord != i) {
        return i;
      }
    }
    if(userData.wordList[currentTestingWord].isMemorized) return -1;
    else return currentTestingWord;
  }

  @override
  Widget build(BuildContext context) {
    usersDataNotifier = Provider.of<UsersDataNotifier>(context);
    screenNotifier = Provider.of<ScreenNotifier>(context);
    if (currentTestingWord == -1) {
      currentTestingWord = getWordNumToTest(usersDataNotifier);
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
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () async {
                      if (answerFormState.currentState.validate()) {
                        answerFormState.currentState.save();
                        answerFormState.currentState.reset();

                        if (currentAnswer.trim().toLowerCase() ==
                            usersDataNotifier.wordList[currentTestingWord].firstValue.toString().trim().toLowerCase()) {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Well done'),
                            ),
                          );

                          usersDataNotifier
                              .wordList[currentTestingWord].isMemorized = true;
                          usersDataNotifier.successRememberedWordsNum++;
                          usersDataNotifier.wordList[currentTestingWord].mempool =
                              0;
                        } else {
                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red,
                              content: Text('Oops that\'s not right'),
                            ),
                          );
                        }

                        final prefs = await SharedPreferences.getInstance();

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
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
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
