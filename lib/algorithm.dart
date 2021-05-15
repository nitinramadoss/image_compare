import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

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

    for (var i = 0; i < bytes1.length-3; i+=3) {
      _pixelListPair.item1.add(Pixel(bytes1[i], bytes1[i+1], bytes1[i+2])); 
    }

    for (var i = 0; i < bytes2.length-3; i+=3) {
      _pixelListPair.item2.add(Pixel(bytes2[i], bytes2[i+1], bytes2[i+2])); 
    }

    return 0.0; // default return
  }
}

/// Organizational class for storing [src1] and [src2] data
class Pixel {
  final int _red;
  final int _blue;
  final int _green;

  Pixel(this._red, this._blue, this._green);
}

/// Algorithm class for comparing images with euclidean distance
class DistanceAlgorithm extends Algorithm {
  @override
  double compare(Image src1, Image src2) {
    // Delegates pixel extraction to parent
    super.compare(src1, src2);

    return 1.0;
  }
}

/// Algorithm class for comparing images with hashing
class HashAlgorithm extends Algorithm {
  @override
  double compare(Image src1, Image src2) {
    var hash1 = md5.convert(src1.getBytes());
    var hash2 = md5.convert(src2.getBytes());
    return hash1 == hash2 ? 1.0 : 0.0;
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
    _histograms = Tuple2(List.filled(_binSize, 0.0), List.filled(_binSize, 0.0));
  }

  /// Fills color intensity histograms for child class compare operations
  @override
  double compare(Image src1, Image src2) {    
    // Delegates pixel extraction to parent
    super.compare(src1, src2);

    // Number of pixels in [src1]
    var src1Total = src1.height*src1.width;

    for (Pixel pixel in _pixelListPair.item1) {
      _histograms.item1[pixel._red] += 1/src1Total;
      _histograms.item1[pixel._blue] += 1/src1Total;
      _histograms.item1[pixel._green] += 1/src1Total;   
    }

    // Number of pixels in [src2]
    var src2Total = src2.height*src2.width;

    for (Pixel pixel in _pixelListPair.item2) {
      _histograms.item2[pixel._red] += 1/src2Total;
      _histograms.item2[pixel._blue] += 1/src2Total;
      _histograms.item2[pixel._green] += 1/src2Total;   
    }
    
    return 0.0; // default return
  }
}

/// Algorithm class for comparing images with chi-square histogram intersections
class ChiSquareHistogramAlgorithm extends HistogramAlgorithm {
  
  /// Calculates histogram similarity using chi-squared distance
  @override
  double compare(Image src1, Image src2) {
    // Delegates histogram initialization to parent
    super.compare(src1, src2);

    var sum = 0.0;
    for (var i = 0; i < _binSize; i++) {
      var count1 = _histograms.item1[i];
      var count2 = _histograms.item2[i];

      sum += (count1 + count2 != 0)? 
        ((count1-count2) * (count1-count2)) / (count1 + count2) : 0;
    }
    sum *= 0.5;

    return sum; 
  }
}

/// Algorithm class for comparing images with standard histogram intersections
class IntersectionHistogramAlgorithm extends HistogramAlgorithm {
  
  /// Calculates histogram similarity using standard intersection
  @override
  double compare(Image src1, Image src2) {
    // Delegates histogram initialization to parent
    super.compare(src1, src2);

    var sum = 0.0;
    for (var i = 0; i < _binSize; i++) {
      var count1 = _histograms.item1[i];
      var count2 = _histograms.item2[i];

      sum += min(count1, count2);
    }

    return sum;
  }
}


