import 'package:shared_preferences/shared_preferences.dart';

class MyThemePreferences {
  static const theme = "theme_key";

  setTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(theme, value);
  }

  getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(theme) ?? false;
  }
}
