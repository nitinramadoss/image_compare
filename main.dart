import 'package:image/image.dart';

import 'lib/algorithms.dart';
import 'lib/image_pair.dart';
import 'dart:io' as IO;

void main(List<String> arguments) {
// NOTE: Test

  var imageFile1 = IO.File('test1.png').readAsBytesSync();
  var image1 = decodeImage(imageFile1)!;
  var imageFile2 = IO.File('test1.png').readAsBytesSync();
  var image2 = decodeImage(imageFile2)!;

  image1 = copyResize(image1, width: 50, height: 50);
  image2 = copyResize(image2, width: 50, height: 50);

  var pair = ImagePair(image1, image2)..setAlgorithm(IMEDAlgorithm());
  print(pair.compare());
}
