import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:tuple/tuple.dart';
import 'package:meta/meta.dart';

import 'algorithm.dart';

abstract class HistogramAlgorithm extends Algorithm {
  // Map string to Tuple2(List, List)
  @protected
  final histograms = {};

  /// Initializes [histograms] for child class compare operations
  @override
  double compare(Image src1, Image src2) {
    histograms['red'] = Tuple2(List.filled(256, 0), List.filled(256, 0));
    histograms['blue'] = Tuple2(List.filled(256, 0), List.filled(256, 0));
    histograms['green'] = Tuple2(List.filled(256, 0), List.filled(256, 0));

    for (var i = 0; i < src1.height; i++) {
      for (var j = 0; j < src1.width; j++) {
        var pixel = src1.getPixelSafe(i, j);
        var list = Uint32List.fromList([pixel]);
        var byte_data = list.buffer.asUint8List();

        histograms['red'].item1[byte_data[0]] += 1;
        histograms['blue'].item1[byte_data[1]] += 1;
        histograms['green'].item1[byte_data[2]] += 1;      
      }
    }

     for (var i = 0; i < src2.height; i++) {
      for (var j = 0; j < src2.width; j++) {
        var pixel = src2.getPixelSafe(i, j);
        var list = Uint32List.fromList([pixel]);
        var byte_data = list.buffer.asUint8List();

        histograms['red'].item2[byte_data[0]] += 1;
        histograms['blue'].item2[byte_data[1]] += 1;
        histograms['green'].item2[byte_data[2]] += 1;      
      }
    }
    
    return 0.0; // default return
  }
}
