import 'dart:io';
import 'package:image/image.dart';
import 'package:image_compare/image_compare.dart';
import 'package:collection/collection.dart';

void main(List<String> arguments) async {
  var url1 =
      'https://lh3.googleusercontent.com/proxy/PZjP3Ugoix466pN9-X54F0IKCM06ZG3ZndilKtsFB-aftdOFNDeBRKSxzAkIfVmac-MQgZ6S5KpV15_KMnt95eKS';
  var url2 =
      'https://lh3.googleusercontent.com/proxy/PZjP3Ugoix466pN9-X54F0IKCM06ZG3ZndilKtsFB-aftdOFNDeBRKSxzAkIfVmac-MQgZ6S5KpV15_KMnt95eKS';

  // Calculate chi square histogram distance between two network images
  var networkResult = await compareImages(
      src1: Uri.parse(url1),
      src2: Uri.parse(url2),
      algorithm: PixelMatching(tolerance: 0));

  print('Difference: ${networkResult * 100}%');

  var otherFile = File('../images/drawings/kolam1.png');
  var targetFile = File('../images/drawings/scribble1.png');

  // Calculate IMED between two asset images
  var assetResult = await compareImages(
      src1: targetFile, src2: otherFile, algorithm: IMED(boxPercentage: 0.001));

  print('Difference: ${assetResult * 100}%');

  var assetImages = [
    File('../images/animals/bunny.jpg'),
    File('../images/animals/deer.jpg'),
    File('../images/animals/tiger.jpg')
  ];

  // Calculate perceptual hash difference between an asset image
  // and a list of asset iamges
  var assetResults = await listCompare(
    targetSrc: File('../images/animals/deer.jpg'),
    srcList: assetImages,
    algorithm: PerceptualHash(),
  );
  for (var item in assetImages) {
    print(item.hashCode);
  }
  assetResults.forEach((e) => print('Difference: ${e}%'));

  var networkImages = [
    Uri.parse(
        'https://lh3.googleusercontent.com/proxy/PZjP3Ugoix466pN9-X54F0IKCM06ZG3ZndilKtsFB-aftdOFNDeBRKSxzAkIfVmac-MQgZ6S5KpV15_KMnt95eKS'),
    Uri.parse(
        'https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg'),
    Uri.parse(
        'https://hs.sbcounty.gov/cn/Photo%20Gallery/Sample%20Picture%20-%20Koala.jpg'),
    Uri.parse(
        'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg'),
  ];

  for (var item in networkImages) {
    print(item.hashCode);
  }
  // Calculate average hash difference between a network image
  // and a list of network images
  var networkResults = await listCompare(
    targetSrc: Uri.parse(url1),
    srcList: networkImages,
    algorithm: AverageHash(),
  );

  networkResults.forEach((e) => print('Difference: ${e}%'));
}
