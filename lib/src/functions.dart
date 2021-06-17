import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'algorithms.dart';

// TODO: Fix docs
/// Compare images at [src1] and [src2] with the given a specified [algorithm], specify the [SourceType] to indicate what sources are passed in.
/// If [algorithm] is not specified, the default (PixelMatching())
/// If [type] is not specified, the default (SourceType.asset)
/// will be supplied.
Future<double> compareImages(
  var src1,
  var src2, {
  Algorithm? algorithm,
}) async {
  algorithm ??= PixelMatching(); //default algorithm

  return algorithm.compare(
      await _getImageFromDynamic(src1), await _getImageFromDynamic(src2));
}

Future<Image> _getImageFromDynamic(var src) async {
  if (src is String) {
    src = _getImageFile('$src');
  } else if (src is Uri) {
    src = decodeImage((await http.get(src)).bodyBytes)!;
  } else if (src is List<int>) {
    src = decodeImage(src)!;
  } else if (src is Image) {
  } else {
    // TODO: Implement custom error?
    throw UnsupportedError(
        "The source(${src}) of type(${src.runtimeType}) passed in is unsupported");
  }

  return src;
}

Image _getImageFile(String path) {
  var imageFile1 = File(path).readAsBytesSync();

  return decodeImage(imageFile1)!;
}

// TODO: Fix docs
/// Compare [targetSrc] to each image present in [srcList] using a
/// specified [algorithm],  specify the [SourceType] to indicate what sources are passed in.
/// Returns a Future list of doubles corresponding to the compare
/// output for each pair of input: [targetSrc] and imagePaths[i].
/// Output is in the same order as [srcList].
/// If [algorithm] is not specified, the default (PixelMatching())
/// If [type] is not specified, the default (SourceType.asset)
/// will be supplied.
Future<List<double>> listCompare(
  var targetSrc,
  List<dynamic> srcList, {
  Algorithm? algorithm,
}) async {
  algorithm ??= PixelMatching(); //default algorithm

  var results = <double>[];
  await Future.wait(srcList.map((input) async {
    results.add(await compareImages(targetSrc, input, algorithm: algorithm));
  }));
  return results;
}
