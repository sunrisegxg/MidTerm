import 'package:flutter/material.dart';
import 'package:midterm/login_page.dart';
import 'package:midterm/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isShowLogin = true;
  void toggleScreen() {
    setState(() {
      isShowLogin = !isShowLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isShowLogin) {
      return LoginPage(showRegisterPage: toggleScreen);
    } else {
      return RegisterPage(showLoginPage: toggleScreen);
    }
  }
}
