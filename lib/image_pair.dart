import 'package:image/image.dart';

import 'algorithm.dart';

class ImagePair {
  /// Algorithm used for comparison
  late Algorithm _algorithm;

  /// Image objects from the dart image library
  late Image _src1;
  late Image _src2;

  /// ImagePair constructor requires [src1] and [src2] images from the dart image library
  ImagePair(Image src1, Image src2) {
    _src1 = src1;
    _src2 = src2;
  }

  /// Sets concrete subclass, [algorithm], for Algorithm
  void setAlgorithm(Algorithm algorithm) {
    _algorithm = algorithm;
  }

  /// Delegates compare request to [algorithm] object 
  double compare() {
    return _algorithm.compare(_src1, _src2);
  }
 
  /// Getters for [src1] and [src2]
  Image get image1 => _src1;
  Image get image2 => _src2;
}
