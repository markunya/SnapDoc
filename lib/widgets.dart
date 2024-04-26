import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snap_doc/constants.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

//MyText(text: 'abcdfghijklm', color: AppColors.lightBlueColor, size: 15, weight: FontWeight.w900)

class DefaultScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class Document {
  String name;
  Directory directory;
  Document({required this.name, required this.directory});
}

class TextW extends StatelessWidget {
  final Color color;
  final String text;
  double size;
  FontWeight weight;
  var textAlign;
  bool fittedBox;

  TextW({Key? key,
    required this.text,
    required this.size,
    this.color = AppColors.text,
    this.weight = FontWeight.w400,
    this.textAlign = TextAlign.left,
    this.fittedBox = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return fittedBox == true ? FittedBox(
      child: Text(
          text,
          textAlign:textAlign ,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontFamily: 'Roboto',
            fontWeight: weight,

          )),
    )
        :  Text(
        text,
        softWrap:true,
        textAlign:textAlign ,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontFamily: 'Roboto',
          fontWeight: weight,
        ));
  }
}

void ToastNotification(String message, context) {
  showToast(
      message,
      context: context,
      backgroundColor: AppColors.toastBackground,
      borderRadius: BorderRadius.circular(Dimensions.toastNotificationBorderRadius),
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      startOffset: Offset(0.0, -2.0),
      reverseEndOffset: Offset(0.0, -5.0),
      position: StyledToastPosition.top,
      duration: Duration(milliseconds: 2500),
      animDuration: Duration(seconds: 1),
      textPadding: EdgeInsets.symmetric(
        horizontal: Dimensions.toastNotificationHorizontalPadding,
        vertical: Dimensions.toastNotificationVerticalPadding,
      ),
      toastHorizontalMargin: Dimensions.toastNotificationHorizontalMargin,
      textStyle: TextStyle(
        fontSize: Dimensions.textFontSize,
        color: AppColors.toastText,
      ),
      fullWidth: true,
      curve: Curves.elasticOut,
      reverseCurve: Curves.fastOutSlowIn
  );
}
