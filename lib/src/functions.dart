import 'package:image/image.dart';
import 'algorithms.dart';

/// Compare [src1] and [src2] given a specified [algorithm].
/// If [algorithm] is not specified, the default (PixelMatching())
/// will be supplied.
double compareImages(Image src1, Image src2, [Algorithm? algorithm]) {
  algorithm ??= PixelMatching(); //default algorithm

  return algorithm.compare(src1, src2);
}

/// Compare [target] to each image present in [images] using a
/// specified [algorithm].
/// Returns a list of doubles corresponding to the compare
/// output for each pair of input: [target] and images[i].
/// Output is in the same order as [images].
///
/// If [algorithm] is not specified, the default (PixelMatching())
/// will be supplied.
List<double> listCompare(Image target, List<Image> images,
    [Algorithm? algorithm]) {
  algorithm ??= PixelMatching(); //default algorithm
  var results = <double>[];

  images.forEach(
      (element) => results.add(compareImages(target, element, algorithm)));

  return results;
}