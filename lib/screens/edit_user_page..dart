import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midterm/components/button/btn_save.dart';
import 'package:midterm/components/textfield/textbox.dart';
import 'package:midterm/components/textfield/textfield_cre.dart';
import 'package:midterm/model/user.dart';
import 'package:midterm/services/user_service.dart';
import 'package:midterm/storage/add_data_image.dart';

class EditUserPage extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String image;
  const EditUserPage({
    super.key,
    required this.username,
    required this.email,
    required this.password,
    required this.image,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  String? userId;
  final _focusNode1 = FocusNode();
  Uint8List? _image;
  File? selectedImage;
  bool _obscureText = true;
  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  @override
  void dispose() {
    _focusNode1.dispose();
    super.dispose();
  }

  Future<void> fetchUserId() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: widget.email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          userId = querySnapshot.docs.first.id; // 🔹 Lưu ID vào biến
        });
        log("User ID: $userId");
      } else {
        log("Không tìm thấy user với email: ${widget.email}");
      }
    } catch (e) {
      log("Lỗi khi lấy user id: $e");
    }
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

  void saveProfile() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) {
        return Center(child: CircularProgressIndicator(color: Colors.green));
      },
    );
    if (_image != null) {
      try {
        // Lưu ảnh vào Firebase Storage và lấy URL ảnh
        String imageUrl = await StoreDataImageProfile().uploadImageToStorage(
          widget.email,
          _image!,
        );
        await FirebaseFirestore.instance.collection('users').doc(userId).update(
          {'image': imageUrl},
        );
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile image saved successfully')),
        );
      } catch (e) {
        // Xử lý lỗi
        print('Error: $e');
      }
    }
  }

  void showEditField(
    BuildContext context,
    String fieldName,
    String value,
    String subtitle,
    String field,
  ) {
    final TextEditingController controller = TextEditingController(text: value);
    final formKey = GlobalKey<FormState>();
    String? firebaseError;
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Header custom
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor: WidgetStateColor.resolveWith(
                                    (states) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return Colors.red.withValues(
                                          alpha: 0.5,
                                        );
                                      }
                                      return Colors.red;
                                    },
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  padding: WidgetStateProperty.all(
                                    EdgeInsets.zero,
                                  ),
                                  minimumSize: WidgetStateProperty.all(
                                    const Size(0, 0),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  "Huỷ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Text(
                                fieldName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  if (formKey.currentState!.validate()) {
                                    if (field == "username") {
                                      bool exists = await UserService()
                                          .checkUsernameExists(
                                            controller.text.trim(),
                                          );
                                      if (exists) {
                                        setModalState(() {
                                          firebaseError =
                                              "Username already exists!";
                                        });
                                        return;
                                      } else {
                                        setModalState(() {
                                          firebaseError = null;
                                        });
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(userId)
                                            .update({
                                              field: controller.text.trim(),
                                            });
                                      }
                                    } else if (field == "email") {
                                      bool exists = await UserService()
                                          .checkEmailExists(
                                            controller.text.trim(),
                                          );
                                      if (exists) {
                                        setModalState(() {
                                          firebaseError =
                                              "Email already exists!";
                                        });
                                        return;
                                      } else {
                                        setModalState(() {
                                          firebaseError = null;
                                        });
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(userId)
                                            .update({
                                              field: controller.text.trim(),
                                            });
                                      }
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(userId)
                                          .update({
                                            field: controller.text.trim(),
                                          });
                                    }
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ButtonStyle(
                                  foregroundColor: WidgetStateColor.resolveWith(
                                    (states) {
                                      if (states.contains(
                                        WidgetState.pressed,
                                      )) {
                                        return Colors.green.withValues(
                                          alpha: 0.5,
                                        );
                                      }
                                      return Colors.green;
                                    },
                                  ),
                                  splashFactory: NoSplash.splashFactory,
                                  padding: WidgetStateProperty.all(
                                    EdgeInsets.zero,
                                  ),
                                  minimumSize: WidgetStateProperty.all(
                                    const Size(0, 0),
                                  ),
                                ),
                                child: const Text(
                                  "Lưu",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                fieldName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 10),
                              MyTextField(
                                suffixIcon:
                                    field == 'password'
                                        ? IconButton(
                                          color: Colors.green,
                                          onPressed: () {
                                            setModalState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                          icon: Icon(
                                            _obscureText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                        )
                                        : null,
                                obscureText:
                                    field == 'password' ? _obscureText : false,
                                focusNode: _focusNode1,
                                controller: controller,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                numBorder: 6,
                                hintText: "Add your $field",
                                errorText:
                                    field == 'username' || field == 'email'
                                        ? firebaseError
                                        : null,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Cannot be empty!";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 5),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
          'Edit user',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            // color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        leadingWidth: 50,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body:
          userId == null
              ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
              : StreamBuilder<DocumentSnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.green),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final userInfo = UserInformation.fromMap(
                    snapshot.data!.data() as Map<String, dynamic>,
                  );
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Change avatar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //profile pic
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
                                            : CachedNetworkImage(
                                              width: 100,
                                              height: 100,
                                              imageUrl: userInfo.image,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
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
                            // const SizedBox(width: 10),
                            BtnSave(text: "Save", onTap: () => saveProfile()),
                          ],
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Account info',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        MyTextBox(
                          text: userInfo.username,
                          sectionName: 'Username',
                          onPressed:
                              () => showEditField(
                                context,
                                'Username',
                                userInfo.username,
                                'Here you can update your username if you want to make changes.',
                                'username',
                              ),
                        ),
                        MyTextBox(
                          text: userInfo.email,
                          sectionName: 'Email',
                          onPressed:
                              () => showEditField(
                                context,
                                'Email',
                                userInfo.email,
                                'Here you can update your email if you want to make changes.',
                                'email',
                              ),
                        ),
                        MyTextBox(
                          text: "********",
                          sectionName: 'Password',
                          onPressed:
                              () => showEditField(
                                context,
                                'Password',
                                userInfo.password,
                                'Here you can update your password if you want to make changes.',
                                'password',
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
