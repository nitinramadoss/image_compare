import 'dart:math';
import 'package:image/image.dart';

/// Abstract class for all algorithms
abstract class Algorithm {
  /// [Pair] of [Pixel] lists for [src1] and [src2]
  var _pixelListPair;

  /// Default constructor gets implicitly called on subclass instantiation
  Algorithm();

  /// Creates lists of [Pixel] for [src1] and [src2] for sub class compare operations
  double compare(Image src1, Image src2) {
    // Pixel representation of [src1] and [src2]
    _pixelListPair = Pair([], []);

    // Bytes for [src1] and [src2]
    var bytes1 = src1.getBytes();
    var bytes2 = src2.getBytes();
    final bytesPerPixel = 4;

    for (var i = 0; i <= bytes1.length - bytesPerPixel; i += bytesPerPixel) {
      _pixelListPair._first
          .add(Pixel(bytes1[i], bytes1[i + 1], bytes1[i + 2], bytes1[i + 3]));
    }

    for (var i = 0; i <= bytes2.length - bytesPerPixel; i += bytesPerPixel) {
      _pixelListPair._second
          .add(Pixel(bytes2[i], bytes2[i + 1], bytes2[i + 2], bytes2[i + 3]));
    }

    return 0.0; // default return
  }
}

/// Organizational class for storing [src1] and [src2] data.
/// Fields are RGBA values
class Pixel {
  final int _red;
  final int _green;
  final int _blue;
  final int _alpha;

  Pixel(this._red, this._green, this._blue, this._alpha);

  @override
  String toString() {
    return 'red: $_red, green: $_green, blue: $_blue, alpha: $_alpha';
  }
}

/// Organizational class for storing a pair of generic
/// objects [T1] and [T2]
class Pair<T1, T2> {
  T1 _first;
  T2 _second;

  Pair(this._first, this._second);
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

    return 0.0;
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
  /// Ignores alpha channel when computing difference
  var ignoreAlpha;

  EuclideanColorDistance({bool this.ignoreAlpha = false});

  /// Computes euclidean color distance between two images
  /// of the same size
  @override
  double compare(Image src1, Image src2) {
    // Delegates image resizing to parent
    super.compare(src1, src2);

    var sum = 0.0;

    var numPixels = _pixelListPair._first.length;

    var alphaBit = (ignoreAlpha) ? 0 : 1;

    for (var i = 0; i < numPixels; i++) {
      sum += sqrt(pow(
              (_pixelListPair._first[i]._red - _pixelListPair._second[i]._red) /
                  255,
              2) +
          pow(
              (_pixelListPair._first[i]._blue -
                      _pixelListPair._second[i]._blue) /
                  255,
              2) +
          pow(
              (_pixelListPair._first[i]._green -
                      _pixelListPair._second[i]._green) /
                  255,
              2) +
          (alphaBit *
              pow(
                  (_pixelListPair._first[i]._alpha -
                          _pixelListPair._second[i]._alpha) /
                      255,
                  2)));
    }

    return sum / (numPixels * sqrt(3 + alphaBit));
  }

  @override
  String toString() {
    return 'Euclidean Color Distance';
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
/// * Returns percentage diffence (0.0 - no difference, 1.0 - 100% difference)
class PixelMatching extends DirectAlgorithm {
  /// Ignores alpha channel when computing difference
  var ignoreAlpha;

  /// Percentage tolerance value between 0.0 and 1.0
  /// of the range of RGB values, 256, used when directly
  /// comparing pixels for equivalence.
  ///
  /// A value of 0.05 means that one RGB value can be + or -
  /// (0.05 * 256) of another RGB value.
  var tolerance;

  PixelMatching({bool this.ignoreAlpha = false, this.tolerance = 0.05});

  /// Computes overlap between two images's color intensities.
  /// Return value is the fraction similarity e.g. 0.1 means 10%
  @override
  double compare(Image src1, Image src2) {
    // Delegates image resizing to parent
    super.compare(src1, src2);

    var count = 0;

    tolerance = (tolerance < 0.0) ? 0.0 : tolerance;
    tolerance = (tolerance > 1.0) ? 1.0 : tolerance;

    var delta = tolerance * 256;

    var numPixels = _pixelListPair._first.length;

    for (var i = 0; i < numPixels; i++) {
      if (_withinRange(delta, _pixelListPair._first[i]._red,
              _pixelListPair._second[i]._red) &&
          _withinRange(delta, _pixelListPair._first[i]._blue,
              _pixelListPair._second[i]._blue) &&
          _withinRange(delta, _pixelListPair._first[i]._green,
              _pixelListPair._second[i]._green)) {
        if (ignoreAlpha ||
              _withinRange(delta, _pixelListPair._first[i]._alpha,
                  _pixelListPair._second[i]._alpha)) {
                    count++;
                  }
      }
    }

    return 1 - (count / numPixels);
  }

  bool _withinRange(var delta, var value, var target) {
    return (target - delta <= value && value <= target + delta);
  }

  @override
  String toString() {
    return 'Pixel Matching';
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
/// * Does not handle transparent pixels
/// * Returns percentage difference (0.0 - no difference, 1.0 - 100% difference)
class IMED extends DirectAlgorithm {
  /// Width parameter of the guassian function
  var sigma;

  /// Percentage of the smaller image's width representing a
  /// component of the window (box) width used for the gaussian blur.
  ///
  /// Guassian blur box width = 1 + ([blurRatio] * (width - 1) / 2) * 2
  ///
  /// The larger this percentage is, the larger the gaussian blur is.
  ///
  /// Note: Large [blurRatio] values can lead to a long computation time
  /// for comparisons.
  var blurRatio;

  IMED({double this.sigma = 1, double this.blurRatio = 0.005});

  /// Computes distance between two images
  /// using image euclidean distance
  @override
  double compare(Image src1, Image src2) {
    // Delegates image resizing to parent
    super.compare(src1, src2);

    var sum = 0.0;
    var gaussNorm = 0.0; // factor to divide by to normalize

    // image with smaller area
    final smallSrc =
        (src1.width * src1.height < src2.width * src2.height) ? src1 : src2;

    blurRatio = (blurRatio < 0.0) ? 0.0 : blurRatio;
    blurRatio = (blurRatio > 1.0) ? 1.0 : blurRatio;

    final offset = (blurRatio * (smallSrc.width - 1) ~/ 2).ceil();

    for (var i = 0; i < _pixelListPair._first.length; i++) {
      var currH = i ~/ smallSrc.width - offset; // current row in image matrix

      final leftEdgeOffset = ((i - offset) ~/ smallSrc.width == currH + offset)
          ? (i - offset)
          : i - (i % smallSrc.width);

      final rightEdgeOffset = ((i + offset) ~/ smallSrc.width == currH + offset)
          ? (i + offset)
          : i + (smallSrc.width - (i % smallSrc.width)) - 1;

      var len = rightEdgeOffset - leftEdgeOffset + 1; // box width

      var start = leftEdgeOffset - (smallSrc.width * offset); // index in list
      var end = rightEdgeOffset + (smallSrc.width * offset);

      for (var j = start; j <= end; j++) {
        var x = _pixelListPair._first; // src1 pixel list
        var y = _pixelListPair._second; // src2 pixel list

        if ((j >= 0 && j < y.length) && j ~/ smallSrc.width == currH) {
          var gauss =
              exp(-pow(_distance(i, j, src1.width), 2) / 2 * pow(sigma, 2));

          gaussNorm += gauss;

          sum += gauss *
              (_grayValue(x[i]) - _grayValue(y[i])) /
              255 *
              (_grayValue(x[j]) - _grayValue(y[j])) /
              255;
        }

        if (j == (start + len - 1)) {
          j = start + smallSrc.width;
          start = j;
          j--;
          currH++;
        }
      }
    }

    return sum / gaussNorm;
  }

  /// Helper function to return grayscale value of a pixel
  int _grayValue(Pixel p) {
    return getLuminanceRgb(p._red, p._green, p._blue);
  }

  /// Helper function to return distance between two pixels at
  /// indices [i] and [j]
  double _distance(var i, var j, var width) {
    var distance = 0.0;
    var pointA = Pair((i % width), (i / width));
    var pointB = Pair((j % width), (j / width));

    distance = sqrt(pow(pointB._first - pointA._first, 2) +
        pow(pointB._second - pointA._second, 2));

    return distance;
  }

  @override
  String toString() {
    return 'IMage Euclidean Distance';
  }
}

/// Abstract class for all hash alogrithms
abstract class HashAlgorithm extends Algorithm {
  @override
  double compare(Image src1, Image src2) {
    // Delegates pixel extraction to parent
    super.compare(src1, src2);

    return 0.0; //default return
  }

  /// Helper function used by subclasses to return hamming distance between two hashes
  double _hammingDistance(String str1, String str2) {
    var distCounter = (str1.length - str2.length).abs();
    var smaller = min(str1.length, str2.length);
    var larger = max(str1.length, str2.length);

    for (var i = 0; i < smaller; i++) {
      distCounter += str1[i] != str2[i] ? 1 : 0;
    }

    return pow((distCounter / larger), 2).toDouble();
  }
}

/// Algorithm class for comparing images with the perceptual hash method
///
/// Images are grayscaled and resized to 32x32. Then they are passed through a 1-dimension discrete cosine transformation.
/// The top 8x8 is only accounted for since it gives the generalized frequency of the image. With this, a hash is created.
///
///
/// * Applications in digital forensics, copyright protection, and media file search
/// * Works well with images of any dimension and aspect ratio
/// * Comparing image fingerprints
/// * Images can be rotated
/// * Does not handle transparent pixels
/// * Returns percentage diffence (0.0 - no difference, 1.0 - 100% difference)
class PerceptualHash extends HashAlgorithm {
  final int _size = 32;

  ///Resize and grayscale images
  @override
  double compare(Image src1, Image src2) {
    src1 = copyResize(src1, height: 32, width: 32);
    src2 = copyResize(src2, height: 32, width: 32);

    super.compare(src1, src2);

    var hash1 = calcPhash(_pixelListPair._first);
    var hash2 = calcPhash(_pixelListPair._second);

    return _hammingDistance(hash1, hash2);
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

  @override
  String toString() {
    return 'Perceptual Hash';
  }
}

/// Algorithm class for comparing images using average values of pixels.
///
/// Images are resized to 8x8 and grayscaled.
/// Afterwards, this algorithm finds the average pixel value by getting the sum of all pixel values and dividing  by total number of pixels.
/// Then, each pixel is checked against the actual value and average value. A binary string is created  which is converted to a hex hash.
///
/// * Work well with images of any dimension and aspect ratio
/// * Comparing image fingerprints
/// * Images can be rotated
/// * Does not handle transparent pixels
/// * Returns percentage diffence (0.0 - no difference, 1.0 - 100% difference)
class AverageHash extends HashAlgorithm {
  @override
  double compare(Image src1, Image src2) {
    src1 = copyResize(grayscale(src1), height: 8, width: 8);
    src2 = copyResize(grayscale(src2), height: 8, width: 8);

    super.compare(src1, src2);

    var hash1 = calcAvg(_pixelListPair._first);
    var hash2 = calcAvg(_pixelListPair._second);

    // Delegates hamming distance computation to parent
    return _hammingDistance(hash1, hash2);
  }

  /// Helper funciton to compute average hex hash for an image
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

  @override
  String toString() {
    return 'Average Hash';
  }
}

/// Algorithm class for comparing images using average values of pixels.
///
/// Images are resized to 9x8 and grayscaled.
/// Afterwards, this algorithm finds the median pixel value.
/// Then, each pixel is checked against the actual value and median value. A binary string is created and converted to a hex hash.
///
/// * Works well with images of any dimension and aspect ratio
/// * Comparing image fingerprints
/// * Images can be rotated
/// * Does not handle transparent pixels
/// * Returns percentage diffence (0.0 - no difference, 1.0 - 100% difference)
class MedianHash extends HashAlgorithm {
  @override
  double compare(Image src1, Image src2) {
    src1 = copyResize(grayscale(src1), height: 9, width: 8);
    src2 = copyResize(grayscale(src2), height: 9, width: 8);

    super.compare(src1, src2);

    var hash1 = calcMedian(_pixelListPair._first);
    var hash2 = calcMedian(_pixelListPair._second);

    // Delegates hamming distance computation to parent
    return _hammingDistance(hash1, hash2);
  }

  /// Helper funciton to compute median hex hash for an image
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

  @override
  String toString() {
    return 'Median Hash';
  }
}

/// Abstract class for all histogram algorithms
abstract class HistogramAlgorithm extends Algorithm {
  /// Number of bins in each histogram
  var _binSize;

  /// Normalized histograms for [src1] and [src2] stored in a [Pair]
  var _histograms;

  /// Default constructor gets implicitly called on subclass instantiation
  HistogramAlgorithm() {
    _binSize = 256;
  }

  /// Fills color intensity histograms for child class compare operations
  @override
  double compare(Image src1, Image src2) {
    // RGBA histograms for [src1] and [src2]
    _histograms = Pair(RGBAHistogram(_binSize), RGBAHistogram(_binSize));

    // Delegates pixel extraction to parent
    super.compare(src1, src2);

    final src1Size = src1.width * src1.height;
    final src2Size = src2.width * src2.height;

    for (Pixel pixel in _pixelListPair._first) {
      _histograms._first.redHist[pixel._red] += 1 / src1Size;
      _histograms._first.greenHist[pixel._green] += 1 / src1Size;
      _histograms._first.blueHist[pixel._blue] += 1 / src1Size;
      _histograms._first.alphaHist[pixel._alpha] += 1 / src1Size;
    }

    for (Pixel pixel in _pixelListPair._second) {
      _histograms._second.redHist[pixel._red] += 1 / src2Size;
      _histograms._second.greenHist[pixel._green] += 1 / src2Size;
      _histograms._second.blueHist[pixel._blue] += 1 / src2Size;
      _histograms._second.alphaHist[pixel._alpha] += 1 / src2Size;
    }

    return 0.0; // default return
  }

  /// Helper function that's overrided by subclasses
  /// to compute differences between histograms
  // ignore: unused_element
  double _diff(List src1Hist, List src2Hist) => 0.0;
}

/// Organizational class for storing [src1] and [src2] data.
/// Fields are RGBA histograms (256 element lists)
class RGBAHistogram {
  final _binSize;
  late List redHist;
  late List greenHist;
  late List blueHist;
  late List alphaHist;

  RGBAHistogram(this._binSize) {
    redHist = List.filled(_binSize, 0.0);
    greenHist = List.filled(_binSize, 0.0);
    blueHist = List.filled(_binSize, 0.0);
    alphaHist = List.filled(_binSize, 0.0); 
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
/// * Works well with images of all aspect ratios and dimensions
/// * Compare for similarity (if two images are similar based on their color distribution)
/// * Returns percentage difference (0.0 - no difference, 1.0 - 100% difference)
class ChiSquareDistanceHistogram extends HistogramAlgorithm {
  /// Ignores alpha channel when computing difference
  var ignoreAlpha;

  ChiSquareDistanceHistogram({bool this.ignoreAlpha = false});

  /// Calculates histogram similarity using chi-squared distance
  @override
  double compare(Image src1, Image src2) {
    // Delegates histogram initialization to parent
    super.compare(src1, src2);

    var sum = 0.0;

    var alphaBit = (ignoreAlpha) ? 0 : 1;

    sum += _diff(_histograms._first.redHist, _histograms._second.redHist) +
        _diff(_histograms._first.greenHist, _histograms._second.greenHist) +
        _diff(_histograms._first.blueHist, _histograms._second.blueHist) + 
        (alphaBit * _diff(_histograms._first.alphaHist, _histograms._second.alphaHist));

    return sum / (3 + alphaBit);
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

  @override
  String toString() {
    return 'Chi Square Distance Histogram';
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
/// * Works well with images of any aspect ratio and dimension
/// * Images can be rotated
/// * Compare for similarity (if two images are similar based on their color distribution)
/// * Returns percentage diffence (0.0 - no difference, 1.0 - 100% difference)
class IntersectionHistogram extends HistogramAlgorithm {
  /// Ignores alpha channel when computing difference
  var ignoreAlpha;

  IntersectionHistogram({bool this.ignoreAlpha = false});

  /// Calculates histogram similarity using standard intersection
  @override
  double compare(Image src1, Image src2) {
    // Delegates histogram initialization to parent
    super.compare(src1, src2);

    var sum = 0.0;

    var alphaBit = (ignoreAlpha) ? 0 : 1;

    sum += _diff(_histograms._first.redHist, _histograms._second.redHist) +
        _diff(_histograms._first.greenHist, _histograms._second.greenHist) +
        _diff(_histograms._first.blueHist, _histograms._second.blueHist) + 
        (alphaBit * _diff(_histograms._first.alphaHist, _histograms._second.alphaHist));

    return 1 - (sum / (3 + alphaBit));
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

  @override
  String toString() {
    return 'Intersection Histogram';
  }
}
