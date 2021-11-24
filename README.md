# image_compare
### Comparing images for difference
#### Simple, extensible dart package

![image1](https://github.com/nitinramadoss/image_compare/blob/main/images/seven2.PNG) ![image2](https://github.com/nitinramadoss/image_compare/blob/main/images/seven.PNG)

## What's New?
 - Handle transparency with the alpha channel option
    - Set `ignoreAlpha` to `true` to ignore alpha channel
    - Available for EuclideanColorDistance, PixelMatching, and the histogram algorithms 
    - Example: `PixelMatching(ignoreAlpha: true);`
  
## Dependency
Add to pubspec.yaml
```
dependencies:
  image_compare: ^1.1.1
```

Import:
```
import 'package:image_compare/image_compare.dart';
```

## Classes:
**Pixel Comparison Algorithms**
- [Pixel Matching](#pixelmatchingdouble-tolerance--005) `PixelMatching({bool ignoreAlpha = true, double tolerance = 0.05})`
- [Euclidean Color Distance](#euclideancolordistance) `EuclideanColorDistance({bool ignoreAlpha = true})`
- [IMage Euclidean Distance](#imeddouble-sigma--1-double-blurratio--0005) `IMED({double sigma = 1, double blurRatio = 0.005})`

**Histogram Comparison Algorithms**
- [Chi Square Distance](#chisquaredistancehistogram) `ChiSquareDistanceHistogram({bool ignoreAlpha = true})`
- [Intersection](#intersectionhistogram) `IntersectionHistogram({bool ignoreAlpha = true})`

**Hashing Comparison Algorithms**
- [Perceptual](#perceptualhash) `PerceptualHash()`
- [Average](#averagehash) `AverageHash()`
- [Median](#medianhash) `MedianHash()`

## Implementation:
1. Initialize two sources for the images. Can be any combination of the following types:
* [Uri](https://api.dart.dev/stable/2.13.4/dart-core/Uri-class.html) - image url
* [File](https://api.dart.dev/stable/2.13.4/dart-io/File-class.html) - image file
* [List<int>](https://api.dart.dev/stable/2.10.5/dart-core/List-class.html) - bytes representing image
* [Image](https://pub.dev/documentation/image/latest/image/Image-class.html) - image class

Url example:
```
var a = Uri.parse('https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg');
var b = Uri.parse('https://hs.sbcounty.gov/cn/Photo%20Gallery/Sample%20Picture%20-%20Koala.jpg');
```
File example:
```
var a = File('../images/tiger.jpg');
var b = File('../images/leopard.png');
```
Bytes example:
```
var a = [50, 183, 24, ...];
var b = [255, 230, 81, ...];
```
Image example:
```
var a = Image(100, 100);
var b = Image.from(a); 
```
Any combination example:
```
var a = File('../images/tiger.jpg');
var b = Uri.parse('https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg');
```

2. Select an algorithm (from classes section). The default is `PixelMatching()`
3. Compare the images:
```
var result = await compareImages(src1: a, src2: b, algorithm: ChiSquareDistanceHistogram())

// or compare one image source to a list of others

var results = await listCompare(target: a, list: [a, b], algorithm: IMED(blurRatio: 0.1));
```

## Algorithm Specifics: 
#### Note: 
  *All algorithms return percentage difference (0.0 - no difference, 1.0 - 100% difference), but their meanings are different*
  
### `PixelMatching({double tolerance = 0.05})`

#### About
 - Images are resized to the same dimensions (if dimensions don't match) and each [src1] pixel's RGB value is checked to see if it falls within 5% (of 256) of [src2] pixel's RGB value.
 - Best with images of similar aspect ratios and dimensions
 - Compare for exactness (if two images are identical)

#### Result
 - Percentage of pixels that do not have overlapping RGB values between the images

### `EuclideanColorDistance()`

#### About
 - Images are resized to the same dimensions (if dimensions don't match) and euclidean difference between [src1] RGB values and [src2] RGB values for each pixel is summed.
 - Best with images of similar aspect ratios and dimensions
 - Compare for exactness (if two images are identical)

#### Result
 - Sum of euclidean distances between each pixel (RGB value), bounded by the maximum distance possible given two images.

### `IMED({double sigma = 1, double blurRatio = 0.005})`
*Source: [IMage Euclidean Distance pdf](https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.680.2097&rep=rep1&type=pdf)*

#### About
 - Images are resized to the same dimensions (if dimensions don't match) and are grayscaled. A gaussian blur is applied when calculating distance between pixel intensities. Spatial relationship is taken into account within the gaussian function to reduce the effect of minor perturbations (ignores minor differences). 
 - Gaussian blur has been modified: area decreased (Note)
 - Best with images of similar aspect ratios and dimensions
 - Does not handle transparent pixels
 - Compare for ~exactness (if two images are roughly identical)

#### Result
 - Sum of image euclidean distances between each pixel (RGB value), bounded by the maximum distance possible given two images.
 
### `ChiSquareDistanceHistogram()`

#### About
 - Images are converted to histogram representations (x-axis intensity, y-axis frequency). The chi-square distance formula is applied to compute the distance between each of the 256 bins. There are four histograms per image (RGBA histograms).  
 - Works with images of all aspect ratios and dimensions
 - Compare for similarity (if two images are similar based on their color distribution)

#### Result
 - Chi square distance between the normalized color distributions of two images

### `IntersectionHistogram()`

#### About
 - Images are converted to histogram representations (x-axis intensity, y-axis frequency). Histograms are overlaid to calculate percentage overlap. There are four histograms per image (RGBA histograms).  
 - Works with images of all aspect ratios and dimensions
 - Compare for similarity (if two images are similar based on their color distribution)

#### Result
 - Differences between the normalized color distributions of two images

### `PerceptualHash()`
*Source: [HackerFactor article](https://hackerfactor.com/blog/index.php%3F/archives/432-Looks-Like-It.html)*

#### About
- Images are grayscaled and resized to 32x32. Then they are passed through a 1-dimension discrete cosine transformation.
- The top 8x8 is only accounted for since it gives the generalized frequency of the image. With this, a hash is created.
- This algorithm works great for images as described by phash.org "copyright protection, similarity search for media files, or even digital forensics". From our testing we also found it works great with pictures that have subjects inside and minimal white space.
- Does not handle transparent pixels
- Compare for exactness (if two images are identical)

#### Result
- Structural differences between two hashed, grayscaled images, more precise than average and median hash

### `AverageHash()`
*Source: [HackerFactor article](https://hackerfactor.com/blog/index.php%3F/archives/432-Looks-Like-It.html)*

#### About
- Images are resized to 8x8 and grayscaled.
- Works by taking the average of all the grayscaled pixels and cross checking with the actual intensity value of the pixel.
- The hash produced by this process is used in the hamming distance function.
- Does not handle transparent pixels
- Compare for exactness (if two images are identical)

#### Result
- Structural difference between average grayscale distributions after hashing of two images

### `MedianHash()`
*Source: [Content-Blockchain article](https://content-blockchain.org/research/testing-different-image-hash-functions/)*

#### About
- Images are resized to 9x8 and grayscaled.
- Works by taking the median of all the grayscaled pixels and cross checking with the actual intensity value of the pixel.
- Conceptually similar to average hash except uses median.
- The hash produced by this process is used in the hamming distance function.
- Does not handle transparent pixels
- Compare for exactness (if two images are identical)
#### Result
- Structural difference between median grayscale distributions after hashing of two images

## Full Example:
```
import 'dart:io';
import 'package:image/image.dart';
import 'package:image_compare/image_compare.dart';

void main(List<String> arguments) async {
  var url1 =
      'https://www.tompetty.com/sites/g/files/g2000007521/f/sample_01.jpg';
  var url2 =
      'https://fujifilm-x.com/wp-content/uploads/2019/08/x-t30_sample-images03.jpg';

  var file1 = File('../images/drawings/kolam1.png');
  var file2 = File('../images/drawings/scribble1.png');

  var bytes1 = File('../images/animals/koala.jpg').readAsBytesSync();
  var bytes2 = File('../images/animals/komodo.jpg').readAsBytesSync();

  var image1 = decodeImage(bytes1);
  var image2 = decodeImage(bytes2);

  var assetImages = [
    File('../images/animals/bunny.jpg'),
    File('../images/animals/deer.jpg'),
    File('../images/animals/tiger.jpg')
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
      src1: file1, src2: file2, algorithm: IMED(blurRatio: 0.001));

  print('Difference: ${assetResult * 100}%');

  // Calculate intersection histogram difference between two bytes of images
  var byteResult = await compareImages(
      src1: bytes1, src2: bytes2, algorithm: IntersectionHistogram());

  print('Difference: ${byteResult * 100}%');

  // Calculate euclidean color distance between two images
  var imageResult = await compareImages(
      src1: image1, src2: image2, algorithm: EuclideanColorDistance());

  print('Difference: ${imageResult * 100}%');

  // Calculate pixel matching between one network and one asset image
  var networkAssetResult =
      await compareImages(src1: Uri.parse(url2), src2: file1);

  print('Difference: ${networkAssetResult * 100}%');

  // Calculate median hash between a byte array and image
  var byteImageResult =
      await compareImages(src1: image1, src2: bytes1, algorithm: MedianHash());

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

```
