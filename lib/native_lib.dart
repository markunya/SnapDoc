import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

// Определение типов функций C++
typedef DetectCornersNative = ffi.Int32 Function(ffi.Pointer<Utf8>, ffi.Pointer<ffi.Int32>);
typedef DetectCornersDart = int Function(ffi.Pointer<Utf8>, ffi.Pointer<ffi.Int32>);

typedef NormalizeNative = ffi.Int32 Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<ffi.Int32>);
typedef NormalizeDart = int Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<ffi.Int32>);

class NativeLibrary {
  static late ffi.DynamicLibrary _lib;

  static void loadLibrary() {
    _lib = ffi.DynamicLibrary.open("libSnapDocLib.so");
  }

  // Обертка для функции DetectCorners
  static int detectCorners(String imagePath, ffi.Pointer<ffi.Int32> corners) {
    final detectCorners = _lib.lookupFunction<DetectCornersNative, DetectCornersDart>('DetectCorners');
    final imagePathC = imagePath.toNativeUtf8();
    final result = detectCorners(imagePathC, corners);
    malloc.free(imagePathC);
    return result;
  }

  // Обертка для функции Normalize
  static int normalize(String inputPath, String outputPath, ffi.Pointer<ffi.Int32> corners) {
    final normalize = _lib.lookupFunction<NormalizeNative, NormalizeDart>('Normalize');
    final inputPathC = inputPath.toNativeUtf8();
    final outputPathC = outputPath.toNativeUtf8();
    int result = normalize(inputPathC, outputPathC, corners);
    malloc.free(inputPathC);
    malloc.free(outputPathC);
    return result;
  }
}