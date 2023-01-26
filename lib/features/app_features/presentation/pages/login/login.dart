import 'package:another_flushbar/flushbar_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/assets.dart';
import '../../../../../core/util/device/device_utils.dart';
import '../../../../../core/util/locale/app_localization.dart';
import '../../../../../core/util/routes/routes.dart';
import '../../../../../core/widgets/app_icon_widget.dart';
import '../../../../../core/widgets/empty_app_bar_widget.dart';
import '../../../../../core/widgets/progress_indicator_widget.dart';
import '../../../../../core/widgets/rounded_button_widget.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../../../data/datasources/sharedpref/constants/preferences.dart';
import '../../../domain/usecases/form/form_store.dart';
import '../../../domain/usecases/theme/theme_store.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  late ThemeStore _themeStore;

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;

  //stores:---------------------------------------------------------------------
  final _store = FormStore();

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
  }

  Future<void> resetPassword(String email) async {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((e) {
      return _showMessage("Reset Password Mail Sent");
    }).catchError((error) {
      return showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text("Unable to send password reset mail"),
              actions: <Widget>[
                InkWell(
                    child: const Text("OK"),
                    onTap: () {
                      Navigator.pop(context);
                    })
              ],
            );
          });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeStore = Provider.of<ThemeStore>(context);
  }

  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((error) {
      if (kDebugMode) {
        print(error.code);
      }
      if (error.code == "invalid-email") {
        return _showErrorMessage("Invalid Email Address");
      }
      if (error.code == "wrong-password") {
        return _showErrorMessage("Incorrect Password");
      }
      if (error.code == "user-not-found") {
        return _showErrorMessage("Incorrect Password");
      }
    }).then((_) {
      _store.login();
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool(Preferences.is_logged_in, true);
      });
      Future.delayed(const Duration(milliseconds: 0), () {
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.organizationList, (Route<dynamic> route) => false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          MediaQuery.of(context).orientation == Orientation.landscape
              ? Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: _buildRightSide(),
                    ),
                  ],
                )
              : Center(child: _buildRightSide()),
          Observer(
            builder: (context) {
              return _store.success
                  ? navigate(context)
                  : _showErrorMessage(_store.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _store.loading,
                child: const CustomProgressIndicatorWidget(),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildRightSide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(46.0),
              child: _themeStore.darkMode
                  ? const AppIconWidget(image: 'assets/images/kanban.png')
                  : const AppIconWidget(image: 'assets/images/kanban.png'),
            ),
            const SizedBox(height: 14.0),
            Container(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 8.0, bottom: 25.0),
              decoration: BoxDecoration(
                color: _themeStore.darkMode ? Colors.grey : Colors.white,
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 1.0),
                      blurRadius: 1.0),
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, -1.0),
                      blurRadius: 1.0),
                ],
              ),
              child: Column(
                children: [
                  _buildUserIdField(),
                  _buildPasswordField(),
                ],
              ),
            ),
            _buildForgotPasswordButton(),
            _buildSignInButton(),
            _buildSignUpButton()
          ],
        ),
      ),
    );
  }

  Widget _buildUserIdField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          textColor: Theme.of(context).primaryTextTheme.bodyText2!.color,
          hint: AppLocalizations.of(context).translate('login_et_user_email'),
          inputType: TextInputType.emailAddress,
          icon: Icons.person,
          iconColor: _themeStore.darkMode ? Colors.black : Colors.blue,
          hintColor: _themeStore.darkMode ? Colors.black : Colors.blue,
          textController: _userEmailController,
          inputAction: TextInputAction.next,
          autoFocus: false,
          onChanged: (value) {
            _store.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _store.formErrorStore.userEmail,
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          textColor: Theme.of(context).primaryTextTheme.bodyText2!.color,
          hint:
              AppLocalizations.of(context).translate('login_et_user_password'),
          isObscure: true,
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.black : Colors.blue,
          hintColor: _themeStore.darkMode ? Colors.black : Colors.blue,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: _store.formErrorStore.password,
          onChanged: (value) {
            _store.setPassword(_passwordController.text);
          },
        );
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: FractionalOffset.centerRight,
      child: TextButton(
        child: Text(
          AppLocalizations.of(context).translate('login_btn_forgot_password'),
          style:
              Theme.of(context).textTheme.caption?.copyWith(color: Colors.blue),
        ),
        onPressed: () {
          _showBoardBottomSheet(context);
        },
      ),
    );
  }

  Widget _buildSignInButton() {
    return RoundedButtonWidget(
      buttonText: AppLocalizations.of(context).translate('login_btn_sign_in'),
      buttonColor: Colors.blue,
      textColor: Colors.white,
      onPressed: () async {
        if (_store.canLogin) {
          DeviceUtils.hideKeyboard(context);
          login(_userEmailController.text, _passwordController.text);
          _store.login();
        } else {
          _showErrorMessage('Please fill in all fields');
        }
      },
    );
  }

  Widget _buildSignUpButton() {
    return Align(
      alignment: FractionalOffset.center,
      child: TextButton(
        child: Text(
          AppLocalizations.of(context).translate('signup_btn_sign_in'),
          style:
              Theme.of(context).textTheme.caption?.copyWith(color: Colors.blue),
        ),
        onPressed: () {
          Navigator.pushNamed(context, Routes.signup);
        },
      ),
    );
  }

  Widget navigate(BuildContext context) {
    return Container();
  }

  // General Methods:-----------------------------------------------------------
  _showErrorMessage(String message) {
    if (message.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 0), () {
        if (message.isNotEmpty) {
          FlushbarHelper.createError(
            message: message,
            title: AppLocalizations.of(context).translate('home_tv_error'),
            duration: const Duration(seconds: 3),
          ).show(context);
        }
      });
    }

    return const SizedBox.shrink();
  }

  void _showBoardBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 15.0, left: 10.0, right: 10.0, bottom: 15.0),
                      child: _buildCreateBoardForm(),
                    ),
                  ]),
            );
          });
        });
  }

  Widget _buildCreateBoardForm() {
    return Container(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.supervised_user_circle_outlined,
                      color: _themeStore.darkMode
                          ? Colors.white
                          : Colors.blue.shade200),
                  const SizedBox(width: 15.0),
                  const Text("Reset Password"),
                ],
              ),
              const SizedBox(width: 10.0),
              OutlinedButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.black45,
                    disabledForegroundColor: Colors.red.withOpacity(0.38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(255.0),
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close,
                    color:
                        _themeStore.darkMode ? Colors.white : Colors.black45),
              ),
            ],
          ),
          const SizedBox(
            height: 20.0,
          ),
          Observer(builder: (context) {
            return TextFieldWidget(
              textColor: Theme.of(context).primaryTextTheme.bodyText2!.color,
              hint:
                  AppLocalizations.of(context).translate('login_et_user_email'),
              inputType: TextInputType.emailAddress,
              icon: Icons.person,
              iconColor: _themeStore.darkMode ? Colors.black : Colors.blue,
              hintColor: _themeStore.darkMode ? Colors.black : Colors.blue,
              textController: _userEmailController,
              inputAction: TextInputAction.next,
              autoFocus: false,
              onChanged: (value) {
                _store.setUserId(_userEmailController.text);
              },
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(_passwordFocusNode);
              },
              errorText: _store.formErrorStore.userEmail,
            );
          }),
          const SizedBox(
            height: 40.0,
          ),
          Observer(
            builder: (context) {
              return ElevatedButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      disabledForegroundColor: Colors.red.withOpacity(0.38),
                      minimumSize: const Size(128, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      )),
                  onPressed: () async {
                    if (_userEmailController.text != "") {
                      DeviceUtils.hideKeyboard(context);
                      resetPassword(_userEmailController.text);
                    } else {
                      _showErrorMessage('Please fill in all fields');
                    }
                  },
                  child: const Text('Reset Password',
                      style: TextStyle(color: Colors.white)));
            },
          )
        ],
      ),
    );
  }

  _showMessage(String message) {
    Future.delayed(const Duration(milliseconds: 0), () {
      FlushbarHelper.createLoading(
        linearProgressIndicator: const LinearProgressIndicator(),
        message: message,
        title: "Message Sent",
        duration: const Duration(seconds: 2),
      ).show(context);
    });

    return const SizedBox.shrink();
  }

  // dispose:-------------------------------------------------------------------
  @override
  void dispose() {
    // Clean up the controller when the Widget is removed from the Widget tree
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
