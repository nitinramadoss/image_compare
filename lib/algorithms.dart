import 'dart:math';

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

    for (var i = 0; i <= bytes1.length - 3; i += 3) {
      _pixelListPair.item1.add(Pixel(bytes1[i], bytes1[i + 1], bytes1[i + 2]));
    }

    for (var i = 0; i <= bytes2.length - 3; i += 3) {
      _pixelListPair.item2.add(Pixel(bytes2[i], bytes2[i + 1], bytes2[i + 2]));
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
abstract class HashAlgorithm extends Algorithm {
  @override
  double compare(Image src1, Image src2) {
    src1 = copyResize(grayscale(src1), height: 8, width: 8);
    src2 = copyResize(grayscale(src2), height: 8, width: 8);
    super.compare(src1, src2);
    return 1;
  }

  double hamming_distance(String str1, String str2) {
    var dist_counter = 0;
    for (var i = 0; i < str1.length; i++) {
      dist_counter += str1[i] != str2[i] ? 1 : 0;
    }
    return pow((dist_counter / str1.length), 2) * 100;
  }
}

class Average_Hash extends HashAlgorithm {
  @override
  double compare(Image src1, Image src2) {
    // Delegates histogram initialization to parent
    super.compare(src1, src2);
    print(_pixelListPair.item1.length);
    var hash1 = average_hash_algo(_pixelListPair.item1);
    var hash2 = average_hash_algo(_pixelListPair.item2);

    return super.hamming_distance(hash1, hash2);
  }

  String average_hash_algo(List pixel_list) {
    var src_array = pixel_list.map((e) => e._red).toList();

    var bit_string = '';

    var mean = (src_array.reduce((a, b) => a + b) / src_array.length);
    src_array.asMap().forEach((key, value) {
      src_array[key] = value > mean ? 1 : 0;
    });

    src_array.forEach((element) {
      bit_string += (1 * element).toString();
    });
    return BigInt.parse(bit_string, radix: 2).toRadixString(16);
  }
}

/// Abstract class for all histogram algorithms
abstract class HistogramAlgorithm extends Algorithm {
  /// Number of bins in each histogram
  @protected
  var _binSize;

  /// Histograms for [src1] and [src2] stored in a Tuple2
  @protected
  var _histograms;

  /// Default constructor gets implicitly called on subclass instantiation
  HistogramAlgorithm() {
    _binSize = 256;
    _histograms =
        Tuple2(List.filled(_binSize, 0.0), List.filled(_binSize, 0.0));
  }

  /// Fills color intensity histograms for child class compare operations
  @override
  double compare(Image src1, Image src2) {
    // Delegates pixel extraction to parent
    super.compare(src1, src2);

    for (Pixel pixel in _pixelListPair.item1) {
      _histograms.item1[pixel._red] += 1;
      _histograms.item1[pixel._blue] += 1;
      _histograms.item1[pixel._green] += 1;
    }

    for (Pixel pixel in _pixelListPair.item2) {
      _histograms.item2[pixel._red] += 1;
      _histograms.item2[pixel._blue] += 1;
      _histograms.item2[pixel._green] += 1;
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

      sum += (count1 + count2 != 0)
          ? ((count1 - count2) * (count1 - count2)) / (count1 + count2)
          : 0;
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

    return sum /
        (src2.width * src2.height); // percentage of [src2] that matches [src1]
  }
}
