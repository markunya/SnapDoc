import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snap_doc/constants.dart';
import 'package:snap_doc/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';
import 'package:snap_doc/pages/document_page.dart';
import 'package:path/path.dart' as pt;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            backgroundColor: AppColors.appBar,
            title: Padding(
              padding: EdgeInsets.all(Dimensions.generalPadding),
              child: TextW(text: AppStrings.appName,
                           size: Dimensions.appBarAppNameFontSize,
                           weight: FontWeight.w800),
            ),
            elevation: 0,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.generalPadding),
            child: const Center(
              child: ScreenWithListOfDocuments(),
            ),
          ),
          // Sets the background color of the Scaffold
        ),
    );

  }
}

class BottomNavigationView extends StatelessWidget {
  const BottomNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0.0, 0.0),
      child: Container(
        decoration: ShapeDecoration(
          color: AppColors.bottomAppBar,
          shape: MyBorderShape(),
          shadows: const [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8.0,
                offset: Offset(1, 1)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(height: Dimensions.bottomAppBarHeight),
            SizedBox(height: Dimensions.bottomAppBarHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildMiddleTabItem() {
    return const Expanded(
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 0),
            Text(''),
          ],
        ),
      ),
    );
  }
}

class MyBorderShape extends ShapeBorder {
  MyBorderShape();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  double holeSize = Dimensions.bottomAppBarHoleSize;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path.combine(
      PathOperation.difference,
      Path()
        ..addRRect(
            RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)))
        ..close(),
      Path()
        ..addOval(Rect.fromCenter(
            center: rect.center.translate(0, -rect.height / 2),
            height: holeSize,
            width: holeSize))
        ..close(),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

class DocumentsList extends ChangeNotifier {
    final List<Document> _documents = [];

    Future<void> load(dynamic context) async {
      _documents.clear();
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final dir = await getExternalStorageDirectory();
        if (dir == null) {
          ToastNotification(AppStrings.somethingWentWrongWithStorageToast, context);
          return;
        }
        final snapDocDir = Directory(pt.join(dir.path, AppStrings.appName));
        if (!await snapDocDir.exists()) {
          await snapDocDir.create(recursive: true);
        }
        final folderList = snapDocDir.listSync().whereType<Directory>().toList();
        for (int i = 0; i < folderList.length; ++i) {
            _documents.add(Document(
            name: pt.basename(folderList[i].path),
            directory: folderList[i]));
        }
        notifyListeners();
      } else {
        ToastNotification(AppStrings.noPermissionToStorageToast, context);
      }
    }

    Future<void> create(String name, dynamic context) async {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          ToastNotification(AppStrings.somethingWentWrongWithStorageToast, context);
          return;
        }
        final snapDocDir = Directory(pt.join(directory.path, AppStrings.appName));
        final newDirectory = Directory(pt.join(snapDocDir.path, name));

        if (!await newDirectory.exists()) {
          await newDirectory.create(recursive: true);
          _documents.add(Document(name: pt.basename(newDirectory.path), directory: newDirectory));
          notifyListeners();
        }
      } else {
      ToastNotification(AppStrings.noPermissionToStorageToast, context);
      }
    }

    int size() {
      return _documents.length;
    }

    String getName(int index) {
      return _documents[index].name;
    }

    Document get(int index) {
      return _documents[index];
    }

    Future<void> delete(int index, dynamic context) async {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          ToastNotification(AppStrings.somethingWentWrongWithStorageToast, context);
          return;
        }
        final snapDocDir = Directory(pt.join(directory.path, AppStrings.appName, _documents[index].name));
        if (await snapDocDir.exists()) {
          await snapDocDir.delete(recursive: true);
            _documents.removeAt(index);
            notifyListeners();
        }
      } else {
        ToastNotification(AppStrings.noPermissionToStorageToast, context);
      }
    }

    Future<void> rename(int index, String newName, dynamic context) async {
      final newFolderPath = pt.join(_documents[index].directory.parent.path, newName);
      try {
        await _documents[index].directory.rename(newFolderPath);
        _documents[index].name = newName;
        notifyListeners();
      } catch (e) {
        ToastNotification(AppStrings.failedToRenameDocumentToast, context);
      }
    }
}

class ScreenWithListOfDocuments extends StatefulWidget {
  const ScreenWithListOfDocuments({super.key});

  @override
  _ScreenWithListOfDocumentsState createState() => _ScreenWithListOfDocumentsState();

}

class _ScreenWithListOfDocumentsState extends State<ScreenWithListOfDocuments> {
  final Set<String> _usedNames = {};
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DocumentsList>(context, listen: false).load(context);
    });
    _usedNames.clear();
    for (int i = 0; i < Provider.of<DocumentsList>(context, listen: false).size(); ++i) {
      _usedNames.add(Provider.of<DocumentsList>(context, listen: false).getName(i));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addDocumentDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: TextW(text: AppStrings.addDocumentDialogTitle,
            size: Dimensions.headerFontSize,
            weight: FontWeight.w600,
           ),
        content: TextField(
            controller: _controller,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textFormFieldUnderlineColor
                ),
              ),
              hintText: AppStrings.addDocumentDialogInputHint,
              hintStyle: TextStyle(
                color: AppColors.addDocumentDialogHintColor,
              ),
            )
        ),
        actions: [
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColors.addDocumentDialogSaveButton),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.addDocumentDialogSaveButtonBorderRadius
                    ),
                  ),
                ),
              ),
              onPressed: (){
                String name = _controller.text.trim();
                if (name.isEmpty) {
                  ToastNotification(AppStrings.emptyDocumentNameToast, context);
                  return;
                }
                if (_usedNames.contains(name)) {
                  ToastNotification(AppStrings.documentWithSuchNameAlreadyExistsToast, context);
                  return;
                }
                _controller.clear();
                Provider.of<DocumentsList>(context, listen: false).create(name, context);
                _usedNames.add(name);
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.all(
                    Dimensions.addDocumentDialogSaveButtonPadding
                ),
                child: TextW(
                    text: AppStrings.addDocumentDialogSaveButton,
                    size: Dimensions.textFontSize,
                    color: AppColors.dialogBackground,
                    weight: FontWeight.w600,
                ),
              ))
        ],
      )
  );

  Future<void> _renameDocumentDialog(int index) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: TextW(text: AppStrings.renameDocumentDialogTitle,
          size: Dimensions.headerFontSize,
          weight: FontWeight.w600,
        ),
        content: TextField(
            controller: _controller,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.textFormFieldUnderlineColor
                ),
              ),
              hintText: AppStrings.addDocumentDialogInputHint,
              hintStyle: TextStyle(
                color: AppColors.addDocumentDialogHintColor,
              ),
            )
        ),
        actions: [
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColors.addDocumentDialogSaveButton),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.addDocumentDialogSaveButtonBorderRadius
                    ),
                  ),
                ),
              ),
              onPressed: (){
                String name = _controller.text.trim();
                if (name.isEmpty) {
                  ToastNotification(AppStrings.emptyDocumentNameToast, context);
                  return;
                }
                if (_usedNames.contains(name)) {
                  ToastNotification(AppStrings.documentWithSuchNameAlreadyExistsToast, context);
                  return;
                }
                _controller.clear();
                _usedNames.remove(Provider.of<DocumentsList>(context, listen: false).getName(index));
                Provider.of<DocumentsList>(context, listen: false).rename(index, name, context);
                _usedNames.add(name);
                Navigator.pop(context);
              },
              child: Padding(
                padding: EdgeInsets.all(
                    Dimensions.addDocumentDialogSaveButtonPadding
                ),
                child: TextW(
                  text: AppStrings.renameDocumentDialogButtonText,
                  size: Dimensions.textFontSize,
                  color: AppColors.dialogBackground,
                  weight: FontWeight.w600,
                ),
              ))
        ],
      )
  );

  Future<void> _longPressDialog(int index) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.dialogBackground,
        title: TextW(
          text: Provider.of<DocumentsList>(context, listen: false).getName(index),
          size: Dimensions.headerFontSize,
          weight: FontWeight.w600,
          textAlign: TextAlign.center,
        ),
        content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Divider(
                color: Palette.dimLightBlue, // Задайте нужный цвет черты
                thickness: 1, // Толщина черты
              ),
              TextButton(
                  child: Padding(
                    padding: EdgeInsets.all(Dimensions.addDocumentDialogSaveButtonPadding),
                    child: TextW(text: AppStrings.documentLongPressDialogRename,
                      size: Dimensions.textFontSize,
                    ),
                  ),
                  onPressed: (){
                    Navigator.pop(context);
                    _renameDocumentDialog(index);
                  }),
              TextButton(
                  child: Padding(
                    padding: EdgeInsets.all(Dimensions.addDocumentDialogSaveButtonPadding),
                    child: TextW(text: AppStrings.documentLongPressDialogDelete,
                      size: Dimensions.textFontSize,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: (){
                    _usedNames.remove(Provider.of<DocumentsList>(context, listen: false).getName(index));
                    Provider.of<DocumentsList>(context, listen: false).delete(index, context);
                    Navigator.pop(context);
                  }),
            ],
          ),
      ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ScrollConfiguration(
              behavior: DefaultScrollBehavior(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Consumer<DocumentsList>(
                      builder: (context, documentsList, child) {
                        return LayoutGrid(
                          columnSizes: [1.fr, 1.fr, 1.fr],
                          rowSizes: [
                            for(int i = 0; i < (documentsList.size() / 2).round() + 1; ++i)
                              const IntrinsicContentTrackSize(),
                          ],
                          columnGap: Dimensions.gridItemColumnGap,
                          rowGap: Dimensions.gridItemRowGap,
                          children: [
                            for(int i = documentsList.size() - 1; i >= 0; --i)
                              DocumentWidget(
                                documentName: documentsList.getName(i),
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context)
                                      => DocumentPage(document: Provider.of<DocumentsList>(context, listen: false).get(i)),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  _longPressDialog(i);
                                },),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: Dimensions.addDocumentButtonSize),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.background.withOpacity(0.95), // Цвет тени
                    spreadRadius: Dimensions.bottomAppBarShadowSpread, // Радиус распространения тени
                    blurRadius: Dimensions.bottomAppBarShadowRadius, // Размытие тени
                    offset: Offset(0, Dimensions.bottomAppBarShadowOffset), // Смещение тени вверх
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  right: Dimensions.generalPadding,
                  left: Dimensions.generalPadding,
                  bottom: Dimensions.generalPadding,
                ),
                child: const BottomNavigationView(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.background.withOpacity(0.95), // Цвет тени
                    spreadRadius: Dimensions.addDocumentButtonShadowSpread, // Радиус распространения тени
                    blurRadius: Dimensions.addDocumentButtonShadowRadius, // Размытие тени
                    offset: Offset(0, Dimensions.addDocumentButtonShadowOffset), // Смещение тени вверх
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  right: Dimensions.generalPadding,
                  left: Dimensions.generalPadding,
                  bottom: Dimensions.generalPadding,
                ),
                child: SizedBox(
                  width: Dimensions.addDocumentButtonSize,
                  height: Dimensions.addDocumentButtonSize,
                  child: FittedBox(
                    child: FloatingActionButton(
                      shape: const CircleBorder(),
                      onPressed: () {
                        _addDocumentDialog();
                      },
                      backgroundColor: AppColors.addDocumentButton,
                      child: Icon(
                        AppIcons.addDocumentButton,
                        size: Dimensions.addDocumentIconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
    );
  }
}

class DocumentWidget extends StatelessWidget {
  final String documentName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const DocumentWidget({super.key, required this.documentName, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Dimensions.documentWidgetPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              AppIcons.document,
              size: Dimensions.documentWidgetSize,
              color: Palette.lightBlue
            ),
            Flexible(child: TextW(text: documentName, size: Dimensions.textFontSize)),
          ],
        ),
      ),
    );
  }
}
