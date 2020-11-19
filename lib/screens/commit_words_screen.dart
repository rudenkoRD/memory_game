import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memory_game/notifiers/pages_notifier.dart';
import 'package:memory_game/notifiers/users_data_notifier.dart';
import 'package:memory_game/widgets/counter_widget.dart';
import 'package:memory_game/widgets/outline_border_counter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommitWordsScreen extends StatefulWidget {
  @override
  _CommitWordsScreenState createState() => _CommitWordsScreenState();
}

class _CommitWordsScreenState extends State<CommitWordsScreen> {
  UsersDataNotifier userData;
  ScreenNotifier screenNotifier;
  int topFlex = 2;
  int middleFlex = 6;
  int currentWord = -1;
  bool isPlayed = false;

  int currentWordToRefreshInMemory;

  int rememberedWords;
  AudioCache audioCache = AudioCache();
  var prefs;

  @override
  void initState(){
    super.initState();

    loadPrefs();
  }

  loadPrefs() async { 
    prefs = await SharedPreferences.getInstance();
  }

  int getWordNumToRemember(UsersDataNotifier userData) {
    for (int i = 0; i < userData.wordList.length; i++) {
      if (userData.wordList[i].isMemorized == false &&
          userData.wordList[i].mempool == 0) {
        return i;
      }
    }
    return -1;
  }

  int getCurrentWordToRefreshInMemory(){
    for(int i = 0; i < userData.wordList.length; i++){
      if(userData.wordList[i].giw == 'w') return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    userData = Provider.of<UsersDataNotifier>(context);
    screenNotifier = Provider.of<ScreenNotifier>(context);
    rememberedWords = userData.toRememberWordsNum - userData.currentDayToRemember;

    if (currentWord == -1) currentWord = getWordNumToRemember(userData);
    if(currentWordToRefreshInMemory == null) currentWordToRefreshInMemory = getCurrentWordToRefreshInMemory();
    if(currentWordToRefreshInMemory != -1) currentWord = currentWordToRefreshInMemory;


    if (userData.currentDayToRemember <= 0 ||
        (currentWord == -1 && rememberedWords > 0)) {

      bool isEnterStageTestScreen = false;
      for(int i = 0; i < userData.testingStagesList.length; i++){
        if(userData.wordsCommitted >= int.parse(userData.testingStagesList[i]) ) {
          if(userData.testingStageIsComplete[i] == 'false') {
            userData.testingStageIsComplete[i] = 'active';
            prefs.setStringList('testingStageIsComplete', userData.testingStageIsComplete);
            isEnterStageTestScreen = true;
            break;
          }
        }
        if(userData.testingStageIsComplete[i] == 'active'){
          isEnterStageTestScreen = true;
          break;
        }
      }

      if(isEnterStageTestScreen) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showDialog(context: context,
              builder: (context) => AlertDialog(
                content: Text('You\'re making great progress, tomorrow we will do a Stage test to check your progress to date'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('ok'),
                    color: Colors.green,
                  )
                ],
              ));
        });
      }


      return Scaffold(
        appBar: AppBar(
          title: Text('Commit words'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'That\'s the end of memorizing today, see you tomorrow!',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text(
                    'ok, leave the app',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (currentWord == -1 && rememberedWords == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Commit words'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Next time you start the app the stage test will start again',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                FlatButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text(
                    'ok, leave the app',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // if (userData.wordList[currentWord].displayFileName
    //     .toString()
    //     .isNotEmpty) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //     audioCache.play(
    //         'audio/${userData.wordList[currentWord].displayAudioName}');
    //     await showDialog<String>(
    //       context: context,
    //       builder: (BuildContext context) => WillPopScope(
    //         onWillPop: () async => false,
    //         child: AlertDialog(
    //           contentPadding: EdgeInsets.all(0),
    //           insetPadding: EdgeInsets.all(0),
    //           content: SingleChildScrollView(
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               crossAxisAlignment: CrossAxisAlignment.center,
    //               children: <Widget>[
    //                 Image.asset(
    //                     'assets/images/display_images/${userData.wordList[currentWord].displayFileName}'),
    //                 RaisedButton(
    //                   shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(10)),
    //                   onPressed: () async {
    //                     Navigator.of(context).pop();
    //                     final prefs = await SharedPreferences.getInstance();
    //                     userData.wordsCommitted++;
    //                     userData.wordList[currentWord].mempool = 1;
    //                     userData.currentDayToRemember--;
    //                     rememberedWords = userData.toRememberWordsNum -
    //                         userData.currentDayToRemember;
    //
    //                     List<String> data = List();
    //                     userData.wordList.forEach((element) {
    //                       data.add(element.toString());
    //                       print(element.toString());
    //                     });
    //                     prefs.setStringList('words', data);
    //                     prefs.setInt('successRememberedWordsNum',
    //                         userData.successRememberedWordsNum);
    //                     prefs.setInt(
    //                         'wordsCommitted', userData.wordsCommitted);
    //                     prefs.setInt('currentDayToRemember',
    //                         userData.currentDayToRemember);
    //                     prefs.setInt('toRememberWordsNum',
    //                         userData.toRememberWordsNum);
    //
    //                     currentWord = getWordNumToRemember(userData);
    //
    //                     if (userData.currentDayToRemember <= 0 ||
    //                         (currentWord == -1 && rememberedWords > 0)) {
    //                       DateTime date = DateTime.now();
    //                       prefs.setInt(
    //                           'lastCommitDate', date.millisecondsSinceEpoch);
    //                     }
    //
    //                     setState(() {});
    //                   },
    //                   child: Text(
    //                     'Click when committed',
    //                     style: TextStyle(color: Colors.white, fontSize: 20),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ),
    //     );
    //   });
    // }


    if(currentWord != -1 && !isPlayed) {
      isPlayed = true;
      WidgetsBinding.instance.addPostFrameCallback((_)  {
        if(userData.wordList[currentWord].displayFileName
            .toString()
            .isNotEmpty){

          String path = 'audio/${userData.wordList[currentWord].displayAudioName}';
          audioCache.play(
             path);
        } else audioCache.play('audio/${userData.wordList[currentWord].audioFileName}');
      });
    }

    var totalHeight = MediaQuery.of(context).size.height - (AppBar().preferredSize.height + MediaQuery.of(context).padding.top);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 1.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text('Commit words'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    userData.wordList[currentWord].displayFileName
                        .toString()
                        .isEmpty ?
                    audioCache.play('audio/${userData.wordList[currentWord].audioFileName}')
                        : audioCache.play(
                        'audio/${userData.wordList[currentWord].displayAudioName}');
                  },
                  child: Icon(Icons.hearing, color: Colors.white),
                ),
                InkWell(
                    onTap: () {
                      if(currentWordToRefreshInMemory != -1) return;

                      if (topFlex == 2) {
                        setState(() {
                          topFlex = 0;
                          middleFlex = 8;
                        });
                      } else {
                        setState(() {
                          topFlex = 2;
                          middleFlex = 6;
                        });
                      }
                    },
                    child: CounterWidget(
                      numberToShow: userData.wordsCommitted,
                    )),
                FlatButton(
                    onPressed: () {
                      _showSelectingPerDayNumOfCommit(context)
                          .then((value) async {
                        if (value != null) {
                          userData.toRememberWordsNum = value;
                          if (rememberedWords < value) {
                            userData.currentDayToRemember =
                                value - rememberedWords;

                            prefs.setInt('currentDayToRemember',
                                userData.currentDayToRemember);
                          }

                          prefs.setInt('toRememberWordsNum',
                              userData.toRememberWordsNum);
                        }
                      });
                    },
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                    )),
              ],
            ),
          ],
        ),
      ),
      body: userData.wordList[currentWord].displayFileName
          .toString()
          .isEmpty ? SingleChildScrollView(
        child: Container(
          height: totalHeight,
          padding: EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              currentWordToRefreshInMemory != -1 ? Expanded(
                flex: 2,
                child: Center(child: Text('Refresh old words in memory', textAlign: TextAlign.center, style: TextStyle(fontSize: 30))),
              ) : topFlex == 2
                  ? Expanded(
                      flex: topFlex,
                      child: Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            OutlineBorderCounter(
                              label: 'Words committed\nto memory',
                              numberToShow:
                                  userData.wordsCommitted,
                            ),
                            OutlineBorderCounter(
                              label: 'Words left',
                              numberToShow: userData.totalNumOfWords - userData.wordsCommitted,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              Expanded(
                flex: middleFlex,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
//                    Text(
//                      '${usersDataNotifier.wordList[currentWord].mainText}',
//                      style: TextStyle(fontSize: 40, fontFamily: 'MSyahei'),
//                    ),
                      Image.asset(
                          'assets/images/main_text_images/${userData.wordList[currentWord].mainText}'),
                      Text(
                        '${userData.wordList[currentWord].firstValue}',
                        style: TextStyle(fontSize: 20, fontFamily: 'MSyahei'),
                      ),
//                      Text(
//                        '${userData.wordList[currentWord].secondValue}',
//                        style: TextStyle(fontSize: 18, fontFamily: 'MSyahei'),
//                      ),

                      Image.asset(
                          'assets/images/secondvalue/${userData.wordList[currentWord].secondValue}',
                      height: 30,),


                    ],
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
                      isPlayed = false;
                      userData.wordsCommitted++;

                      prefs.setInt(
                          'wordsCommitted', userData.wordsCommitted);

                      if(currentWordToRefreshInMemory != -1) {
                       userData.wordList[currentWordToRefreshInMemory].giw = '0';
                      }

                      userData.wordList[currentWord].mempool = 1;
                      userData.currentDayToRemember--;
                      rememberedWords = userData.toRememberWordsNum -
                          userData.currentDayToRemember;

                      List<String> data = List();
                      userData.wordList.forEach((element) {
                        data.add(element.toString());
                        print(element.toString());
                      });
                      prefs.setStringList('words', data);
                      prefs.setInt('successRememberedWordsNum',
                          userData.successRememberedWordsNum);
                      prefs.setInt(
                          'wordsCommitted', userData.wordsCommitted);
                      prefs.setInt('currentDayToRemember',
                          userData.currentDayToRemember);
                      prefs.setInt('toRememberWordsNum',
                          userData.toRememberWordsNum);

                      currentWordToRefreshInMemory = getCurrentWordToRefreshInMemory();
                      if(currentWordToRefreshInMemory == -1){
                        currentWord = getWordNumToRemember(userData);
                      }else currentWord = currentWordToRefreshInMemory;


                      if (userData.currentDayToRemember <= 0 ||
                          (currentWord == -1 && rememberedWords > 0)) {
                        DateTime date = DateTime.now();
                        prefs.setInt(
                            'lastCommitDate', date.millisecondsSinceEpoch);

                      }

                      setState(() {});
                    },
                    child: Text(
                      'Click when committed',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                  'assets/images/display_images/${userData.wordList[currentWord].displayFileName}'),
              RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () async {
                  isPlayed = false;
                  userData.wordsCommitted++;

                  prefs.setInt(
                      'wordsCommitted', userData.wordsCommitted);

                  if(currentWordToRefreshInMemory != -1) {
                    userData.wordList[currentWordToRefreshInMemory].giw = '0';
                  }

                  userData.wordList[currentWord].mempool = 1;
                  userData.currentDayToRemember--;
                  rememberedWords = userData.toRememberWordsNum -
                      userData.currentDayToRemember;

                  List<String> data = List();
                  userData.wordList.forEach((element) {
                    data.add(element.toString());
                    print(element.toString());
                  });
                  prefs.setStringList('words', data);
                  prefs.setInt('successRememberedWordsNum',
                      userData.successRememberedWordsNum);
                  prefs.setInt(
                      'wordsCommitted', userData.wordsCommitted);
                  prefs.setInt('currentDayToRemember',
                      userData.currentDayToRemember);
                  prefs.setInt('toRememberWordsNum',
                      userData.toRememberWordsNum);

                  currentWordToRefreshInMemory = getCurrentWordToRefreshInMemory();
                  if(currentWordToRefreshInMemory == -1){
                    currentWord = getWordNumToRemember(userData);
                  }else currentWord = currentWordToRefreshInMemory;


                  if (userData.currentDayToRemember <= 0 ||
                      (currentWord == -1 && rememberedWords > 0)) {
                    DateTime date = DateTime.now();
                    prefs.setInt(
                        'lastCommitDate', date.millisecondsSinceEpoch);

                  }

                  setState(() {});
                },
                child: Text(
                  'Click when committed',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<int> _showSelectingPerDayNumOfCommit(context) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('How many words would you like to commit each day?'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(5);
            },
            child: Text(
              '5 words',
              textAlign: TextAlign.center,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(4);
            },
            child: Text(
              '4 words',
              textAlign: TextAlign.center,
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(3);
            },
            child: Text(
              '3 words',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
