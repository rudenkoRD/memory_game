import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memory_game/notifiers/users_data_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommitWordsScreen extends StatefulWidget {
  @override
  _CommitWordsScreenState createState() => _CommitWordsScreenState();
}

class _CommitWordsScreenState extends State<CommitWordsScreen> {
  UsersDataNotifier usersDataNotifier;
  int topFlex = 2;
  int middleFlex = 6;
  int currentWord = -1;
  int rememberedWords;
  AudioCache audioCache = AudioCache();

  int getWordNumToRemember(UsersDataNotifier userData) {
    for (int i = 0; i < userData.wordList.length; i++) {
      if (userData.wordList[i].isMemorized == false &&
          userData.wordList[i].mempool == 0) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    usersDataNotifier = Provider.of<UsersDataNotifier>(context);
    rememberedWords = usersDataNotifier.toRememberWordsNum -
        usersDataNotifier.currentDayToRemember;
    if (currentWord == -1) currentWord = getWordNumToRemember(usersDataNotifier);

    if (usersDataNotifier.currentDayToRemember <= 0 || (currentWord == -1 && rememberedWords > 0)) {
      return Scaffold(
        appBar: AppBar(title: Text('Commit words'),),
        body: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('That\'s the end of memorizing today, see you tomorrow!', style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                FlatButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text('ok, leave an app', style: TextStyle(color: Colors.white),),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if(currentWord == -1 && rememberedWords == 0){
      return Scaffold(
        appBar: AppBar(title: Text('Commit words'),),
        body: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('You have learned all words!', style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                FlatButton(
                  onPressed: () {
                    exit(0);
                  },
                  child: Text('ok, leave an app', style: TextStyle(color: Colors.white),),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if(usersDataNotifier.wordList[currentWord].displayFileName.toString().isNotEmpty){
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        audioCache.play(
            'audio/${usersDataNotifier.wordList[currentWord].displayAudioName}');
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              insetPadding: EdgeInsets.all(0),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/${usersDataNotifier.wordList[currentWord].displayFileName}'),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final prefs = await SharedPreferences.getInstance();
                        usersDataNotifier.wordsCommitted++;
                        usersDataNotifier.wordList[currentWord].mempool = 1;
                        usersDataNotifier.currentDayToRemember--;
                        rememberedWords = usersDataNotifier.toRememberWordsNum -
                            usersDataNotifier.currentDayToRemember;

                        List<String> data = List();
                        usersDataNotifier.wordList.forEach((element) {
                          data.add(element.toString());
                          print(element.toString());
                        });
                        prefs.setStringList('words', data);
                        prefs.setInt('successRememberedWordsNum',
                            usersDataNotifier.successRememberedWordsNum);
                        prefs.setInt(
                            'wordsCommitted', usersDataNotifier.wordsCommitted);
                        prefs.setInt('currentDayToRemember',
                            usersDataNotifier.currentDayToRemember);
                        prefs.setInt('toRememberWordsNum',
                            usersDataNotifier.toRememberWordsNum);

                        currentWord = getWordNumToRemember(usersDataNotifier);

                        if(usersDataNotifier.currentDayToRemember <= 0 || (currentWord == -1 && rememberedWords > 0)){
                          DateTime date = DateTime.now();
                          prefs.setInt('lastCommitDate', date.millisecondsSinceEpoch);
                        }

                        setState(() {

                        });
                      },
                      child: Text(
                        'Click when committed',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Commit words'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    audioCache.play(
                        'audio/${usersDataNotifier.wordList[currentWord].audioFileName}');
                  },
                  child: Icon(Icons.hearing, color: Colors.white),
                ),
                InkWell(
                  onTap: () {
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(2),
                        child: Text(
                            '${usersDataNotifier.wordsCommitted.toString().length == 4 ? usersDataNotifier.wordsCommitted.toString()[usersDataNotifier.wordsCommitted.toString().length-4] : 0}'),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white),
                            bottom: BorderSide(color: Colors.white),
                            left: BorderSide(color: Colors.white),
                            right: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        child: Text(
                            '${usersDataNotifier.wordsCommitted.toString().length >= 3 ? usersDataNotifier.wordsCommitted.toString()[usersDataNotifier.wordsCommitted.toString().length-3] : 0}'),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white),
                            bottom: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        child: Text(
                            '${usersDataNotifier.wordsCommitted.toString().length >= 2 ? usersDataNotifier.wordsCommitted.toString()[usersDataNotifier.wordsCommitted.toString().length-2] : 0}'),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white),
                            left: BorderSide(color: Colors.white),
                            bottom: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        child: Text(
                            '${usersDataNotifier.wordsCommitted.toString().length >= 1 ? usersDataNotifier.wordsCommitted.toString()[usersDataNotifier.wordsCommitted.toString().length-1] : 0}'),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.white),
                            bottom: BorderSide(color: Colors.white),
                            right: BorderSide(color: Colors.white),
                            left: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () {
                      _showSelectingPerDayNumOfCommit(context)
                          .then((value) async {
                        if (value != null) {
                          usersDataNotifier.toRememberWordsNum = value;
                          if(usersDataNotifier.currentDayToRemember < value) {
                            usersDataNotifier.currentDayToRemember = value - rememberedWords;
                          }
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setInt('toRememberWordsNum', usersDataNotifier.toRememberWordsNum);
                          prefs.setInt('currentDayToRemember', usersDataNotifier.currentDayToRemember);
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
      body: Container(
        padding: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            topFlex == 2
                ? Expanded(
                    flex: topFlex,
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                'Words committed\nto memory',
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  '${usersDataNotifier.wordsCommitted}',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text('Words left'),
                              SizedBox(
                                height: 12,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  '${usersDataNotifier.totalNumOfWords - usersDataNotifier.wordsCommitted}',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(),
                                ),
                              ),
                            ],
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
                    Text(
                      '${usersDataNotifier.wordList[currentWord].mainText}',
                      style: TextStyle(fontSize: 40, fontFamily: 'MSyahei'),
                    ),
                    Text(
                      '${usersDataNotifier.wordList[currentWord].firstValue}',
                      style: TextStyle(fontSize: 18, fontFamily: 'MSyahei'),
                    ),
                    Text(
                      '${usersDataNotifier.wordList[currentWord].secondValue}',
                      style: TextStyle(fontSize: 18, fontFamily: 'MSyahei'),
                    ),
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
                    final prefs = await SharedPreferences.getInstance();
                    usersDataNotifier.wordsCommitted++;
                    usersDataNotifier.wordList[currentWord].mempool = 1;
                    usersDataNotifier.currentDayToRemember--;
                    rememberedWords = usersDataNotifier.toRememberWordsNum -
                        usersDataNotifier.currentDayToRemember;


                    List<String> data = List();
                    usersDataNotifier.wordList.forEach((element) {
                      data.add(element.toString());
                      print(element.toString());
                    });
                    prefs.setStringList('words', data);
                    prefs.setInt('successRememberedWordsNum',
                        usersDataNotifier.successRememberedWordsNum);
                    prefs.setInt(
                        'wordsCommitted', usersDataNotifier.wordsCommitted);
                    prefs.setInt('currentDayToRemember',
                        usersDataNotifier.currentDayToRemember);
                    prefs.setInt('toRememberWordsNum',
                        usersDataNotifier.toRememberWordsNum);

                    currentWord = getWordNumToRemember(usersDataNotifier);

                    if(usersDataNotifier.currentDayToRemember <= 0 || (currentWord == -1 && rememberedWords > 0)){
                      DateTime date = DateTime.now();
                      prefs.setInt('lastCommitDate', date.millisecondsSinceEpoch);
                    }

                    setState(() {

                    });
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
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop(2);
            },
            child: Text(
              '2 words',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
