import 'package:image/image.dart';

import 'algorithm.dart';

class ImagePair {
  //Algorithm used for comparison
  Algorithm _imageAlgo;

  //Image sources
  Image _src1;
  Image _src2;

  //Constructor
  ImagePair(Image src1, Image src2) {
    _src1 = src1;
    _src2 = src2;
  }

  //sets instances spciefied algorithm
  void setAlgorithm(Algorithm algorithm) {
    _imageAlgo = algorithm;
  }

//calls Algorithm's compare funciton and returns result
  double compare() {
    return _imageAlgo.compare(_src1, _src2);
  }

//getters for the images set at init
  Image get image1 => _src1;
  Image get image2 => _src2;
}
