import 'package:image/image.dart';

import 'hash_algorithm.dart';
import 'image_pair.dart';
import 'dart:io' as Io;

void main(List<String> arguments) {
// NOTE: Test

  var imageFile1 = Io.File('assets/test1.png').readAsBytesSync();
  var image1 = decodeImage(imageFile1);
  var imageFile2 = Io.File('assets/test2.png').readAsBytesSync();
  var image2 = decodeImage(imageFile2);

  var pair = ImagePair(image1, image2)
    ..setAlgorithm(HashAlgorithm())
    ..compare();
}
