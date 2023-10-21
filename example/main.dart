import 'dart:io';
import 'package:image/image.dart';
import 'package:image_compare_2/image_compare_2.dart';

void main(List<String> arguments) async {
  var url1 =
      'https://www.tompetty.com/sites/g/files/g2000014681/files/2022-06/TP%2520skateboard%25205.14.jpg';
  var url2 =
      'https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg';

  var file1 = File('images/drawings/kolam1.png');
  var file2 = File('images/drawings/scribble1.png');

  var bytes1 = File('images/animals/koala.jpg').readAsBytesSync();
  var bytes2 = File('images/animals/komodo.jpg').readAsBytesSync();

  var image1 = decodeImage(bytes1);
  var image2 = decodeImage(bytes2);

  var assetImages = [
    File('images/animals/bunny.jpg'),
    File('images/objects/red_apple.png'),
    File('images/animals/tiger.jpg')
  ];

  var networkImages = [
    Uri.parse(
        'https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg'),
    Uri.parse(
        'https://hs.sbcounty.gov/cn/Photo%20Gallery/Sample%20Picture%20-%20Koala.jpg'),
    Uri.parse(
        'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg'),
  ];

  // Calculate chi square histogram distance between two network images
  var networkResult = await compareImages(
      src1: Uri.parse(url1),
      src2: Uri.parse(url2),
      algorithm: ChiSquareDistanceHistogram());

  print('Difference: ${networkResult * 100}%');

  // Calculate IMED between two asset images
  var assetResult = await compareImages(
      src1: image1, src2: image2, algorithm: IMED(blurRatio: 0.001));

  print('Difference: ${assetResult * 100}%');

  // Calculate intersection histogram difference between two bytes of images
  var byteResult = await compareImages(
      src1: bytes1, src2: bytes2, algorithm: IntersectionHistogram());

  print('Difference: ${byteResult * 100}%');

  // Calculate euclidean color distance between two images
  var imageResult = await compareImages(
      src1: file1,
      src2: file2,
      algorithm: EuclideanColorDistance(ignoreAlpha: true));

  print('Difference: ${imageResult * 100}%');

  // Calculate pixel matching between one network and one asset image
  var networkAssetResult = await compareImages(
      src1: Uri.parse(url2),
      src2: image2,
      algorithm: PixelMatching(tolerance: 0.1));

  print('Difference: ${networkAssetResult * 100}%');

  // Calculate median hash between a byte array and image
  var byteImageResult =
      await compareImages(src1: image1, src2: bytes2, algorithm: MedianHash());

  print('Difference: ${byteImageResult * 100}%');

  // Calculate average hash difference between a network image
  // and a list of network images
  var networkResults = await listCompare(
    target: Uri.parse(url1),
    list: networkImages,
    algorithm: AverageHash(),
  );

  networkResults.forEach((e) => print('Difference: ${e * 100}%'));

  // Calculate perceptual hash difference between an asset image
  // and a list of asset iamges
  var assetResults = await listCompare(
    target: File('../images/animals/deer.jpg'),
    list: assetImages,
    algorithm: PerceptualHash(),
  );

  assetResults.forEach((e) => print('Difference: ${e * 100}%'));
}
