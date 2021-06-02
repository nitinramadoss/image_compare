import 'dart:math';
import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

/// Compare [src1] and [src2] given a specified [algorithm].
/// If [algorithm] is not specified, the default (PixelMatching())
/// will be supplied.
double compareImages(Image src1, Image src2, [Algorithm? algorithm]) {
  algorithm ??= PixelMatching(); //default algorithm

  return algorithm.compare(src1, src2);
}

/// Compare [target] to each image present in [images] using a
/// specified [algorithm]. 
/// Returns a list of doubles corresponding to the compare
/// output for each pair of input: [target] and images[i].
/// Output is in the same order as [images].
/// 
/// If [algorithm] is not specified, the default (PixelMatching())
/// will be supplied.
List<double> listCompare(Image target, List<Image> images, [Algorithm? algorithm]) {
  algorithm ??= PixelMatching(); //default algorithm
  var results = <double>[];

  images.forEach((element) => 
            results.add(compareImages(target, element, algorithm)));

  return results;
}

/// Abstract class for all algorithms
abstract class Algorithm {
  /// Tuple of [Pixel] lists for [src1] and [src2]
  @protected
  var _pixelListPair;

  /// Default constructor gets implicitly called on subclass instantiation
  Algorithm() {
    _pixelListPair = Tuple2<List, List>([], []);
  }

  /// Creates lists of [Pixel] for [src1] and [src2] for sub class compare operations
  double compare(Image src1, Image src2) {
    // RGB intensities
    var bytes1 = src1.getBytes(format: Format.rgb);
    var bytes2 = src2.getBytes(format: Format.rgb);

    for (var i = 0; i <= bytes1.length - 3; i += 3) {
      _pixelListPair.item1.add(Pixel(bytes1[i], bytes1[i + 1], bytes1[i + 2]));
    }

    for (var i = 0; i <= bytes2.length - 3; i += 3) {
      _pixelListPair.item2.add(Pixel(bytes2[i], bytes2[i + 1], bytes2[i + 2]));
    }

    return 0.0; // default return
  }
}

/// Organizational class for storing [src1] and [src2] data.
/// Fields are RGB values
class Pixel {
  final int _red;
  final int _blue;
  final int _green;

  Pixel(this._red, this._blue, this._green);

  @override
  String toString() {
    return 'red: $_red, blue: $_blue, green: $_green';
  }
}

/// Algorithm class for comparing images pixel-by-pixel
abstract class DirectAlgorithm extends Algorithm {
  /// Resizes images if dimensions do not match.
  /// If different sizes, larger image will be
  /// resized to the smaller image
  @override
  double compare(Image src1, Image src2) {
    if (src1.width != src2.width && src1.height != src2.height) {
      var size1 = src1.width * src1.height;
      var size2 = src2.width * src2.height;

      if (size1 < size2) {
        src2 = copyResize(src2, height: src1.height, width: src1.width);
      } else {
        src1 = copyResize(src1, height: src2.height, width: src2.width);
      }
    }

    // Delegates pixel extraction to parent
    super.compare(src1, src2);

    return 1.0;
  }
}

/// Algorithm class for comparing images with euclidean distance.
///
/// Images are resized to the same dimensions (if dimensions don't match)
/// and euclidean difference between [src1] RGB values and [src2] RGB values
/// for each pixel is summed.
///
/// sum(sqrt(([src1[i].red - [src2[i].red)^2 + ([src1[i].blue - [src2[i].blue)^2 +
/// ([src1[i].green - [src2[i].green)^2)
///
/// * Best with images of similar aspect ratios and dimensions
/// * Compare for exactness (if two images are identical)
/// * Returns percentage difference (0.0 - no difference, 1.0 - 100% difference)
class EuclideanColorDistance extends DirectAlgorithm {
  /// Computes euclidean color distance between two images
  /// of the same size
  @override
  double compare(Image src1, Image src2) {
    // Delegates image resizing to parent
    super.compare(src1, src2);

    var sum = 0.0;

    var numPixels = _pixelListPair.item1.length;

    for (var i = 0; i < numPixels; i++) {
      sum += sqrt(pow(
              (_pixelListPair.item1[i]._red - _pixelListPair.item2[i]._red) /
                  255,
              2) +
          pow(
              (_pixelListPair.item1[i]._blue - _pixelListPair.item2[i]._blue) /
                  255,
              2) +
          pow(
              (_pixelListPair.item1[i]._green -
                      _pixelListPair.item2[i]._green) /
                  255,
              2));
    }

    return sum / (numPixels * sqrt(3)); // percentage difference
  }
}

/// Algorithm class for comparing images with standard pixel matching.
///
/// Images are resized to the same dimensions (if dimensions don't match)
/// and each [src1] pixel's RGB value is checked to see if it falls within 5%
/// (of 256) of [src2] pixel's RGB value.
///
/// * Best with images of similar aspect ratios and dimensions
/// * Compare for exactness (if two images are identical)
/// * Returns percentage similarity (0.0 - no similarity, 1.0 - 100% similarity)
class PixelMatching extends DirectAlgorithm {
  /// Computes overlap between two images's color intensities.
  /// Return value is the fraction similarity e.g. 0.1 means 10%
  @override
  double compare(Image src1, Image src2) {
    // Delegates image resizing to parent
    super.compare(src1, src2);

    var count = 0;
    // percentage leniency for pixel comparison
    var delta = 0.05 * 256;

    var numPixels = _pixelListPair.item1.length;

    for (var i = 0; i < numPixels; i++) {
      if (_withinRange(delta, _pixelListPair.item1[i]._red,
              _pixelListPair.item2[i]._red) &&
          _withinRange(delta, _pixelListPair.item1[i]._blue,
              _pixelListPair.item2[i]._blue) &&
          _withinRange(delta, _pixelListPair.item1[i]._green,
              _pixelListPair.item2[i]._green)) {
        count++;
      }
    }

    return count / numPixels; // fraction similarity
  }

  bool _withinRange(var delta, var value, var target) {
    return (target - delta < value && value < target + delta);
  }
}

/// Algorithm class for comparing images with image euclidean distance
///
/// Images are resized to the same dimensions (if dimensions don't match)
/// and are grayscaled. A gaussian blur is applied when calculating distance
/// between pixel intensities. Spatial relationship is taken into account
/// within the guassian function to reduce the effect of minor perturbations.
///
/// sum(exp(-distance([i], [j]) ^2 / 2 * pi * sigma^2) * (src1[i] - src2[i]) *
/// (src1[j] - src2[j]))
///
/// * Best with images of similar aspect ratios and dimensions
/// * Compare for ~exactness (if two images are roughly identical)
/// * Returns percentage difference (0.0 - no difference, 1.0 - 100% difference)
class IMED extends DirectAlgorithm {
  /// Computes distance between two images
  /// using image euclidean distance
  @override
  double compare(Image src1, Image src2) {
    // Delegates image resizing to parent
    super.compare(src1, src2);

    var sum = 0.0;
    var gaussNorm = 0.0; // factor to divide by to normalize

    final SRC_PERCENTAGE = 0.005;
    final smallerDim = (src1.width < src1.height) ? src1.width : src1.height;

    final sigma = SRC_PERCENTAGE * smallerDim;
    final offset = (sigma).ceil();
    final len = 1 + offset * 2;

    for (var i = 0; i < _pixelListPair.item1.length; i++) {
      var start = (i - offset) - (src1.width * offset);

      for (var j = start; j <= (i + offset) + (src1.width * offset); j++) {
        var x = _pixelListPair.item1; // src1 pixel list
        var y = _pixelListPair.item2; // src2 pixel list

        if (j >= 0 && j < y.length) {
          var gauss =
              exp(-pow(_distance(i, j, src1.width), 2) / 2 * pow(sigma, 2));

          gaussNorm += gauss;

          sum += gauss *
              (_grayValue(x[i]) - _grayValue(y[i])) /
              255 *
              (_grayValue(x[j]) - _grayValue(y[j])) /
              255;
        }

        if (j == (start + len)) {
          j = start + src1.width;
          start = j;
        }
      }
    }

    return sum / gaussNorm; // percentage difference
  }

  /// Helper function to return grayscale value of a pixel
  int _grayValue(Pixel p) {
    return getLuminanceRgb(p._red, p._green, p._blue);
  }

  /// Helper function to return distance between two pixels at
  /// indices [i] and [j]
  double _distance(var i, var j, var width) {
    var distance = 0.0;
    var pointA = Tuple2((i % width), (i / width));
    var pointB = Tuple2((j % width), (j / width));

    distance = sqrt(pow(pointB.item1 - pointA.item1, 2) +
        pow(pointB.item2 - pointA.item2, 2));

    return distance;
  }
}

/// Abstract class for all hash alogrithms
abstract class HashAlgorithm extends Algorithm {
  // Delegates pixel extraction to parent
  @override
  double compare(Image src1, Image src2) {
    super.compare(src1, src2);
    return 0.0; //default return
  }

  // Helper function used by subclasses to return hamming distance between two hashes
  double hammingDistace(String str1, String str2) {
    var distCounter = 0;
    for (var i = 0; i < str1.length; i++) {
      distCounter += str1[i] != str2[i] ? 1 : 0;
    }
    return pow((distCounter / str1.length), 2).toDouble();
  }
}

/// Algorithm class for comparing images with the perceptual hash method based on https://github.com/freearhey/phash-js
class PerceptualHash extends HashAlgorithm {
  final int _size = 32;

  ///Resize and grayscale images
  @override
  double compare(Image src1, Image src2) {
    src1 = copyResize(grayscale(src1), height: 32, width: 32);
    src2 = copyResize(grayscale(src2), height: 32, width: 32);
    // Delegates image resizing to parent
    super.compare(src1, src2);

    var hash1 = calcPhash(_pixelListPair.item1);
    var hash2 = calcPhash(_pixelListPair.item2);

    return super.hammingDistace(hash1,
        hash2); //super class hamming distance method to return a value between 0-1
  }

  /// Helper function which computes a binary hash of a [List] of [Pixel]
  String calcPhash(List pixelList) {
    var bitString = '';
    var matrix = List<dynamic>.filled(32, 0);
    var row = List<dynamic>.filled(32, 0);
    var rows = List<dynamic>.filled(32, 0);
    var col = List<dynamic>.filled(32, 0);

    var data = unit8ListToMatrix(pixelList); //returns a matrix used for DCT
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        var color = data[x][y];
        row[x] = getLuminanceRgb(color._red, color._green, color._blue);
      }
      rows[y] = calculateDCT(row);
    }
    for (var x = 0; x < _size; x++) {
      for (var y = 0; y < _size; y++) {
        col[y] = rows[y][x];
      }
      matrix[x] = calculateDCT(col);
    }

    // Extract the top 8x8 pixels.
    var pixels = [];
    for (var y = 0; y < 8; y++) {
      for (var x = 0; x < 8; x++) {
        pixels.add(matrix[y][x]);
      }
    }
    // Calculate hash.
    var bits = [];
    var compare = average(pixels);
    for (var pixel in pixels) {
      bits.add(pixel > compare ? 1 : 0);
    }

    bits.forEach((element) {
      bitString += (1 * element).toString();
    });
    return BigInt.parse(bitString, radix: 2).toRadixString(16);
  }

  ///Helper funciton to compute the average of an array after dct caclulations
  num average(List pixels) {
    // Calculate the average value from top 8x8 pixels, except for the first one.
    var n = pixels.length - 1;
    return pixels.sublist(1, n).reduce((a, b) => a + b) / n;
  }

  ///Helper function to perform 1D discrete cosine tranformation on a matrix
  List calculateDCT(List matrix) {
    var transformed = List<num>.filled(32, 0);
    var _size = matrix.length;
    for (var i = 0; i < _size; i++) {
      num sum = 0;
      for (var j = 0; j < _size; j++) {
        sum += matrix[j] * cos((i * pi * (j + 0.5)) / _size);
      }
      sum *= sqrt(2 / _size);
      if (i == 0) {
        sum *= 1 / sqrt(2);
      }
      transformed[i] = sum;
    }

    return transformed;
  }

  ///Helper function to convert a Unit8List to a nD matrix
  List unit8ListToMatrix(List pixelList) {
    var copy = pixelList.sublist(0);
    pixelList.clear();
    for (var r = 0; r < _size; r++) {
      var res = [];
      for (var c = 0; c < _size; c++) {
        var i = r * _size + c;
        if (i < copy.length) {
          res.add(copy[i]);
        }
      }
      pixelList.add(res);
    }
    return pixelList;
  }
}

class AverageHash extends HashAlgorithm {
  @override
  double compare(Image src1, Image src2) {
    src1 = copyResize(grayscale(src1), height: 9, width: 8);
    src2 = copyResize(grayscale(src2), height: 9, width: 8);
    // Delegates image resizing to parent
    super.compare(src1, src2);
    var hash1 = calcAvg(_pixelListPair.item1);
    var hash2 = calcAvg(_pixelListPair.item2);

    return super.hammingDistace(hash1, hash2);
  }

  String calcAvg(List pixelList) {
    var srcArray = pixelList.map((e) => e._red).toList();

    var bitString = '';

    var mean = (srcArray.reduce((a, b) => a + b) / srcArray.length);
    srcArray.asMap().forEach((key, value) {
      srcArray[key] = value > mean ? 1 : 0;
    });

    srcArray.forEach((element) {
      bitString += (1 * element).toString();
    });
    return BigInt.parse(bitString, radix: 2).toRadixString(16);
  }
}

class MedianHash extends HashAlgorithm {
  @override
  double compare(Image src1, Image src2) {
    src1 = copyResize(grayscale(src1), height: 9, width: 8);
    src2 = copyResize(grayscale(src2), height: 9, width: 8);
    // Delegates image resizing to parent
    super.compare(src1, src2);

    var hash1 = calcMedian(_pixelListPair.item1);
    var hash2 = calcMedian(_pixelListPair.item2);

    // Delegates hamming distance computation to parent
    return super.hammingDistace(hash1, hash2);
  }

  /// Helper funciton to compute median binary hash for an image
  String calcMedian(List pixelList) {
    var srcArray = pixelList.map((e) => e._red).toList();
    var tempArr = List.from(srcArray);
    var bitString = '';
    tempArr.sort((a, b) => a.compareTo(b));
    var median = (tempArr[((tempArr.length - 1) / 2).floor()] +
            tempArr[((tempArr.length - 1) / 2).floor() + 1]) /
        2;
    srcArray.asMap().forEach((key, value) {
      srcArray[key] = value > median ? 1 : 0;
    });

    srcArray.forEach((element) {
      bitString += (1 * element).toString();
    });

    return BigInt.parse(bitString, radix: 2).toRadixString(16);
  }
}

/// Abstract class for all histogram algorithms
abstract class HistogramAlgorithm extends Algorithm {
  /// Number of bins in each histogram
  @protected
  var _binSize;

  /// Normalized histograms for [src1] and [src2] stored in a Tuple2
  @protected
  var _histograms;

  /// Default constructor gets implicitly called on subclass instantiation
  HistogramAlgorithm() {
    _binSize = 256;
    _histograms = Tuple2(RGBHistogram(_binSize), RGBHistogram(_binSize));
  }

  /// Fills color intensity histograms for child class compare operations
  @override
  double compare(Image src1, Image src2) {
    // Delegates pixel extraction to parent
    super.compare(src1, src2);

    final src1Size = src1.width * src1.height;
    final src2Size = src2.width * src2.height;

    for (Pixel pixel in _pixelListPair.item1) {
      _histograms.item1.redHist[pixel._red] += 1 / src1Size;
      _histograms.item1.greenHist[pixel._green] += 1 / src1Size;
      _histograms.item1.blueHist[pixel._blue] += 1 / src1Size;
    }

    for (Pixel pixel in _pixelListPair.item2) {
      _histograms.item2.redHist[pixel._red] += 1 / src2Size;
      _histograms.item2.greenHist[pixel._green] += 1 / src2Size;
      _histograms.item2.blueHist[pixel._blue] += 1 / src2Size;
    }

    return 0.0; // default return
  }

  /// Helper function that's overrided by subclasses
  /// to compute differences between histograms
  // ignore: unused_element
  double _diff(List src1Hist, List src2Hist) => 0.0;
}

/// Organizational class for storing [src1] and [src2] data.
/// Fields are RGB histograms (256 element lists)
class RGBHistogram {
  final _binSize;
  late List redHist;
  late List greenHist;
  late List blueHist;

  RGBHistogram(this._binSize) {
    redHist = List.filled(_binSize, 0.0);
    greenHist = List.filled(_binSize, 0.0);
    blueHist = List.filled(_binSize, 0.0);
  }
}

/// Algorithm class for comparing images with chi-square histogram intersections
///
/// Images are converted to histogram representations (x-axis intensity, y-axis frequency).
/// The chi-square distance formula is applied to compute the distance between each bin:
///
/// 0.5* sum((binCount1 - binCount2)^2 / (binCount1 + binCount2))
///
/// Number of histograms bins is 256. Three histograms represent RGB distributions.
///
/// * Works with images of all aspect ratios and dimensions
/// * Compare for similarity (if two images are similar based on their color distribution)
/// * Returns percentage difference (0.0 - no difference, 1.0 - 100% difference)
class ChiSquareDistanceHistogram extends HistogramAlgorithm {
  /// Calculates histogram similarity using chi-squared distance
  @override
  double compare(Image src1, Image src2) {
    // Delegates histogram initialization to parent
    super.compare(src1, src2);

    var sum = 0.0;

    sum += _diff(_histograms.item1.redHist, _histograms.item2.redHist) +
        _diff(_histograms.item1.greenHist, _histograms.item2.greenHist) +
        _diff(_histograms.item1.blueHist, _histograms.item2.blueHist);

    return sum / 3;
  }

  /// Helper function to compute chi square difference
  /// between two histograms
  @override
  double _diff(List src1Hist, List src2Hist) {
    var sum = 0.0;

    for (var i = 0; i < _binSize; i++) {
      var count1 = src1Hist[i];
      var count2 = src2Hist[i];

      sum += (count1 + count2 != 0)
          ? ((count1 - count2) * (count1 - count2)) / (count1 + count2)
          : 0;
    }

    return sum * 0.5;
  }
}

/// Algorithm class for comparing images with standard histogram intersection.
///
/// Images are converted to histogram representations (x-axis intensity, y-axis frequency).
/// Generated histograms are overlayed to examine percentage overlap, thereby indicating
/// percentage similarity in pixel intensity frequencies:
///
/// sum(min(binCount1, binCount2))
///
/// Number of histograms bins is 256. Three histograms represent RGB distributions.
///
/// * Best with images of similar aspect ratios and dimensions
/// * Compare for similarity (if two images are similar based on their color distribution)
/// * Returns percentage similarity (0.0 - no similarity, 1.0 - 100% similarity)
class IntersectionHistogram extends HistogramAlgorithm {
  /// Calculates histogram similarity using standard intersection
  @override
  double compare(Image src1, Image src2) {
    // Delegates histogram initialization to parent
    super.compare(src1, src2);

    var sum = 0.0;

    sum += _diff(_histograms.item1.redHist, _histograms.item2.redHist) +
        _diff(_histograms.item1.greenHist, _histograms.item2.greenHist) +
        _diff(_histograms.item1.blueHist, _histograms.item2.blueHist);

    return sum / 3; // percentage of [src2] that matches [src1]
  }

  /// Helper function to compute difference between two histograms
  /// by summing overlap
  @override
  double _diff(List src1Hist, List src2Hist) {
    var sum = 0.0;

    for (var i = 0; i < _binSize; i++) {
      var count1 = src1Hist[i];
      var count2 = src2Hist[i];

      sum += min(count1, count2);
    }

    return sum;
  }
}
