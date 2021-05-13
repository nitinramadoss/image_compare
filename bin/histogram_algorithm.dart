import 'dart:collection';
import 'dart:typed_data';

import 'package:image/image.dart';

import 'algorithm.dart';

class HistogramAlgorithm extends Algorithm {
  var redHist = List.filled(256, 0);
  var blueHist = List.filled(256, 0);
  var greenHist = List.filled(256, 0);

  @override
  double compare(Image src1, Image src2) {
    for (var i = 0; i < src1.height; i++) {
      for (var j = 0; j < src1.width; j++) {
        int pixel = src1.getPixelSafe(i, j);
        Uint32List list = new Uint32List.fromList([pixel]);
        Uint8List byte_data = list.buffer.asUint8List();
        redHist[byte_data[0]] += 1;
        blueHist[byte_data[1]] += 1;
        greenHist[byte_data[2]] += 1;
      }
    }

    print(redHist);
    return 1;
  }
}
