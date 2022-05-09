import 'dart:io';
import 'package:image/image.dart';
import 'package:image_compare/image_compare.dart';

const imagesPath = 'assets/images/';

printDiff(String title, double diff) {
  print('$title: ${diff * 100}%');
}

void main(List<String> arguments) async {
  var url1 =
      'https://www.tompetty.com/sites/g/files/g2000007521/f/sample_01.jpg';
  var url2 =
      'https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg';

  var file1 = File('$imagesPath' 'drawings/kolam1.png');
  var file2 = File('$imagesPath' 'drawings/scribble1.png');

  var bytes1 = File('$imagesPath' 'animals/koala.jpg').readAsBytesSync();
  var bytes2 = File('$imagesPath' 'animals/komodo.jpg').readAsBytesSync();

  var image1 = decodeImage(bytes1);
  var image2 = decodeImage(bytes2);

  var assetImages = [
    File('$imagesPath' 'animals/bunny.jpg'),
    File('$imagesPath' 'objects/red_apple.png'),
    File('$imagesPath' 'animals/tiger.jpg')
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

  printDiff('Network images', networkResult);

  // Calculate IMED between two asset images
  var assetResult = await compareImages(
      src1: image1, src2: image2, algorithm: IMED(blurRatio: 0.001));

  printDiff('Asset images', assetResult);

  // Calculate intersection histogram difference between two bytes of images
  var byteResult = await compareImages(
    src1: bytes1,
    src2: bytes2,
    algorithm: IntersectionHistogram(),
  );

  printDiff('Bytes', byteResult);

  // Calculate euclidean color distance between two images
  var imageResult = await compareImages(
      src1: file1,
      src2: file2,
      algorithm: EuclideanColorDistance(ignoreAlpha: true));

  printDiff('Files', imageResult);

  // Calculate pixel matching between one network and one asset image
  var networkAssetResult = await compareImages(
      src1: Uri.parse(url2),
      src2: image2,
      algorithm: PixelMatching(tolerance: 0.1));

  printDiff('Network asset', networkAssetResult);

  // Calculate median hash between a byte array and image
  var byteImageResult =
      await compareImages(src1: image1, src2: bytes2, algorithm: MedianHash());

  printDiff('Byte image', byteImageResult);

  // Calculate average hash difference between a network image
  // and a list of network images
  var networkResults = await listCompare(
    target: Uri.parse(url1),
    list: networkImages,
    algorithm: AverageHash(),
  );

  for (var i = 0; i < networkResults.length; i++) {
    final e = networkResults[i];
    printDiff('Network $i', e);
  }

  // Calculate perceptual hash difference between an asset image
  // and a list of asset iamges
  var assetResults = await listCompare(
    target: File('$imagesPath' 'animals/deer.jpg'),
    list: assetImages,
    algorithm: PerceptualHash(),
  );

  for (var i = 0; i < assetResults.length; i++) {
    final e = assetResults[i];
    printDiff('asset $i', e);
  }
}
