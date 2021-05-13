import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:tuple/tuple.dart';
import 'package:meta/meta.dart';

import 'algorithm.dart';

abstract class HistogramAlgorithm extends Algorithm {
  /// Normalized histograms for [src1] and [src2] stored in a Tuple2
  @protected
  var histograms = Tuple2(List.filled(256, 0.0), List.filled(256, 0.0));

  /// Fills color [histograms] for child class compare operations
  @override
  double compare(Image src1, Image src2) {

    var src1Total = src1.height*src1.width;

    for (var i = 0; i < src1.height; i++) {
      for (var j = 0; j < src1.width; j++) {
        var pixel = src1.getPixelSafe(i, j);
        var list = Uint32List.fromList([pixel]);
        var byte_data = list.buffer.asUint8List();

        histograms.item1[byte_data[0]] += 1/src1Total;
        histograms.item1[byte_data[1]] += 1/src1Total;
        histograms.item1[byte_data[2]] += 1/src1Total;     
      }
    }

    var src2Total = src1.height*src1.width;

    for (var i = 0; i < src2.height; i++) {
      for (var j = 0; j < src2.width; j++) {
        var pixel = src2.getPixelSafe(i, j);
        var list = Uint32List.fromList([pixel]);
        var byte_data = list.buffer.asUint8List();

        histograms.item2[byte_data[0]] += 1/src2Total;
        histograms.item2[byte_data[1]] += 1/src2Total;
        histograms.item2[byte_data[2]] += 1/src2Total;      
      }
    }
    
    return 0.0; // default return
  }
}
