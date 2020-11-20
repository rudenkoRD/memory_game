import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_game/notifiers/pages_notifier.dart';
import 'package:memory_game/notifiers/users_data_notifier.dart';
import 'package:memory_game/screens/commit_words_screen.dart';
import 'package:memory_game/screens/stage_test_screen.dart';
import 'package:memory_game/screens/testing_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (BuildContext context) => ScreenNotifier(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => UsersDataNotifier(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int numOfLaunches;
  int lastCommitDateTime;

  Future _getLastCommitDate(context) async {
    final prefs = await SharedPreferences.getInstance();
    lastCommitDateTime = prefs.getInt('lastCommitDate');
    numOfLaunches = prefs.getInt('numberOfLaunches');
    print(numOfLaunches);
    numOfLaunches = numOfLaunches == null ? 0 : numOfLaunches;

    ScreenNotifier screenNotifier =
        Provider.of<ScreenNotifier>(context, listen: false);
    UsersDataNotifier usersDataNotifier = Provider.of<UsersDataNotifier>(context, listen: false);

    bool isEnterStageTestScreen = false;
    for(int i = 0; i < usersDataNotifier.testingStagesList.length; i++){
      if(usersDataNotifier.wordsCommitted >= int.parse(usersDataNotifier.testingStagesList[i]) ) {
        if(usersDataNotifier.testingStageIsComplete[i] == 'false') {
          usersDataNotifier.testingStageIsComplete[i] = 'active';
          prefs.setStringList('testingStageIsComplete', usersDataNotifier.testingStageIsComplete);
          isEnterStageTestScreen = true;
          break;
        }
      }
      if(usersDataNotifier.testingStageIsComplete[i] == 'active'){
        isEnterStageTestScreen = true;
        break;
      }
    }
    print('${usersDataNotifier.testingStageIsComplete.toString()} --- stages-----');
    int currentWord = getWordNumToRemember(usersDataNotifier);

    if(currentWord == -1){
      screenNotifier.currentScreen = Screen.STAGE_TESTING_SCREEN;
    }else if (lastCommitDateTime != null) {
      screenNotifier.currentScreen = isEnterStageTestScreen ? Screen.STAGE_TESTING_SCREEN : Screen.TESTING_SCREEN;
    } else if (numOfLaunches != 0) {
      screenNotifier.currentScreen = Screen.COMMIT_SCREEN;
    } else
      screenNotifier.currentScreen = Screen.WELCOME_SCREEN;
  }

  int getWordNumToRemember(UsersDataNotifier userData) {
    for (int i = 0; i < userData.wordList.length; i++) {
      if (userData.wordList[i].isMemorized == false &&
          userData.wordList[i].mempool == 1) {
        return i;
      }
    }
    return -1;
  }

  _getUserData(context) async {
    String database =
        await rootBundle.loadString('assets/database/databasetest1.csv');
    List<String> tableData = database.split('\n');

    List<String> testingStagesData = tableData[0].split(',');

    List<String> wordsData = tableData.sublist(1);

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getStringList('words') == null) {
      prefs.setStringList('words', wordsData);
    }

    List<List<String>> data = List();
    prefs.getStringList('words').forEach((element) {
      List<String> split = element.split(',');
      data.add(split);
    });

    UsersDataNotifier usersDataNotifier =
        Provider.of<UsersDataNotifier>(context, listen: false);

    usersDataNotifier.totalNumOfWords = data.length;


    usersDataNotifier.testingStagesList = testingStagesData;

    if(prefs.getStringList('testingStageIsComplete') == null) {
      usersDataNotifier.testingStageIsComplete = List.generate(
          testingStagesData.length, (index) => 'false');

      prefs.setStringList('testingStageIsComplete', usersDataNotifier.testingStageIsComplete);
    }else {
      usersDataNotifier.testingStageIsComplete = prefs.getStringList('testingStageIsComplete');
    }

    usersDataNotifier.numberToStageTest = -1;

    final int successRememberedWordsNum =
        prefs.getInt('successRememberedWordsNum');
    usersDataNotifier.successRememberedWordsNum =
        successRememberedWordsNum == null ? 0 : successRememberedWordsNum;

    final wordsCommitted = prefs.getInt('wordsCommitted');
    usersDataNotifier.wordsCommitted =
        wordsCommitted == null ? 0 : wordsCommitted;

    final currentDayToRemember = prefs.getInt('currentDayToRemember');
    usersDataNotifier.currentDayToRemember =
        currentDayToRemember == null ? 4 : currentDayToRemember;

    final toRememberWordsNum = prefs.getInt('toRememberWordsNum');
    usersDataNotifier.toRememberWordsNum =
        toRememberWordsNum == null ? 4 : toRememberWordsNum;

    usersDataNotifier.setWordList(data);

    print('${usersDataNotifier.totalNumOfWords} totalNumOfWords');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getUserData(context);
    _getLastCommitDate(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Memory App',
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          minWidth: 0,
        ),
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<ScreenNotifier>(
        builder: (context, notifier, child) {
          switch (notifier.currentScreen) {
            case Screen.WELCOME_SCREEN:
              return WelcomePage();
            case Screen.COMMIT_SCREEN:
              return CommitWordsScreen();
            case Screen.TESTING_SCREEN:
              return TestingScreen(lastCommitDateTime: lastCommitDateTime,);
            case Screen.STAGE_TESTING_SCREEN:
              return StageTestScreen(lastCommitDateTime: lastCommitDateTime,);
            default:
              return LoadingScreen();
          }
        },
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
    );
  }
}

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Game: Welcome'),
      ),
      body: Container(
        padding: EdgeInsets.all(6.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/welcome_screen_image.jpg'),
              RaisedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setInt('numberOfLaunches', 1);
                  ScreenNotifier screenNotifier =
                      Provider.of<ScreenNotifier>(context, listen: false);
                  screenNotifier.currentScreen = Screen.COMMIT_SCREEN;
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('enter the app',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
