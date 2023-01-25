import 'package:another_flushbar/flushbar_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/util/device/device_utils.dart';
import '../../../../../core/util/locale/app_localization.dart';
import '../../../../../core/util/routes/routes.dart';
import '../../../../../core/widgets/progress_indicator_widget.dart';
import '../../../../../core/widgets/rounded_button_widget.dart';
import '../../../../../core/widgets/textfield_widget.dart';
import '../../../data/datasources/sharedpref/constants/preferences.dart';
import '../../../domain/usecases/form/signUp_form_store.dart';
import '../../../domain/usecases/theme/theme_store.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  //text controllers:-----------------------------------------------------------
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  //stores:---------------------------------------------------------------------
  late ThemeStore _themeStore;

  //focus node:-----------------------------------------------------------------
  late FocusNode _passwordFocusNode;
//focus node:-----------------------------------------------------------------
  late FocusNode _confirmPasswordFocusNode;
  //stores:---------------------------------------------------------------------
  final _signupStore = SignUpFormStore();

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeStore = Provider.of<ThemeStore>(context);
  }

  Future<void> signUp(String? email, String? password) async{
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email!, password: password!).catchError((error){
      if(error.code == "email-already-in-use"){
        if (kDebugMode) {
          print(error.code);
        }
       return _showErrorMessage('Email Already in Use');
      }
    }).then((_){
      Navigator.pushNamed(context, Routes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          AppLocalizations.of(context).translate('signup_btn_sign_in'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: _buildBody(),
    );
  }

  // body methods:--------------------------------------------------------------
  Widget _buildBody() {
    return Material(
      child: Stack(
        children: <Widget>[
          _buildRightSide(),
          Observer(
            builder: (context) {
              return _signupStore.success
                  ? navigate(context)
                  : _showErrorMessage(_signupStore.errorStore.errorMessage);
            },
          ),
          Observer(
            builder: (context) {
              return Visibility(
                visible: _signupStore.loading,
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
            const SizedBox(height: 14.0),
            Container(
              margin: const EdgeInsets.only(top: 120),
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
                  _buildConfirmPasswordField(),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            _buildSignInButton(),
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
            _signupStore.setUserId(_userEmailController.text);
          },
          onFieldSubmitted: (value) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
          errorText: _signupStore.formErrorStore.userEmail,
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
              AppLocalizations.of(context).translate('signup_et_user_password'),
          isObscure: true,
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.black : Colors.blue,
          hintColor: _themeStore.darkMode ? Colors.black : Colors.blue,
          textController: _passwordController,
          focusNode: _passwordFocusNode,
          errorText: _signupStore.formErrorStore.password,
          onChanged: (value) {
            _signupStore.setPassword(_passwordController.text);
          },
        );
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return Observer(
      builder: (context) {
        return TextFieldWidget(
          textColor: Theme.of(context).primaryTextTheme.bodyText2!.color,
          hint: AppLocalizations.of(context)
              .translate('signup_et_user_confirm_password'),
          isObscure: true,
          padding: const EdgeInsets.only(top: 16.0),
          icon: Icons.lock,
          iconColor: _themeStore.darkMode ? Colors.black : Colors.blue,
          hintColor: _themeStore.darkMode ? Colors.black : Colors.blue,
          textController: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          errorText: _signupStore.formErrorStore.confirmPassword,
          onChanged: (value) {
            _signupStore.setConfirmPassword(_confirmPasswordController.text);
          },
        );
      },
    );
  }

  Widget _buildSignInButton() {
    return RoundedButtonWidget(
      buttonText: AppLocalizations.of(context).translate('signup_btn_sign_in'),
      buttonColor: Colors.blue,
      textColor: Colors.white,
      onPressed: () async {
        if (_signupStore.canRegister) {
          DeviceUtils.hideKeyboard(context);
          _signupStore.register();
          signUp(_userEmailController.text, _passwordController.text);
        } else {
          _showErrorMessage('Please fill in all fields');
        }
      },
    );
  }

  Widget navigate(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(Preferences.is_logged_in, false);
    });


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
