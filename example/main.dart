import 'package:image_compare/image_compare.dart';

void main(List<String> arguments) async {
  var otherPath = '../images/animals/komodo.jpg';
  var targetPath = '../images/animals/koala.jpg';

  var networkResult = await compareImages(
      'https://www.tompetty.com/sites/g/files/g2000007521/f/sample_01.jpg',
      'https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg',
      type: SourceType.network);

  print('Difference: ${networkResult * 100}%');

  var assetResult =
      await compareImages(otherPath, targetPath, type: SourceType.asset);
  print('Difference: ${assetResult * 100}%');

  var assetImages = [
    '../images/animals/deer.jpg',
    '../images/animals/bunny.jpg',
    '../images/animals/tiger.jpg'
  ];
  var networkImages = [
    'https://www.tompetty.com/sites/g/files/g2000007521/f/sample_01.jpg',
    'https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg',
    'https://hs.sbcounty.gov/cn/Photo%20Gallery/Sample%20Picture%20-%20Koala.jpg',
    'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
  ];

  // Calculate median hashes between target (src1) and list of images
  var results = await listCompare(targetPath, assetImages,
      algorithm: PerceptualHash(), type: SourceType.asset);

  results.forEach((e) => print('Difference: ${e * 100}%'));

  // results = await listCompare(
  //     'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
  //     networkImages,
  //     algorithm: MedianHash(),
  //     type: SourceType.network);

  // results.forEach((e) => print('Difference: ${e * 100}%'));
}
