import 'package:image/image.dart';

import 'hash_algorithm.dart';
import 'image_pair.dart';
import 'dart:io' as Io;

void main(List<String> arguments) {
  var imageFile1 = new Io.File('assets/test1.png').readAsBytesSync();
  Image image1 = decodeImage(imageFile1);
  var imageFile2 = new Io.File('assets/test2.png').readAsBytesSync();
  Image image2 = decodeImage(imageFile2);

  ImagePair pair = ImagePair(image1, image2)
    ..setAlgorithm(HashAlgorithm())
    ..compare();
}
