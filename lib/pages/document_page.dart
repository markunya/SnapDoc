import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:snap_doc/constants.dart';
import 'package:snap_doc/pages/page_of_document_page.dart';
import 'package:snap_doc/widgets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:snap_doc/pages/border_adjustment_page.dart';
import 'package:snap_doc/native_lib.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class Page {
  File file;
  Page({required this.file});
}

class PagesList extends ChangeNotifier {
  final List<Page> _data = [];

  Future<void> load(Directory directory, dynamic context) async {
    _data.clear();
    if (!await directory.exists()) {
      ToastNotification(AppStrings.somethingWentWrong, context);
      return;
    }
    List<FileSystemEntity> files = await directory.list().where((entity) {
      return entity is File && entity.path.endsWith(AppStrings.jpgExt);
    }).toList();

    _data.clear();

    for (var fileEntity in files) {
      _data.add(Page(file: fileEntity as File));
    }

    notifyListeners();
  }

  int size() {
    return _data.length;
  }

  void clear() {
    _data.clear();
    notifyListeners();
  }

  Page get(int index) {
    return _data[index];
  }

  void remove(int index) {
    _data.removeAt(index);
    notifyListeners();
  }
}

class PageWidget extends StatelessWidget {
  final int index;
  final void Function() onLongPress;
  final void Function() onTap;

  const PageWidget({Key? key, required this.index, required this.onLongPress, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var page = Provider.of<PagesList>(context, listen: false).get(index);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: Dimensions.pageWidgetWidth,
        height: Dimensions.pageWidgetHeight,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.pageWidgetBorder,
            width: Dimensions.border,
          ),
          borderRadius: BorderRadius.circular(Dimensions.pageWidgetBorderRadius),
          color: AppColors.background,
        ),
        child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.pageWidgetBorderRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      page.file,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: AppColors.pageWidgetGlass,
                    ),
                  ],
                ),
            ),
          ),
      );
  }
}

class DocumentPage extends StatelessWidget {
  final Document document;

  const DocumentPage({super.key, required this.document});

  Future<void> _createPdf(BuildContext context) async {
    int len = Provider.of<PagesList>(context, listen: false).size();
    if (len == 0) {
      ToastNotification(AppStrings.documentIsEmptyToast, context);
      return;
    }
    final pdf = pw.Document();
    for (int i = Provider.of<PagesList>(context, listen: false).size() - 1; i >= 0; --i) {
      try {
        final fileBytes = await Provider.of<PagesList>(context, listen: false).get(i).file.readAsBytes();
        final image = img.decodeImage(fileBytes);
        if (image == null) {
          ToastNotification(AppStrings.somethingWentWrong, context);
          continue;
        }
        final pdfImage = pw.MemoryImage(img.encodeJpg(image));

        pdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4.copyWith(marginBottom: 0, marginTop: 0, marginLeft: 0, marginRight: 0),
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(pdfImage));
            }
        ));
      } catch (e) {
        ToastNotification(AppStrings.somethingWentWrong, context);
        break;
      }
    }

    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir == null) {
        ToastNotification(AppStrings.somethingWentWrong, context);
        return;
      }
      final output = Path.join(extDir.path, AppStrings.docsFolderName);
      final outputDir = Directory(output);
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
      final file = File(Path.join(output, document.name + AppStrings.pdfExt));
      await file.writeAsBytes(await pdf.save());
      ToastNotification(AppStrings.documentIsSavedToast, context);
    } catch (e) {
      ToastNotification(AppStrings.somethingWentWrong, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(AppIcons.goBack,
                                color: AppColors.text),
              onPressed: () {
                Navigator.pop(context);
                _createPdf(context);
                Provider.of<PagesList>(context, listen: false).clear();
              }
          ),
          actions: [
            IconButton(
                icon: const Icon(AppIcons.download,
                    color: AppColors.text),
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Palette.lightBlue),
                        ),
                      ),
                    ),
                  );
                  await _createPdf(context);
                  Navigator.pop(context);
                }
            ),
          ],
          titleSpacing: 0.0,
          backgroundColor: AppColors.appBar,
          title: Padding(
            padding: EdgeInsets.all(Dimensions.generalPadding),
            child: TextW(text: document.name,
                size: Dimensions.appBarAppNameFontSize,
                weight: FontWeight.w800),
          ),
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.generalPadding),
          child: Center(
            child: ScreenWithListOfDocumentPages(document: document),
          ),
        ),
        // Sets the background color of the Scaffold
      ),
    );

  }
}


class ScreenWithListOfDocumentPages extends StatefulWidget {
  final Document document;

  const ScreenWithListOfDocumentPages({super.key, required this.document});

  @override
  _ScreenWithListOfDocumentPagesState createState() => _ScreenWithListOfDocumentPagesState(document: document);

}

class _ScreenWithListOfDocumentPagesState extends State<ScreenWithListOfDocumentPages> {
  final TextEditingController _controller = TextEditingController();
  final Document document;

  _ScreenWithListOfDocumentPagesState({required this.document});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<PagesList>(context, listen: false).load(document.directory, context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showCircularProgressIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.lightBlue),
          ),
        ),
      ),
    );
  }

  Future<void> _saveImageToDocumentDirectory(File file) async {
    var cornersPtr = calloc<ffi.Int32>(Integrals.amountOfCornersCoordinates);
    if (NativeLibrary.detectCorners(file.path, cornersPtr) != 0) {
      ToastNotification(AppStrings.somethingWentWrong, context);
      return;
    }
    List<int> corners = [];
    for (int i = 0; i < Integrals.amountOfCornersCoordinates; ++i) {
      corners.add(cornersPtr[i]);
    }
    calloc.free(cornersPtr);
    final data = await file.readAsBytes();
    final image = img.decodeImage(data);
    double width = 0.0;
    double height = 0.0;
    if (image != null) {
      width = image.width.toDouble();
      height = image.height.toDouble();
    }
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context)
      => BorderAdjustmentPage(imageFile: file, corners: corners,
                              imageWidth: width,
                              imageHeight: height,
                              document: document),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Получаем путь к изображению
      final file = File(pickedFile.path);

      await _saveImageToDocumentDirectory(file);
      Provider.of<PagesList>(context, listen: false).notifyListeners();
    }
  }



  Future<void> _longPressDialog(int index) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.dialogBackground,
      title: TextW(
        text: AppStrings.sureWantDeleteImageToast,
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
            color: Palette.dimLightBlue,
            thickness: 1,
          ),
          TextButton(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.addDocumentDialogSaveButtonPadding),
                child: TextW(text: AppStrings.documentLongPressDialogDelete,
                  color: AppColors.deleteButtonColor,
                  size: Dimensions.textFontSize,
                ),
              ),
              onPressed: () async {
                Page page = Provider.of<PagesList>(context, listen: false).get(index);
                try {
                  if (await page.file.exists()) {
                    await page.file.delete();
                    Provider.of<PagesList>(context, listen: false).remove(index);
                    ToastNotification(AppStrings.imageDeletedToast, context);
                  }
                } catch (e) {
                    ToastNotification(AppStrings.imageNotDeletedToast, context);
                }
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
                  Consumer<PagesList>(
                    builder: (context, pagesList, child) {
                      return LayoutGrid(
                        columnSizes: [1.fr, 1.fr, 1.fr],
                        rowSizes: [
                          for(int i = 0; i < (pagesList.size() / 2).round() + 1; ++i)
                            const IntrinsicContentTrackSize(),
                        ],
                        columnGap: Dimensions.gridItemColumnGap,
                        rowGap: Dimensions.gridItemRowGap,
                        children: [
                          for(int i = pagesList.size() - 1; i >= 0; --i)
                            PageWidget(
                              index: i,
                              onLongPress: () {
                                _longPressDialog(i);
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context)
                                  => PageOfDocumentPage(imageFile: Provider.of<PagesList>(context, listen: false).get(i).file),
                                  ),
                                );
                              },
                            ),
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
          child: Row(
            children: [
              SizedBox(
                  width: Dimensions.takePhotoButtonWidth,
                  child: Padding(
                    padding: EdgeInsets.all(Dimensions.takePhotoButtonMargin),
                    child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(AppColors.buttonType1Background),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Dimensions.buttonBorderRadius),
                            ),
                          ),
                        ),
                        onPressed: () {
                          _showCircularProgressIndicator();
                          _pickImage(ImageSource.gallery);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: Dimensions.buttonPadding),
                          child: const Icon(AppIcons.gallery, color: AppColors.buttonType1Text),
                        )),
                  )),
              SizedBox(
                  width:Dimensions.takePhotoButtonWidth,
                  child: Padding(
                    padding: EdgeInsets.all(Dimensions.takePhotoButtonMargin),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonType2Background,
                        side: BorderSide(color: AppColors.buttonBorder,
                            width: Dimensions.buttonBorderSide),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.buttonBorderRadius),
                        ),
                      ),
                      onPressed: () {
                        _showCircularProgressIndicator();
                        _pickImage(ImageSource.camera);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimensions.buttonPadding),
                        child: const Icon(
                          AppIcons.camera,
                          color: AppColors.buttonType2Text,
                        ),
                      ),
                    ),
                  )),
            ],),
        ),
      ],
    );
  }
}
