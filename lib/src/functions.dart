import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart';
import 'algorithms.dart';

/// Compare images at [path1] and [path2] with the given a specified [algorithm].
/// If [algorithm] is not specified, the default (PixelMatching())
/// will be supplied.
Future<double> compareImages(String path1, String path2,
    [Algorithm? algorithm]) async {
  algorithm ??= PixelMatching(); //default algorithm
  Image src1;
  Image src2;
  if (RegExp(r"((http|https)://)(www.)?" +
          "[a-zA-Z0-9@:%._\\+~#?&//=]" +
          "{2,256}\\.[a-z]" +
          "{2,6}\\b([-a-zA-Z0-9@:%" +
          "._\\+~#?&//=]*)")
      .hasMatch(path1)) {
    src1 = decodeImage((await http.get(Uri.parse('$path1'))).bodyBytes)!;
    src2 = decodeImage((await http.get(Uri.parse('$path2'))).bodyBytes)!;
  } else {
    src1 = _getImageFile('$path1');
    src2 = _getImageFile('$path2');
  }

  return algorithm.compare(src1, src2);
}

Image _getImageFile(String path) {
  var imageFile1 = File(path).readAsBytesSync();

  return decodeImage(imageFile1)!;
}

/// Compare [targetPath] to each image present in [imagePaths] using a
/// specified [algorithm].
/// Returns a Future list of doubles corresponding to the compare
/// output for each pair of input: [targetPath] and imagePaths[i].
/// Output is in the same order as [imagePaths].
///
/// If [algorithm] is not specified, the default (PixelMatching())
/// If [type] is not specified, the default (ImageType.asset)
/// will be supplied.
Future<List<double>> listCompare(String targetPath, List<String> imagePaths,
    [Algorithm? algorithm]) async {
  algorithm ??= PixelMatching(); //default algorithm
  var results = <double>[];
  await Future.wait(imagePaths.map((input) async {
    results.add(await compareImages(targetPath, input, algorithm));
  }));
  return results;
}
