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
- [Pixel Matching](#pixelmatching) `PixelMatching()`
- [Euclidean Color Distance](#euclideancolordistance) `EuclideanColorDistance()`
- [IMage Euclidean Distance](#imed) `IMED()`

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
  
### `PixelMatching()`

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

### `IMED()`
*Source: https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.680.2097&rep=rep1&type=pdf*

#### About
 - Images are resized to the same dimensions (if dimensions don't match) and are grayscaled. A gaussian blur is applied when calculating distance between pixel intensities.    Spatial relationship is taken into account within the guassian function to reduce the effect of minor perturbations (ignores minor differences). 
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
 - Images are converted to histogram representations (x-axis intensity, y-axis frequency). Histograms are overlayed to calculate percentage overlap. There are three histograms per image (RGB histograms).  
 - Works with images of all aspect ratios and dimensions
 - Compare for similarity (if two images are similar based on their color distribution)

#### Result
 - Differences between the normalized color distributions of two images

### `PerceptualHash()`

#### About

#### Result

### `AverageHash()`

#### About

#### Result

### `MedianHash()`

#### About

#### Result


