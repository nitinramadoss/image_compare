import 'dart:io';
import 'package:image/image.dart';
import 'package:image_compare/image_compare.dart';

void main(List<String> arguments) async {
  var url1 =
      'https://cdn.pixabay.com/photo/2018/04/22/19/16/marguerite-daisy-3342050_1280.jpg';
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
        'https://cdn.pixabay.com/photo/2015/07/21/15/19/koala-854021_1280.jpg'),
    Uri.parse(
        'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg'),
  ];

  // Calculate chi square histogram distance between two network images
  var networkResult = await compareImages(
      src1: Uri.parse(url1),
      src2: Uri.parse(url2),
      algorithm: ChiSquareDistanceHistogram());

  print('Difference of network images with Chi Square: ${networkResult * 100}%');

  // Calculate IMED between two asset images
  var assetResult = await compareImages(
      src1: image1, src2: image2, algorithm: IMED(blurRatio: 0.001));

  print('Difference of asset images with IMED: ${assetResult * 100}%');

  // Calculate intersection histogram difference between two bytes of images
  var byteResult = await compareImages(
      src1: bytes1, src2: bytes2, algorithm: IntersectionHistogram());

  print('Difference of byte images with Intersection Histogram: ${byteResult * 100}%');

  // Calculate euclidean color distance between two images
  var imageResult = await compareImages(
      src1: file1, src2: file2, algorithm: EuclideanColorDistance(ignoreAlpha: true));

  print('Difference of image files with Euclidean Color Distance: ${imageResult * 100}%');

  // Calculate pixel matching between one network and one asset image
  var networkAssetResult =
      await compareImages(src1: Uri.parse(url2), src2: image2, algorithm: PixelMatching(tolerance: 0.1));

  print('Difference of network and asset images with Pixel Matching: ${networkAssetResult * 100}%');

  // Calculate median hash between a byte array and image
  var byteImageResult =
      await compareImages(src1: image1, src2: bytes2, algorithm: MedianHash());

  print('Difference of byte image and image with Median Hash: ${byteImageResult * 100}%');

  // Calculate average hash difference between a network image
  // and a list of network images
  var networkResults = await listCompare(
    target: Uri.parse(url1),
    list: networkImages,
    algorithm: AverageHash(),
  );

  networkResults.forEach((e) => print('Difference of network images with Average Hash: ${e * 100}%'));

  // Calculate perceptual hash difference between an asset image
  // and a list of asset iamges
  var assetResults = await listCompare(
    target: File('images/animals/deer.jpg'),
    list: assetImages,
    algorithm: PerceptualHash(),
  );

  assetResults.forEach((e) => print('Difference of asset images with Perceptual Hash: ${e * 100}%'));
}
