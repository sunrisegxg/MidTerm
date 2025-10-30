import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:midterm/components/button/btn_sign.dart';
import 'package:midterm/components/textfield/textfield_cre.dart';
import 'package:midterm/model/user.dart';
import 'package:midterm/services/main_page.dart';
import 'package:midterm/services/user_service.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text controllers
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _focusNode3 = FocusNode();
  final _focusNode4 = FocusNode();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText1 = true;
  bool _obscureText2 = true;
  bool _usernameExists = false;
  bool _emailExists = false;

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _focusNode4.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    MainPage.ignoreAuthListener.value = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.green));
      },
    );
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      final userInformation = UserInformation(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        image:
            "https://media.istockphoto.com/id/1192884194/vector/admin-sign-on-laptop-icon-stock-vector.jpg?s=612x612&w=0&k=20&c=W7ClQXF-0UP_9trbNMvC04qUE4f__SOgg6BUdoX6hdQ=",
        password: _passwordController.text.trim(),
      );
      await FirebaseFirestore.instance
          .collection('admin')
          .doc(userCredential.user!.uid)
          .set(userInformation.toMap());
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Register successfully!')));
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _confirmController.clear();
      await Future.delayed(const Duration(milliseconds: 300));
      MainPage.ignoreAuthListener.value = false;
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      MainPage.ignoreAuthListener.value = false;
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
                    'Create account',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  //introduc subtitle
                  Text(
                    'Please enter your valid information to create a new admin account',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  MyTextField(
                    obscureText: false,
                    focusNode: _focusNode1,
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    label: "Username",
                    onSubmitted:
                        (value) =>
                            FocusScope.of(context).requestFocus(_focusNode2),
                    onChanged: (value) async {
                      if (value.isEmpty) return;
                      bool exists = await UserService()
                          .checkUsernameAdminExists(value.trim());
                      setState(() {
                        _usernameExists = exists;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your username";
                      } else if (_usernameExists) {
                        return "Username already exists";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  //textfield email
                  MyTextField(
                    obscureText: false,
                    focusNode: _focusNode2,
                    controller: _emailController,
                    hintText: "example@gmail.com",
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    label: "Email",
                    onSubmitted:
                        (value) =>
                            FocusScope.of(context).requestFocus(_focusNode3),
                    onChanged: (value) async {
                      if (value.isEmpty) return;
                      bool exists = await UserService().checkEmailAdminExists(
                        value.trim(),
                      );
                      setState(() {
                        _emailExists = exists;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      } else if (_emailExists) {
                        return "Email already exists";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  //textfield password
                  MyTextField(
                    obscureText: _obscureText1,
                    focusNode: _focusNode3,
                    controller: _passwordController,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    label: "Password",
                    suffixIcon: IconButton(
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          _obscureText1 = !_obscureText1;
                        });
                      },
                      icon: Icon(
                        _obscureText1 ? Icons.visibility_off : Icons.visibility,
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  //textfield cf-password
                  MyTextField(
                    obscureText: _obscureText2,
                    focusNode: _focusNode4,
                    controller: _confirmController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.visiblePassword,
                    label: "Confirm password",
                    suffixIcon: IconButton(
                      color: Colors.green,
                      onPressed: () {
                        setState(() {
                          _obscureText2 = !_obscureText2;
                        });
                      },
                      icon: Icon(
                        _obscureText2 ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                    onSubmitted: (value) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your confirmation password";
                      } else if (value != _passwordController.text) {
                        return "Password doesn't match";
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
                          await signUp();
                        } catch (e) {
                          log("Error occurred: ${e.toString()}");
                        }
                      }
                    },
                    text: "Sign up",
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  //not a member -> register
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(text: "I have an account? "),
                          TextSpan(
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = widget.showLoginPage,
                            text: "Login now",
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
