import 'package:image_compare/image_compare.dart';

void main(List<String> arguments) async {
  var otherPath = '../images/animals/komodo.jpg';
  var targetPath = '../images/animals/koala.jpg';

  // Calculate pixel matching with a 10% tolerance
  var networkResult = await compareImages(
    'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
    'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
    PerceptualHash(),
  );

  print('Difference: ${networkResult * 100}%');

  var assetResult = await compareImages(
    otherPath,
    targetPath,
  );
  print('Difference: ${assetResult * 100}%');

  var assetImages = [
    '../images/animals/deer.jpg',
    '../images/animals/bunny.jpg',
    '../images/animals/tiger.jpg'
  ];
  var networkImages = [
    'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
    'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
    'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
    'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
  ];

  // Calculate median hashes between target (src1) and list of images
  var results = await listCompare(otherPath, assetImages, MedianHash());

  results.forEach((e) => print('Difference: ${e * 100}%'));

  results = await listCompare(
    'https://c.files.bbci.co.uk/12A9B/production/_111434467_gettyimages-1143489763.jpg',
    networkImages,
    MedianHash(),
  );

  results.forEach((e) => print('Difference: ${e * 100}%'));
}
