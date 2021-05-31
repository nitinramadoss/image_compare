# image_compare
### Comparing images for similarity
#### Simple, extensible dart package

![alt text](https://github.com/nitinramadoss/image_compare/blob/main/seven2.PNG) ![alt text](https://github.com/nitinramadoss/image_compare/blob/main/seven.PNG)

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

## Features:
**Pixel Comparison Algorithms**
- Pixel matching ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `PixelMatching()`
- Euclidean Color Distance ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `EuclideanColorDistance()`
- IMage Euclidean Distance (IMED) ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `IMED()`

**Histogram Comparison Algorithms**
- Chi Square Difference ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `ChiSquareDifferenceHistogram()`
- Intersection ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `IntersectionHistogram()`

**Hashing Comparison Algorithms**
- Average ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `AverageHash()`
- Median ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `MedianHash()`

## Implementation:
Initialize two images from the dart image class 
*(https://pub.dev/documentation/image/latest/image/Image-class.html):*
```
Image a = Image.fromBytes(width, height, bytes1);
Image b = Image.fromBytes(width, height, bytes2);
```
Construct an ```ImagePair``` object with the two images (from previous step):
```
ImagePair pair = ImagePair(a, b);
```
Choose an algorithm (from features section):
```
pair.setAlgorithm(IntersectionHistogram());
```
Compare the images using that algorithm:
```
var result = pair.compare();
```

## Algorithm Specifics: 
### ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `PixelMatching()`

#### About
 - Images are resized to the same dimensions (if dimensions don't match) and each [src1] pixel's RGB value is checked to see if it falls within 5% (of 256) of [src2] pixel's RGB value.
 - Best with images of similar aspect ratios and dimensions
 - Compare for exactness (if two images are identical)

#### Returns
 - Returns percentage similarity (0.0 - no similarity, 1.0 - 100% similarity)

### ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `EuclideanColorDistance()`

#### About
 - Images are resized to the same dimensions (if dimensions don't match) and euclidean difference between [src1] RGB values and [src2] RGB values for each pixel is summed.
 - Best with images of similar aspect ratios and dimensions
 - Compare for exactness (if two images are identical)

#### Returns
 - Returns percentage difference (0.0 - no difference, 1.0 - 100% difference)

### ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `IMED()`
*Source: https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.680.2097&rep=rep1&type=pdf*

#### About
 - Images are resized to the same dimensions (if dimensions don't match) and are grayscaled. A gaussian blur is applied when calculating distance between pixel intensities.    Spatial relationship is taken into account within the guassian function to reduce the effect of minor perturbations (ignores minor differences). 
 - Gaussian blur has been modified: area decreased (Note)
 - Best with images of similar aspect ratios and dimensions
 - Compare for ~exactness (if two images are roughly identical)

#### Returns
 - Returns percentage difference (0.0 - no difference, 1.0 - 100% difference)

### ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `ChiSquareDifferenceHistogram()`

#### About
 - Images are converted to histogram representations (x-axis intensity, y-axis frequency). The chi-square distance formula is applied to compute the distance between each of the 256 bins. There are three histograms per image (RGB histograms).  
 - Works with images of all aspect ratios and dimensions
 - Compare for similarity (if two images are similar based on their color distribution)

#### Returns
 - Returns percentage difference (0.0 - no difference, 1.0 - 100% difference)

### ![#1589F0](https://via.placeholder.com/15/1589F0/000000?text=+) `IntersectionHistogram()`

#### About
 - Images are converted to histogram representations (x-axis intensity, y-axis frequency). The chi-square distance formula is applied to compute the distance between each of the 256 bins. There are three histograms per image (RGB histograms).  
 - Works with images of all aspect ratios and dimensions
 - Compare for similarity (if two images are similar based on their color distribution)

#### Returns
 - Returns percentage similarity (0.0 - no similarity, 1.0 - 100% similarity)


