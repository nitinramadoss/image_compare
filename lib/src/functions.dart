import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'algorithms.dart';

enum SourceType { asset, network, image, bytes }

/// Compare images at [src1] and [src2] with the given a specified [algorithm], specify the [SourceType] to indicate what sources are passed in.
/// If [algorithm] is not specified, the default (PixelMatching())
/// If [type] is not specified, the default (SourceType.asset)
/// will be supplied.
Future<double> compareImages(
  var src1,
  var src2, {
  SourceType? type,
  Algorithm? algorithm,
}) async {
  algorithm ??= PixelMatching(); //default algorithm
  type ??= SourceType.asset; //default source type
  print(algorithm);
  switch (type) {
    case SourceType.asset:
      src1 = _getImageFile('$src1');
      src2 = _getImageFile('$src2');
      break;
    case SourceType.network:
      src1 = decodeImage((await http.get(Uri.parse('$src1'))).bodyBytes)!;
      src2 = decodeImage((await http.get(Uri.parse('$src2'))).bodyBytes)!;
      break;
    case SourceType.image:
      break;
    case SourceType.bytes:
      src1 = decodeImage(src1);
      src2 = decodeImage(src2);
      break;
  }

  return algorithm.compare(src1, src2);
}

Image _getImageFile(String path) {
  var imageFile1 = File(path).readAsBytesSync();

  return decodeImage(imageFile1)!;
}

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
  SourceType? type,
  Algorithm? algorithm,
}) async {
  algorithm ??= PixelMatching(); //default algorithm
  type ??= SourceType.asset; //default source type

  var results = <double>[];
  await Future.wait(srcList.map((input) async {
    results.add(await compareImages(targetSrc, input,
        algorithm: algorithm, type: type));
  }));
  return results;
}
