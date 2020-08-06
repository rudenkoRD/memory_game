import 'package:flutter/cupertino.dart';

class ScreenNotifier with ChangeNotifier{
  Screen _currentScreen;

  set currentScreen(newValue) {
    _currentScreen = newValue;
    notifyListeners();
  }

  get currentScreen => _currentScreen;
}

enum Screen{
  COMMIT_SCREEN,
  TESTING_SCREEN,
  WELCOME_SCREEN,
  STAGE_TESTING_SCREEN,
}