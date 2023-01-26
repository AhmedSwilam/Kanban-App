import 'package:flutter/material.dart';
import 'package:kanban/core/constants/colors.dart';
import 'package:kanban/core/constants/font_family.dart';

final ThemeData themeData = ThemeData(
    primaryTextTheme:  const TextTheme(
        bodyText1: TextStyle(color: Colors.blue),
        bodyText2: TextStyle(color: Colors.blue)),
    fontFamily: FontFamily.productSans,
    brightness: Brightness.light,
    primaryColor: AppColors.blue[500],
    colorScheme: ColorScheme.fromSwatch(
            primarySwatch:
                MaterialColor(AppColors.blue[500]!.value, AppColors.blue))
        .copyWith(secondary: AppColors.blue[500]));

final ThemeData themeDataDark = ThemeData(
  primaryTextTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.white),
      bodyText2: TextStyle(color: Colors.black)),
  fontFamily: FontFamily.productSans,
  brightness: Brightness.dark,
  primaryColor: AppColors.blue[900],
  primaryColorBrightness: Brightness.dark,
  accentColor: AppColors.blue[900],
  accentColorBrightness: Brightness.dark,
);
