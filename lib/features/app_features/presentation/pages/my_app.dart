import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/di/components/service_locator.dart';
import '../../../../core/util/locale/app_localization.dart';
import '../../../../core/util/routes/routes.dart';
import '../../data/repositories/repository.dart';
import '../../domain/usecases/board/board_list_store.dart';
import '../../domain/usecases/language/language_store.dart';
import '../../domain/usecases/organization/organization_list_store.dart';
import '../../domain/usecases/post/post_store.dart';
import '../../domain/usecases/theme/theme_store.dart';
import '../../domain/usecases/user/user_store.dart';
import 'login/login.dart';
import 'organization/organization.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final ThemeStore _themeStore = ThemeStore(getIt<Repository>());
  final PostStore _postStore = PostStore(getIt<Repository>());
  final OrganizationListStore _organizationListStore = OrganizationListStore(getIt<Repository>());
  final BoardListStore _boardListStore = BoardListStore(getIt<Repository>());
  final LanguageStore _languageStore = LanguageStore(getIt<Repository>());
  final UserStore _userStore = UserStore(getIt<Repository>());

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ThemeStore>(create: (_) => _themeStore),
        Provider<PostStore>(create: (_) => _postStore),
        Provider<OrganizationListStore>(create: (_) => _organizationListStore),
        Provider<BoardListStore>(create: (_) => _boardListStore),
        Provider<LanguageStore>(create: (_) => _languageStore),
      ],
      child: Observer(
        name: 'global-observer',
        builder: (context) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: Strings.appName,
            theme: _themeStore.darkMode ? themeDataDark : themeData,
            routes: Routes.routes,
            locale: Locale(_languageStore.locale),
            supportedLocales: _languageStore.supportedLanguages
                .map((language) => Locale(language.locale!, language.code))
                .toList(),
            localizationsDelegates: const [
              // A class which loads the translations from JSON files
              AppLocalizations.delegate,
              // Built-in localization of basic text for Material widgets
              GlobalMaterialLocalizations.delegate,
              // Built-in localization for text direction LTR/RTL
              GlobalWidgetsLocalizations.delegate,
              // Built-in localization of basic text for Cupertino widgets
              GlobalCupertinoLocalizations.delegate,
            ],
            home: _userStore.isLoggedIn ? OrganizationScreen() : LoginScreen(),
          );
        },
      ),
    );
  }
}
