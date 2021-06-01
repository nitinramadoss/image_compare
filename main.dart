import 'package:image/image.dart';

import 'lib/image_compare.dart';
import 'dart:io' as IO;

void main(List<String> arguments) {
// NOTE: Test

  var imageFile1 = IO.File('koala2.jpg').readAsBytesSync();
  var image1 = decodeImage(imageFile1)!;
  var imageFile2 = IO.File('koala1.jpg').readAsBytesSync();
  var image2 = decodeImage(imageFile2)!;

  var pair = ImagePair(image1, image2)..setAlgorithm(AverageHash());
  print(pair.compare());
  var pair2 = ImagePair(image1, image2)..setAlgorithm(PerceptualHash());
  print(pair2.compare());
  var pair3 = ImagePair(image1, image2)..setAlgorithm(MedianHash());
  print(pair3.compare());
}
