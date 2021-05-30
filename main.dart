import 'package:image/image.dart';

import 'lib/image_compare.dart';
import 'dart:io' as IO;

void main(List<String> arguments) {
// NOTE: Test

  var imageFile1 = IO.File('test1.png').readAsBytesSync();
  var image1 = decodeImage(imageFile1)!;
  var imageFile2 = IO.File('test1.png').readAsBytesSync();
  var image2 = decodeImage(imageFile2)!;

  var pair = ImagePair(image1, image2)..setAlgorithm(EuclideanColorDistanceAlgorithm());
  print(pair.compare());
}
