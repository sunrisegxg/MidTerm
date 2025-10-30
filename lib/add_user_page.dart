import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midterm/components/button/btn_save.dart';
import 'package:midterm/components/textfield/textfield_cre.dart';
import 'package:midterm/model/user.dart';
import 'package:midterm/services/user_service.dart';
import 'package:midterm/storage/add_data_image.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _focusNode1 = FocusNode();
  final _focusNode2 = FocusNode();
  final _focusNode3 = FocusNode();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  Uint8List? _image;
  File? selectedImage;
  String? usernameError;
  String? emailError;

  @override
  void dispose() {
    _focusNode1.dispose();
    _focusNode2.dispose();
    _focusNode3.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> addUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.green));
      },
    );
    String imageUrl = "";
    if (_image != null) {
      imageUrl = await StoreDataImageProfile().uploadImageToStorage(
        _emailController.text.trim(),
        _image!,
      );
    }
    final userInformation = UserInformation(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      image:
          _image != null
              ? imageUrl
              : "https://cdn-icons-png.flaticon.com/512/3177/3177440.png",
      password: _passwordController.text.trim(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .add(userInformation.toMap());
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('User added successfully!')));
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    Navigator.of(context).pop();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    setState(() {
      selectedImage = file;
      _image = file.readAsBytesSync();
    });

    if (mounted) Navigator.of(context).pop();
  }

  // function upload image
  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      // backgroundColor: Colors.green[100],
      context: context,
      builder: (builder) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 190,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  width: 100,
                  height: 3,
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              size: 17,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Choose image from gallery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    _pickImage(ImageSource.camera);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.camera,
                              size: 17,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Take a photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Divider(thickness: 1.2, color: Colors.grey),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.close,
                              size: 17,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add user',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        leadingWidth: 50,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          BtnSave(
            text: 'Save',
            onTap: () async {
              bool usernameExists = await UserService().checkUsernameExists(
                _usernameController.text.trim(),
              );
              bool emailExists = await UserService().checkEmailExists(
                _emailController.text.trim(),
              );
              if (usernameExists) {
                if (!mounted) return;
                setState(() {
                  usernameError = "Username already exists";
                });
              } else {
                setState(() {
                  usernameError = null;
                });
              }
              if (emailExists) {
                if (!mounted) return;
                setState(() {
                  emailError = "Email already exists";
                });
                return;
              } else {
                setState(() {
                  emailError = null;
                });
              }
              if (!_formKey.currentState!.validate()) return;
              await addUser();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      Center(
                        child: ClipOval(
                          child:
                              _image != null
                                  ? Image.memory(
                                    _image!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.asset(
                                    'assets/avatar.png',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 190,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.green[200],
                          ),
                          child: IconButton(
                            onPressed: () {
                              showImagePickerOption(context);
                            },
                            icon: const Icon(Icons.add_a_photo),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  MyTextField(
                    obscureText: false,
                    focusNode: _focusNode1,
                    controller: _usernameController,
                    hintText: "example",
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    label: "Username",
                    errorText: usernameError,
                    onSubmitted:
                        (value) =>
                            FocusScope.of(context).requestFocus(_focusNode2),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your username";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  MyTextField(
                    obscureText: false,
                    focusNode: _focusNode2,
                    controller: _emailController,
                    hintText: "example@gmail.com",
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    label: "Email",
                    errorText: emailError,
                    onSubmitted:
                        (value) =>
                            FocusScope.of(context).requestFocus(_focusNode3),
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
                    focusNode: _focusNode3,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
