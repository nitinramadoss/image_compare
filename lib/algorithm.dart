import 'package:image/image.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

abstract class Algorithm {
  /// Tuple of [Pixel] lists for [src1] and [src2]
  @protected
  var _pixelListPair;

  Algorithm() {
    _pixelListPair = Tuple2<List, List>([], []);
  }

  /// Creates lists of [Pixel] for [src1] and [src2] for sub class compare operations
  double compare(Image src1, Image src2) {
    // RGB intensities 
    var bytes1 = src1.getBytes(format: Format.rgb);
    var bytes2 = src2.getBytes(format: Format.rgb);

    for (var i = 0; i < bytes1.length-3; i+=3) {
      _pixelListPair.item1.add(Pixel(bytes1[i], bytes1[i+1], bytes1[i+2])); 
    }

    for (var i = 0; i < bytes2.length-3; i+=3) {
      _pixelListPair.item2.add(Pixel(bytes2[i], bytes2[i+1], bytes2[i+2])); 
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
