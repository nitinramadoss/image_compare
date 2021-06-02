import 'package:image/image.dart';

import 'package:image_compare/image_compare.dart';
import 'dart:io' as IO;

void main(List<String> arguments) {
// NOTE: Test

  var imageFile1 = IO.File('images/koala1.jpg').readAsBytesSync();
  var image1 = decodeImage(imageFile1)!;
  var imageFile2 = IO.File('images/koala2.jpg').readAsBytesSync();
  var image2 = grayscale(decodeImage(imageFile2)!);

  print(compareImages(image1, image2, ChiSquareDistanceHistogram()));
  print(compareImages(image1, image2, IntersectionHistogram()));
}
