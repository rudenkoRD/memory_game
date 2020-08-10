import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:memory_game/notifiers/pages_notifier.dart';
import 'package:memory_game/notifiers/users_data_notifier.dart';
import 'package:memory_game/widgets/counter_widget.dart';
import 'package:memory_game/widgets/outline_border_counter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StageTestScreen extends StatefulWidget {
  final int lastCommitDateTime;

  const StageTestScreen({Key key, this.lastCommitDateTime}) : super(key: key);
  @override
  _StageTestScreenState createState() => _StageTestScreenState();
}



class _StageTestScreenState extends State<StageTestScreen> {

  UsersDataNotifier userData;
  ScreenNotifier screenNotifier;
  int topFlex = 1;
  bool showCounters = true;
  bool keyboardIsActive = false;
  int middleFlex = 6;
  String currentAnswer;
  int currentWord = -1;
  double totalHeight;
  int totalNumberOfTestedWords;
  GlobalKey<FormState> stateTestingAnswer = GlobalKey<FormState>();
  AudioCache audioCache = AudioCache();
  var scrollController = ScrollController();
  var focusNode = FocusNode();

  @override
  void initState(){
    super.initState();
  }


  int getNextWordToTest(){
    for(int i = 0; i < userData.wordList.length; i++){
      print('${userData.wordList[i].isMemorized} ${userData.wordList[i].mempool} data');

      if( (userData.wordList[i].isMemorized || userData.wordList[i].mempool == 1) && userData.wordList[i].giw == '0')
        return i;
    }

    return -1;
  }

  int getTotalNumberOfTestedWords(){
    int res = 0;
    for(int i = 0; i < userData.wordList.length; i++){
      if((userData.wordList[i].isMemorized || userData.wordList[i].mempool == 1) && userData.wordList[i].giw == '0') res++;
    }

    return res;
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
    totalHeight = MediaQuery.of(context).size.height - (AppBar().preferredSize.height + MediaQuery.of(context).padding.top);

    focusNode.addListener(() {
      keyboardIsActive = focusNode.hasFocus;
    });


    userData = Provider.of<UsersDataNotifier>(context);
    screenNotifier = Provider.of<ScreenNotifier>(context);

    if(currentWord == -1) currentWord = getNextWordToTest();
    totalNumberOfTestedWords = getTotalNumberOfTestedWords();

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

    print('${MediaQuery.of(context).padding.top} padding');
    print('${AppBar().preferredSize.height} appbar');
    print('$kToolbarHeight tool');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text('Stage testing'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    audioCache.play(
                        'audio/${userData.wordList[currentWord].audioFileName}');
                  },
                  child: Icon(
                    Icons.hearing,
                    color: Colors.white,
                  ),
                ),
                InkWell(
                  onTap: () {
                    print('tap');
                    showCounters = !showCounters;

                    setState(() {});
                  },
                  child: CounterWidget(
                    numberToShow: totalNumberOfTestedWords,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            showCounters && !keyboardIsActive ? Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    OutlineBorderCounter(
                      label: 'Words committed\nto memory',
                      numberToShow: userData.wordsCommitted,
                    ),
                    OutlineBorderCounter(
                      label: 'Words to test left',
                      numberToShow: totalNumberOfTestedWords,
                    ),
                  ],
                ),
              ),
            ) : Container(),
            Expanded(
              flex : 5,
              child: Container(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Image.asset(
                          'assets/images/main_text_images/${userData.wordList[currentWord].mainText}'),
                    ),
                  ),
                ),
              ),
            ),
//            SizedBox(height: 15),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Form(
                  key: stateTestingAnswer,
                  child: TextFormField(
                    focusNode: focusNode,
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
            Builder(
              builder: (context) => Container(
                child: FlatButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();

                    if(stateTestingAnswer.currentState.validate()){
                      stateTestingAnswer.currentState.save();
                      stateTestingAnswer.currentState.reset();

                      if(currentAnswer.trim().toLowerCase() == userData.wordList[currentWord].firstValue.toString().trim().toLowerCase()){

                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(milliseconds: 900),
                            backgroundColor: Colors.green,
                            content: Text('Well done', style: TextStyle(fontSize: 25,), textAlign: TextAlign.center,),
                          ),
                        ).closed
                        .then((value) {
                          currentWord = getNextWordToTest();
                          if(currentWord == -1){

                            for(int i = 0; i < userData.wordList.length; i++){
                              if(userData.wordList[i].giw == '1')
                                userData.wordList[i].giw = '0';
                            }

                            for(int i = 0; i < userData.testingStageIsComplete.length; i++){
                              if(userData.testingStageIsComplete[i] == 'active'){
                                userData.testingStageIsComplete[i] = 'true';
                              }
                            }

                            prefs.setStringList('testingStageIsComplete', userData.testingStageIsComplete);

                            List<String> data = List();
                            userData.wordList.forEach((element) {
                              data.add(element.toString());
                              print(element.toString());
                            });
                            prefs.setStringList('words', data);

                            userData.currentDayToRemember =
                                userData.toRememberWordsNum;
                            prefs.setInt('currentDayToRemember',
                                userData.currentDayToRemember);
                            prefs.remove('lastCommitDate');
                            screenNotifier.currentScreen = Screen.COMMIT_SCREEN;
                          }

                          setState(() {});
                        });


                        if(!userData.wordList[currentWord].isMemorized) {
                          userData.successRememberedWordsNum++;
                        }

                        userData.wordList[currentWord].isMemorized = true;
                        userData.wordList[currentWord].giw = '1';
                        userData.wordList[currentWord].mempool = 0;

                      }else {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            duration: Duration(milliseconds: 900),
                            backgroundColor: Colors.red,
                            content: Text('Oops that\'s not right',
                              style: TextStyle(fontSize: 25),textAlign: TextAlign.center,),
                          ),
                        ).closed.then((value) {
                          currentWord = getNextWordToTest();
                          if(currentWord == -1){

                            for(int i = 0; i < userData.wordList.length; i++){
                              if(userData.wordList[i].giw == '1')
                                userData.wordList[i].giw = '0';
                            }

                            for(int i = 0; i < userData.testingStageIsComplete.length; i++){
                              if(userData.testingStageIsComplete[i] == 'active'){
                                userData.testingStageIsComplete[i] = 'true';
                              }
                            }

                            prefs.setStringList('testingStageIsComplete', userData.testingStageIsComplete);

                            List<String> data = List();
                            userData.wordList.forEach((element) {
                              data.add(element.toString());
                              print(element.toString());
                            });
                            prefs.setStringList('words', data);

                            userData.currentDayToRemember =
                                userData.toRememberWordsNum;
                            prefs.setInt('currentDayToRemember',
                                userData.currentDayToRemember);
                            prefs.remove('lastCommitDate');
                            screenNotifier.currentScreen = Screen.COMMIT_SCREEN;
                          }

                          setState(() {});
                        });

                        if(userData.wordList[currentWord].isMemorized)
                          userData.wordList[currentWord].giw = 'w';
                        else userData.wordList[currentWord].giw = '1';

                        userData.wordList[currentWord].isMemorized = false;

                        userData.wordList[currentWord].mempool = 0;
                        userData.wordsCommitted--;
                      }


                      prefs.setInt('wordsCommitted', userData.wordsCommitted);


                      List<String> data = List();
                      userData.wordList.forEach((element) {
                        data.add(element.toString());
                        print(element.toString());
                      });
                      prefs.setStringList('words', data);

                    }

                  },
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  color: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    'Test me',
                    style: TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
