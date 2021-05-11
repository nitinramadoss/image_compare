import 'dart:collection';

import 'package:image/image.dart';

import 'algorithm.dart';

class HistogramAlgorithm implements Algorithm {
  @override
  double compare(Image src1, Image src2) {
    Map<int, int> map1 = {};
    Map<int, int> map2 = {};

    src1.getBytes().forEach((element) {
      if (!map1.containsKey(element)) {
        map1[element] = 1;
      } else {
        map1[element] += 1;
      }
    });
    src2.getBytes().forEach((element) {
      if (!map2.containsKey(element)) {
        map2[element] = 1;
      } else {
        map2[element] += 1;
      }
    });

    print('${sortKeys(map1)}\n\n${sortKeys(map2)}');

    return 1.0;
  }

  Map<int, int> sortKeys(Map<int, int> srcMap) {
    Map<int, int> temp = {};
    //for sorting based on keys
    for (var i = 1; i <= 255; i++) {
      temp[i] = srcMap.containsKey(i) ? srcMap[i] : 0;
    }
    return temp;
  }
}
