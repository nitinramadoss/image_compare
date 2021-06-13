# image_compare
### Comparing images for difference
#### Simple, extensible dart package

![alt text](https://github.com/nitinramadoss/image_compare/blob/main/images/seven2.PNG) ![alt text](https://github.com/nitinramadoss/image_compare/blob/main/images/seven.PNG)

## Dependency
Add to pubspec.yaml
```
dependencies:
    image_compare: ^1.0.0
```

Import:
```
import 'package:image_compare/image_compare.dart';
```

## Classes:
**Pixel Comparison Algorithms**
- [Pixel Matching](#pixelmatchingdouble-tolerance--005) `PixelMatching({double tolerance = 0.05})`
- [Euclidean Color Distance](#euclideancolordistance) `EuclideanColorDistance()`
- [IMage Euclidean Distance](#imeddouble-sigma--1-double-boxpercentage--0005) `IMED({double sigma = 1, double boxPercentage = 0.005})`

**Histogram Comparison Algorithms**
- [Chi Square Distance](#chisquaredistancehistogram) `ChiSquareDistanceHistogram()`
- [Intersection](#intersectionhistogram) `IntersectionHistogram()`

**Hashing Comparison Algorithms**
- [Perceptual](#perceptualhash) `PerceptualHash()`
- [Average](#averagehash) `AverageHash()`
- [Median](#medianhash) `MedianHash()`

## Implementation:
1. Initialize two images from the dart image class 
*(https://pub.dev/documentation/image/latest/image/Image-class.html):*
```
Image a = Image.fromBytes(width, height, bytes1);
Image b = Image.fromBytes(width, height, bytes2);
```
2. Select an algorithm (from features section). The default is `PixelMatching()`
3. Compare the images:
```
var result = compareImages(a, b, IntersectionHistogram())
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

### `IMED({double sigma = 1, double boxPercentage = 0.005})`
*Source: [IMage Euclidean Distance pdf](https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.680.2097&rep=rep1&type=pdf)*

#### About
 - Images are resized to the same dimensions (if dimensions don't match) and are grayscaled. A gaussian blur is applied when calculating distance between pixel intensities.    Spatial relationship is taken into account within the gaussian function to reduce the effect of minor perturbations (ignores minor differences). 
 - Gaussian blur has been modified: area decreased (Note)
 - Best with images of similar aspect ratios and dimensions
 - Compare for ~exactness (if two images are roughly identical)

#### Result
 - Sum of image euclidean distances between each pixel (RGB value), bounded by the maximum distance possible given two images.
 
### `ChiSquareDistanceHistogram()`

#### About
 - Images are converted to histogram representations (x-axis intensity, y-axis frequency). The chi-square distance formula is applied to compute the distance between each of the 256 bins. There are three histograms per image (RGB histograms).  
 - Works with images of all aspect ratios and dimensions
 - Compare for similarity (if two images are similar based on their color distribution)

#### Result
 - Chi square distance between the normalized color distributions of two images

### `IntersectionHistogram()`

#### About
 - Images are converted to histogram representations (x-axis intensity, y-axis frequency). Histograms are overlaid to calculate percentage overlap. There are three histograms per image (RGB histograms).  
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
- Compare for exactness (if two images are identical)

#### Result
- Structural differences between two hashed, grayscaled images, more precise than average and median hash

### `AverageHash()`
*Source: [HackerFactor article](https://hackerfactor.com/blog/index.php%3F/archives/432-Looks-Like-It.html)*

#### About
- Images are resized to 8x8 and grayscaled.
- Works by taking the average of all the grayscaled pixels and cross checking with the actual intensity value of the pixel.
- The hash produced by this process is used in the hamming distance function.
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
- Compare for exactness (if two images are identical)
#### Result
- Structural difference between median grayscale distributions after hashing of two images

## Full Example:
```
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
```
