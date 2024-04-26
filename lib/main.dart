import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snap_doc/constants.dart';
import 'package:snap_doc/pages/home_page.dart';
import 'package:snap_doc/pages/document_page.dart';
import 'package:get/get.dart';
import 'package:snap_doc/native_lib.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NativeLibrary.loadLibrary();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DocumentsList()),
        ChangeNotifierProvider(create: (context) => PagesList()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SnapDoc Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: HomePage(),
    );
  }
}