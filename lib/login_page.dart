import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:midterm/services/user_service.dart';

import 'components/button/btn_sign.dart';
import 'components/textfield/textfield_cre.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controllers
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.green));
      },
    );
    bool existsAdmin = await UserService().checkEmailAdminExists(
      _emailController.text.trim(),
    );
    if (!existsAdmin) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You are not admin.')));
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login successfully!')));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Wrong password.')));
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.1,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //logo
                  Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      "assets/home.png",
                      fit: BoxFit.cover,
                      height: 100,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  //introduc title
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  //introduc subtitle
                  Text(
                    'Enter your email address and password to get access your account.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  //textfield email
                  MyTextField(
                    obscureText: false,
                    focusNode: _focusNode1,
                    controller: _emailController,
                    hintText: "example@gmail.com",
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    label: "Email",
                    onSubmitted:
                        (value) =>
                            FocusScope.of(context).requestFocus(_focusNode2),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  //textfield password
                  MyTextField(
                    obscureText: _obscureText,
                    focusNode: _focusNode2,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    label: "Password",
                    suffixIcon: IconButton(
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    onSubmitted: (value) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                  ), //button signin
                  BtnSign(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      if (_formKey.currentState!.validate()) {
                        try {
                          await login();
                        } catch (e) {
                          log("Error occurred: ${e.toString()}");
                        }
                      }
                    },
                    text: "Sign in",
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  //not a member -> register
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = widget.showRegisterPage,
                            text: "Register now",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
