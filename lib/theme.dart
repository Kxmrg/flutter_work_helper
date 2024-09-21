import 'dart:io';

import 'package:flutter/material.dart';

class AppTheme {
  static const String Font_Montserrat = 'Montserrat';

  static const String Font_AlibabaHealth = 'AlibabaHealth';

  static const Color themeColor = Color.fromARGB(255, 10, 53, 205);

  static const Color secondaryColor = Colors.orange;

  /// 亮色主题样式
  static ThemeData light = ThemeData(
    useMaterial3: false,
    fontFamily: Platform.isWindows ? Font_AlibabaHealth : Font_Montserrat,
    colorScheme: ColorScheme.fromSeed(
      seedColor: themeColor,
      primary: themeColor,
      secondary: secondaryColor,
      brightness: Brightness.light,
      surface: Colors.white,
      surfaceTint: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color.fromARGB(200, 0, 0, 0),
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(200, 0, 0, 0),
      ),
    ),
  );
}
