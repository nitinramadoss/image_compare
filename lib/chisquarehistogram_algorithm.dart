import 'dart:math';

import 'package:image/image.dart';

import 'histogram_algorithm.dart';

class ChiSquareHistogramAlgorithm extends HistogramAlgorithm {
  @override
  double compare(Image src1, Image src2) {
    // Delegates histogram initialization to parent
    super.compare(src1, src2);

    var binSize = super.binSize;

    var sum = 0.0;
    for (var i = 0; i < binSize; i++) {
      var count1 = super.histograms.item1[i];
      var count2 = super.histograms.item2[i];

      sum += ((count1-count2) * (count1-count2)) / (count1 + count2);
    }
    sum *= 0.5;

    return sum;
  }
}