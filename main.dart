import 'package:image/image.dart';

import 'package:image_compare/image_compare.dart';
import 'dart:io';

void main(List<String> arguments) {
  compareImageToDirectory("images/animals/", "images/animals/bunny.jpg");
}

Image getImageFile(String path) {
  var imageFile1 = File(path).readAsBytesSync();

  return decodeImage(imageFile1)!;
}

void compareImageToDirectory(String dirName, String targetPath) async{
  var directory = Directory(dirName);

  var images = <String>[];

  await for (var entity in
      directory.list(recursive: true, followLinks: false)) {
    
    images.add(entity.path);
  }

  var target = getImageFile(targetPath);

  var results = listCompare(target, images.map((val) => getImageFile(val)).toList());

  for (var i = 0; i < images.length; i++) {
    printResult(targetPath, images[i], results[i]);
  }
}

void printResult(String image1, String image2, double result) {
  print('Target: $image1\nOther:  $image2\nResult: $result');
  print('-----------------------------------');
}
