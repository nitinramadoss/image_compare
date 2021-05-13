import 'package:image/image.dart';
import 'package:crypto/crypto.dart';

import 'algorithm.dart';

class HashAlgorithm implements Algorithm {
  @override
  double compare(Image src1, Image src2) {
    var hash1 = md5.convert(src1.getBytes());
    var hash2 = md5.convert(src2.getBytes());
    return hash1 == hash2 ? 1.0 : 0.0;
  }
}
