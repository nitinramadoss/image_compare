import 'package:image/image.dart';

import 'package:image_compare/image_compare.dart';
import 'dart:io';

void main(List<String> arguments) {
  var otherPath = 'images/animals/komodo.jpg';
  var targetPath = 'images/animals/koala.jpg';

  var src1 = getImageFile(targetPath);
  var src2 = getImageFile(otherPath);

  // Calculate pixel matching with a 10% tolerance
  var result = compareImages(src1, src2, PixelMatching(tolerance: 0.1));

  print('Difference: ${result * 100}%');

  // Calculate Chi square distance between histograms
  result = compareImages(src1, src2, ChiSquareDistanceHistogram());

  print('Difference: ${result * 100}%');

  var images = [
    getImageFile('images/animals/deer.jpg'),
    getImageFile('images/animals/bunny.jpg'),
    getImageFile('images/animals/tiger.jpg')
  ];

  // Calculate median hashes between target (src1) and list of images
  var results = listCompare(src1, images, MedianHash());

  results.forEach((e) => print('Difference: ${e * 100}%'));
}

Image getImageFile(String path) {
  var imageFile1 = File(path).readAsBytesSync();

  return decodeImage(imageFile1)!;
}
