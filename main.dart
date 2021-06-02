import 'package:image/image.dart';

import 'lib/image_compare.dart';
import 'dart:io' as IO;

void main(List<String> arguments) {
// NOTE: Test

  var imageFile1 = IO.File('images/kolam1.png').readAsBytesSync();
  var image1 = decodeImage(imageFile1)!;
  var imageFile2 = IO.File('images/kolam3.png').readAsBytesSync();
  var image2 = decodeImage(imageFile2)!;

  print(compareImages(image1, image2, PixelMatching()));
}
