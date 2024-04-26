import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snap_doc/constants.dart';
import 'package:snap_doc/widgets.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:flutter/widgets.dart';
import 'dart:ffi' as ffi;
import 'package:snap_doc/native_lib.dart';
import 'package:snap_doc/pages/document_page.dart';

class DraggableCorner extends StatefulWidget {
  final Offset initialPosition;
  final Function(Offset newPosition) onDrag;

  const DraggableCorner({
    super.key,
    required this.initialPosition,
    required this.onDrag,
  });

  @override
  _DraggableCornerState createState() => _DraggableCornerState();
}

class _DraggableCornerState extends State<DraggableCorner> {
  Offset position = const Offset(0, 0);

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - Dimensions.draggableCornerSize / 2,
      top: position.dy - Dimensions.draggableCornerSize / 2,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
            widget.onDrag(position);
          });
        },
        child: Container(
          width: Dimensions.draggableCornerSize,
          height: Dimensions.draggableCornerSize,
          decoration: BoxDecoration(
            color: Palette.mainBlue.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: Palette.lightBlue,
              width: 2,
            )
          ),
        ),
      ),
    );
  }
}

class BorderAdjustmentPage extends StatefulWidget {
  final File imageFile;
  final List<int> corners;
  final double imageWidth;
  final double imageHeight;
  final Document document;

  const BorderAdjustmentPage({super.key,
    required this.imageFile,
    required this.corners,
    required this.imageWidth,
    required this.imageHeight,
    required this.document});

  @override
  _BorderAdjustmentPageState createState() => _BorderAdjustmentPageState(imageFile: imageFile,
      corners: corners,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      document: document);
}

class _BorderAdjustmentPageState extends State<BorderAdjustmentPage> {
  File imageFile;
  List<int> corners;
  double imageWidth;
  double imageHeight;
  Document document;

  _BorderAdjustmentPageState({
    required this.imageFile,
    required this.corners,
    required this.imageWidth,
    required this.imageHeight,
    required this.document});


  Offset _realToScreen(Offset offset) {
    double k = _getCoefficient();
    offset /= k;
    offset += Offset(Dimensions.draggableCornerSize / 2, Dimensions.draggableCornerSize / 2);
    return offset;
  }

  Offset _screenToReal(Offset offset) {
      double k = _getCoefficient();
      offset -= Offset(Dimensions.draggableCornerSize / 2, Dimensions.draggableCornerSize / 2);
      offset *= k;
      return offset;
  }

  void onCornerDrag(Offset position, int index) {
      position = _screenToReal(position);
      corners[2 * index] = position.dx.toInt();
      corners[2 * index + 1] = position.dy.toInt();
  }

  double crossProduct(Offset A, Offset B, Offset C) {
    return (B.dx - A.dx) * (C.dy - B.dy) - (B.dy - A.dy) * (C.dx - B.dx);
  }

  List<int> sortCorners(List<int> intPoints) {
    List<Offset> points = [];
    for (int i = 0; i < 4; ++i) {
      points.add(Offset(intPoints[2 * i].toDouble(), intPoints[2 * i + 1].toDouble()));
    }
    Offset minNormPoint = points.reduce((a, b) => (a.dx * a.dx + a.dy * a.dy < b.dx * b.dx + b.dy * b.dy) ? a : b);
    points.remove(minNormPoint);
    points.sort((a, b) {
      double ax = a.dx - minNormPoint.dx;
      double ay = a.dy - minNormPoint.dy;
      double bx = b.dx - minNormPoint.dx;
      double by = b.dy - minNormPoint.dy;
      double cross = ax * by - ay * bx;
      if (cross == 0) {
        return (ax * ax + ay * ay).compareTo(bx * bx + by * by);
      } else {
        return cross > 0 ? -1 : 1;
      }
    });
    points = [minNormPoint, ...points];
    List<int> result = [];
    for (int i = 0; i < 4; ++i) {
        result.add(points[i].dx.toInt());
        result.add(points[i].dy.toInt());
    }
    return result;
  }

  double _getCoefficient() {
    if (imageWidth / imageHeight > Dimensions.stackBorderAdjustmentWidth / Dimensions.stackBorderAdjustmentHeight) {
      return imageWidth / Dimensions.stackBorderAdjustmentWidth;
    }
    return imageHeight / Dimensions.stackBorderAdjustmentHeight;
  }

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
    return Container(
      color: AppColors.background,
      child: Scaffold(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: Dimensions.screenHeight * 0.8, // Максимальная высота виджета
                ),
                child: SizedBox(
                child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(Dimensions.draggableCornerSize / 2),
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                      for (int i = 0; i < Integrals.amountOfCorners; ++i)
                      DraggableCorner(
                        initialPosition: _realToScreen(Offset(corners[2 * i].toDouble(),
                                                corners[2 * i + 1].toDouble())), // Начальная позиция угла
                        onDrag: (newPosition) {
                          onCornerDrag(newPosition, i);
                        },
                      ),
                  ],
                ),
              ),
              ),

              SizedBox(width: Dimensions.saveImageButtonWidth,
                        child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonType2Background,
                side: BorderSide(color: AppColors.buttonBorder,
                    width: Dimensions.buttonBorderSide),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.buttonBorderRadius),
                ),
              ),
                onPressed:() async {
                  final directory = await getExternalStorageDirectory();
                  if (directory == null) {
                    ToastNotification(AppStrings.somethingWentWrongWithStorageToast, context);
                    return;
                  }
                  final newFilePath = Path.join(directory.path, AppStrings.appName, document.name, Path.basename(imageFile.path));
                  var cornersPtr = calloc<ffi.Int32>(Integrals.amountOfCornersCoordinates);
                  corners = sortCorners(corners);
                  for (int i = 0; i < Integrals.amountOfCornersCoordinates; ++i) {
                    cornersPtr[i] = corners[i];
                  }
                  var result = NativeLibrary.normalize(imageFile.path, newFilePath, cornersPtr);
                  if (result != 0) {
                    ToastNotification(AppStrings.somethingWentWrong, context);
                  }
                  calloc.free(cornersPtr);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context)
                  => DocumentPage(document: document),
                  ),);
                },
                child: Padding(
                  padding:EdgeInsets.symmetric(vertical: Dimensions.buttonPadding),
                  child: TextW(text: AppStrings.save, size: Dimensions.buttonFontSize, color: AppColors.buttonType2Text),
                ),
              ),
              ),
            ],
          ),
        // Sets the background color of the Scaffold
      ),
      ),
    );
  }
}
