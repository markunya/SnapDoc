import 'package:snap_doc/constants.dart';
import 'package:snap_doc/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PageOfDocumentPage extends StatefulWidget {
  File imageFile;
  
  PageOfDocumentPage({super.key,
    required this.imageFile});

  @override
  _PageOfDocumentPageState createState() => _PageOfDocumentPageState(imageFile: imageFile);
}

class _PageOfDocumentPageState extends State<PageOfDocumentPage> {
  File imageFile;

  _PageOfDocumentPageState({required this.imageFile});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          backgroundColor: AppColors.appBar,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.text),
              onPressed: (){
                Navigator.pop(context);
              }
          ),
          title: Padding(
            padding: EdgeInsets.all(Dimensions.generalPadding),
            child: TextW(text: "",
                size: Dimensions.appBarAppNameFontSize,
                weight: FontWeight.w800),
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(Dimensions.generalPadding),
          child: Center(
            child: Image.file(
                imageFile,
                fit: BoxFit.cover,
            ),
            ),
          ),
      );
  }
}
