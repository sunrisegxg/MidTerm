import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midterm/services/auth_page.dart';
import 'package:midterm/user_management_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
  static final ValueNotifier<bool> ignoreAuthListener = ValueNotifier(false);
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: MainPage.ignoreAuthListener,
      builder: (context, ignore, child) {
        return StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            log(
              "Firebase Auth State: ${snapshot.connectionState}, admin: ${snapshot.data}",
            );
            if (ignore) {
              return AuthPage();
            }
            //user is logged in
            if (snapshot.hasData) {
              return UserManagementPage();
              // user is not logged in
            } else {
              return AuthPage();
            }
          },
        );
      },
    );
  }
}
