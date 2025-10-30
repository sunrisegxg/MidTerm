import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:midterm/services/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    // thanh trang thai
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // nen trong suot
      statusBarIconBrightness: Brightness.dark, // icon toi
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Midterm',
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
