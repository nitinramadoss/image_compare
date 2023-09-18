import 'dart:typed_data';
import 'algorithms.dart';
import 'package:image/image.dart';
import 'package:universal_io/io.dart';

/// Compare images from [src1] and [src2] with a specified [algorithm].
/// If [algorithm] is not specified, the default (PixelMatching()) is supplied.
///
/// Returns a [Future] of double corresponding to the difference between [src1]
/// and [src2]
///
/// [src1] and [src2] may be any combination of the supported types:
/// * [Uri] - parsed URI, such as a URL (dart:core Uri class)
/// * [File] - reference to a file on the file system (dart:io File class)
/// * [List]- list of integers (bytes representing the image)
/// * [Image] - image buffer (Image class)
Future<double> compareImages({
  required var src1,
  required var src2,
  Algorithm? algorithm,
}) async {
  algorithm ??= PixelMatching(); // default algorithm
  src1 = await _getImageFromDynamic(src1);
  src2 = await _getImageFromDynamic(src2);

  var result = algorithm.compare(src1, src2);

  // Ignore floating point error
  if (result < 0) {
    result = 0;
  } else if (result > 1) {
    result = 1;
  }

  return result;
}

/// Compare [target] to each image present in [list] using a
/// specified [algorithm]. If [algorithm] is not specified, the default (PixelMatching())
/// is supplied.
///
/// Returns a [Future] list of doubles corresponding to the difference
/// between [targetSrc] and srcList[i].
/// Output is in the same order as [srcList].
///
/// [target] and list[i] may be any combination of the supported types:
/// * [Uri] - parsed URI, such as a URL (dart:core Uri class)
/// * [File] - reference to a file on the file system (dart:io File class)
/// * [List]- list of integers (bytes representing the image)
/// * [Image] - image buffer (Image class)
Future<List<double>> listCompare({
  required var target,
  required List<dynamic> list,
  Algorithm? algorithm,
}) async {
  algorithm ??= PixelMatching(); //default algorithm

  var results = List<double>.filled(list.length, 0);

  await Future.wait(list.map((otherSrc) async {
    results[list.indexOf(otherSrc)] =
        await compareImages(src1: target, src2: otherSrc, algorithm: algorithm);
  }));

  return results;
}

Future<Image> _getImageFromDynamic(var src) async {
  // Error message if image format can't be identified
  var err = 'A valid image could not be identified from ';
  var bytes = <int>[];

  if (src is File) {
    bytes = src.readAsBytesSync();

    err += '${src.path}. Provide image file.';
  } else if (src is Uri) {
    bytes = await _getBytesFromNetwork(src);

    var url = (src.toString().length <= 25)
        ? src.toString()
        : '${src.toString().substring(0, 25)}..';

    err += '$url Provide image url.';
  } else if (src is List<int>) {
    bytes = src;

    var list = (src.length <= 10) ? src : src.sublist(0, 10);

    err += '$list<...>';
  } else if (src is Image) {
    err +=
        '${src.width}x${src.height}!=${src.data?.length ?? 0} length != width * height';

    if (src.height * src.width != (src.data?.length ?? 0) &&
        src.height * src.width * 3 != (src.data?.length ?? 0)) {
      throw FormatException(err);
    }

    return src;
  } else {
    throw UnsupportedError(
        "The source, ${src.runtimeType}, passed in is unsupported");
  }

  src = _getValidImage(bytes, err);

  return src;
}

/// Helper function to validate [List]
/// of bytes format and return [Image].
/// Throws exception if format is invalid.
Image _getValidImage(List<int> bytes, String err) {
  var image;
  try {
    image = decodeImage(Uint8List.fromList(bytes));
  } catch (Exception) {
    throw FormatException("Insufficient data provided to identify image.");
  }

  if (image == null) {
    throw FormatException(err);
  }

  return image;
}

/// Helper function to convert byte data from a
/// [Uri] source into an [Image] object
Future<List<int>> _getBytesFromNetwork(Uri src) async {
  var bodyBytes = <int>[];
  HttpClient cl = new HttpClient();

  var req = await cl.getUrl(src);
  var res = await req.close();

  await for (var value in res) {
    value.forEach((element) {
      bodyBytes.add(element);
    });
  }

  return bodyBytes;
}
