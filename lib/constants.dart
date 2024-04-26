import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Integrals {
  static const int amountOfCorners = 4;
  static const int amountOfCornersCoordinates = 2 * amountOfCorners;
}

class Palette {
  static const Color transparent = Colors.transparent;
  static const Color lightBlue = Color(0xff789ecb);
  static const Color dimLightBlue = Color(0xff596067);
  static const Color mainBlue = Color(0xff14172D);
  static const Color almostBlack = Color(0xff191919);
  static const Color darkGray = Color.fromARGB(255, 37, 37, 37);
  static const Color grayTextColor = Color.fromARGB(173, 223, 223, 226);
  static const Color red = Color(0xffC41e3a);
  static const Color black = Color.fromARGB(0, 0, 0, 0);
}

class AppColors {
  static const Color shadow = Palette.black;
  static const Color text = Palette.lightBlue;
  static const Color background = Palette.mainBlue;
  static const Color appBar = Palette.mainBlue;
  static const Color addDocumentButton = Palette.lightBlue;
  static const Color bottomAppBar = Palette.lightBlue;
  static const Color dialogBackground = Palette.mainBlue;
  static const Color textFormFieldUnderlineColor = Palette.lightBlue;
  static const Color addDocumentDialogHintColor = Palette.dimLightBlue;
  static const Color addDocumentDialogSaveButton = Palette.lightBlue;
  static const Color toastBackground = Palette.almostBlack;
  static const Color toastText = Palette.lightBlue;
  static const Color buttonBorder = Palette.lightBlue;
  static const Color buttonType1Background = Palette.lightBlue;
  static const Color buttonType1Text = Palette.mainBlue;
  static const Color buttonType2Background = Palette.mainBlue;
  static const Color buttonType2Text = Palette.lightBlue;
  static const Color pageWidgetBorder = Palette.lightBlue;
  static Color pageWidgetGlass = Palette.mainBlue.withOpacity(0.25);
  static const Color deleteButtonColor = Palette.red;
}

class AppIcons {
  static const IconData addDocumentButton = Icons.add;
  static const IconData gallery = Icons.image;
  static const IconData camera = Icons.camera;
  static const IconData download = Icons.download;
  static const IconData goBack = Icons.arrow_back_ios_new;
  static const IconData document = Icons.folder;
}

class AppStrings{
  static const String appName = 'SnapDoc';
  static const String docsFolderName = 'Documents';
  static const String addDocumentDialogTitle = 'Новый документ';
  static const String addDocumentDialogInputHint = 'Придумайте название';
  static const String addDocumentDialogSaveButton = 'Создать';
  static const String emptyDocumentNameToast = 'Придумайте название';
  static const String somethingWentWrongWithStorageToast = 'Что-то пошло не так при попытке обратиться к хранилищу';
  static const String noPermissionToStorageToast = 'Нет разрещения на доступ к хранилищу';
  static const String documentWithSuchNameAlreadyExistsToast = 'Документ с таким именем уже существует';
  static const String nameOfDocumentTooLongToast = 'Название слишком длинное';
  static const String failedToRenameDocumentToast = 'Произошла ошибка при попытке переименовать документ';
  static const String renameDocumentDialogTitle = 'Придумайте новое название';
  static const String renameDocumentDialogButtonText = 'Переименовать';
  static const String documentLongPressDialogRename = 'Переименовать';
  static const String documentLongPressDialogDelete = 'Удалить';
  static const String somethingWentWrong = 'Что-то пошло не так';
  static const String save = 'Сохранить';
  static const String jpgExt = '.jpg';
  static const String pdfExt = '.pdf';
  static const String documentIsEmptyToast = 'Документ пуст';
  static const String documentIsSavedToast = 'Документ сохранен в папку $docsFolderName';
  static const String sureWantDeleteImageToast = 'Вы действительно хотите удалить изображение?';
  static const String imageDeletedToast = 'Изображение удалено';
  static const String imageNotDeletedToast = 'Не удалось удалить изображение';
}

class Dimensions {
  static double screenHeight = Get.context!.height;
  static double screenWidth = Get.context!.width;

  static double border = screenWidth * 1 / 428;
  static double buttonPadding = screenWidth * 3 / 428;
  static double buttonBorderRadius = screenWidth * 50 / 428;
  static double buttonBorderSide = border;
  static double appBarAppNameFontSize = screenWidth * 24 / 428;
  static double generalPadding = screenWidth * 10 / 428;
  static double headerFontSize = screenWidth * 20 / 428;
  static double textFontSize = screenWidth * 16 / 428;
  static double buttonFontSize = screenWidth * 20 / 428;
  static double bottomAppBarHeight = screenHeight * 35 / 926;
  static double addDocumentIconSize = screenWidth * 30 / 428;
  static double bottomAppBarHoleSize = screenWidth * 75 / 428;
  static double addDocumentButtonSize = screenWidth * 60 / 428;

  static double gridItemColumnGap = screenWidth * 12 / 428;
  static double gridItemRowGap = screenWidth * 12 / 428;

  static double bottomAppBarShadowRadius = screenHeight * 20 / 926;
  static double bottomAppBarShadowOffset = -screenHeight * 20 / 926;
  static double bottomAppBarShadowSpread = screenHeight / 926;
  static double addDocumentButtonShadowRadius = screenHeight * 20 / 926;
  static double addDocumentButtonShadowOffset = -bottomAppBarHeight + screenHeight * 5 / 926;
  static double addDocumentButtonShadowSpread = -screenHeight * 10 / 926;

  //dialog
  static double addDocumentDialogSaveButtonPadding = screenWidth * 3 / 428;
  static double addDocumentDialogSaveButtonBorderRadius = screenWidth * 16 / 428;

  //DocumentWidget
  static double documentWidgetPadding = screenWidth * 8 / 428;
  static double documentWidgetSize = screenWidth * 70 / 426;

  //Toast
  static double toastNotificationFontSize = screenWidth * 18 / 428;
  static double toastNotificationHorizontalMargin = screenWidth * 20 / 428;
  static double toastNotificationVerticalPadding = screenWidth * 7 / 428;
  static double toastNotificationHorizontalPadding = screenWidth * 10 / 428;
  static double toastNotificationBorderRadius = screenWidth * 10 / 428;

  //DocumentPage
  static double takePhotoButtonHeight = screenHeight * 35 / 926;
  static double takePhotoButtonWidth = (screenWidth - 2 * generalPadding) / 2;
  static double takePhotoButtonMargin = screenWidth * 8 / 428;
  static double pageWidgetWidth = (screenWidth - generalPadding) / 3;
  static double pageWidgetHeight = pageWidgetWidth * 1.5;
  static double pageWidgetBorderRadius = screenWidth * 10 / 428;

  //borderAdjustmentPage
  static double saveImageButtonWidth = screenWidth - 2 * generalPadding;
  static double draggableCornerSize = screenWidth * 30 / 428;
  static double stackBorderAdjustmentHeight = screenHeight * 0.8;
  static double stackBorderAdjustmentWidth = screenWidth - 2 * generalPadding - draggableCornerSize;
}