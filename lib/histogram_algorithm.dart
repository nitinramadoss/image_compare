import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:tuple/tuple.dart';
import 'package:meta/meta.dart';

import 'algorithm.dart';

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
    var src1Total = src1.height*src1.width;

    for (var i = 0; i < src1.height; i++) {
      for (var j = 0; j < src1.width; j++) {
        var pixel = src1.getPixelSafe(i, j);
        var list = Uint32List.fromList([pixel]);
        var byte_data = list.buffer.asUint8List();

        _histograms.item1[byte_data[0]] += 1/src1Total;
        _histograms.item1[byte_data[1]] += 1/src1Total;
        _histograms.item1[byte_data[2]] += 1/src1Total;     
      }
    }

    var src2Total = src2.height*src2.width;

    for (var i = 0; i < src2.height; i++) {
      for (var j = 0; j < src2.width; j++) {
        var pixel = src2.getPixelSafe(i, j);
        var list = Uint32List.fromList([pixel]);
        var byte_data = list.buffer.asUint8List();

        _histograms.item2[byte_data[0]] += 1/src2Total;
        _histograms.item2[byte_data[1]] += 1/src2Total;
        _histograms.item2[byte_data[2]] += 1/src2Total;      
      }
    }
    
    return 0.0; // default return
  }
}

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

