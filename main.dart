import 'package:image/image.dart';

import 'package:image_compare/image_compare.dart';
import 'dart:io';

void main(List<String> arguments) {
  var dirPath = 'images/drawings/';
  var targetPath = '${dirPath}kolam1.png';

  compareImageToDirectory(PixelMatching(), dirPath, targetPath);
  compareImageToDirectory(EuclideanColorDistance(), dirPath, targetPath);
  compareImageToDirectory(IMED(), dirPath, targetPath);

  dirPath = 'images/animals/';
  targetPath = '${dirPath}bunny.jpg';

  compareImageToDirectory(IntersectionHistogram(), dirPath, targetPath);
  compareImageToDirectory(ChiSquareDistanceHistogram(), dirPath, targetPath);

  dirPath = 'images/animals/';
  targetPath = '${dirPath}deer.jpg';

  compareImageToDirectory(AverageHash(), dirPath, targetPath);
  //compareImageToDirectory(PerceptualHash(), dirPath, targetPath);
  compareImageToDirectory(MedianHash(), dirPath, targetPath);
}

Image getImageFile(String path) {
  var imageFile1 = File(path).readAsBytesSync();

  return decodeImage(imageFile1)!;
}

void compareImageToImage(
    Algorithm algorithm, String targetPath, String otherPath) {
  var result = compareImages(
      getImageFile(targetPath), getImageFile(otherPath), algorithm);

  printResult(
      algorithm, targetPath, otherPath, (result * 100).toStringAsFixed(3));
}

void compareImageToDirectory(
    Algorithm algorithm, String dirName, String targetPath) async {
  var directory = Directory(dirName);

  var images = <String>[];

  await for (var entity
      in directory.list(recursive: true, followLinks: false)) {
    images.add(entity.path);
  }

  var target = getImageFile(targetPath);

  var results = listCompare(
      target, images.map((val) => getImageFile(val)).toList(), algorithm);

  for (var i = 0; i < images.length; i++) {
    printResult(algorithm, targetPath, images[i],
        (results[i] * 100).toStringAsFixed(3));
  }
}

void printResult(
    Algorithm algorithm, String image1, String image2, String result) {
  print(
      'Target: $image1\nOther:  $image2\nAlgorithm: ${algorithm.toString()}\nResult: $result% difference');
  print('-----------------------------------');
}
