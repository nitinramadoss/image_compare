import 'package:image/image.dart';

import 'hash_algorithm.dart';
import 'histogram_algorithm.dart';
import 'image_pair.dart';
import 'dart:io' as IO;

void main(List<String> arguments) {
// NOTE: Test

  var imageFile1 = new IO.File('assets/test1.png').readAsBytesSync();
  Image image1 = decodeImage(imageFile1);
  var imageFile2 = new IO.File('assets/test2.png').readAsBytesSync();
  Image image2 = decodeImage(imageFile2);

  ImagePair pair = ImagePair(image1, image2)
    ..setAlgorithm(HistogramAlgorithm());
  print(pair.compare());
}
