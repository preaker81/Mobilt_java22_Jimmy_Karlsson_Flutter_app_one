import 'package:shared_preferences/shared_preferences.dart';

class MockDb {
  static bool isLoggedIn = false;
  static const String username = "user";
  static const String password = "pass";

  static Future<bool> checkLogIn(
      String enteredUsername, String enteredPassword) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool result = enteredUsername == username && enteredPassword == password;

    if (result) {
      isLoggedIn = true;
      await sharedPreferences.setBool('isLoggedIn', true);
    }

    return result;
  }

  static Future<void> handleLogout() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isLoggedIn = false;
    await sharedPreferences.setBool('isLoggedIn', false);
  }
}
