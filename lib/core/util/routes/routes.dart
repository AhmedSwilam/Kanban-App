
import 'package:flutter/material.dart';

import '../../../features/app_features/presentation/pages/board/board.dart';
import '../../../features/app_features/presentation/pages/home/home.dart';
import '../../../features/app_features/presentation/pages/login/login.dart';
import '../../../features/app_features/presentation/pages/organization/organization.dart';
import '../../../features/app_features/presentation/pages/signup/signup.dart';
import '../../../features/app_features/presentation/pages/splash/splash.dart';

class Routes {
  Routes._();

  //static variables
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String organizationList = '/organizationList';
  static const String board = '/board';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => LoginScreen(),
    signup: (BuildContext context) => SignupScreen(),
    home: (BuildContext context) => HomeScreen(),
    organizationList: (BuildContext context) => OrganizationScreen(),
    board: (BuildContext context) => BoardScreen(),
  };
}