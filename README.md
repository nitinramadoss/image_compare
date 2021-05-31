# image_compare
## Comparing images for similarity
### Simple, extensible dart package

![alt text](https://www.google.com/imgres?imgurl=https%3A%2F%2Fs.cornershopapp.com%2Fproduct-images%2F2967643.jpg%3FversionId%3DzC4X7.h.qHcJarP54Ukt9gQl7fvRnzXP&imgrefurl=https%3A%2F%2Fcornershopapp.com%2Fen-us%2Fproducts%2F1rluj-red-apple-price-by-pound-6y8-le-beau-market&tbnid=pivl2W5q-lTWzM&vet=12ahUKEwic0s2Q8fLwAhUWHVMKHfHvDdMQMygAegUIARDrAQ..i&docid=O77UakJlv_oTSM&w=999&h=1000&q=red%20apple&hl=en&authuser=0&ved=2ahUKEwic0s2Q8fLwAhUWHVMKHfHvDdMQMygAegUIARDrAQ)


![alt text](https://www.google.com/url?sa=i&url=https%3A%2F%2Fcornershopapp.com%2Fen-us%2Fproducts%2F1rlpj-green-apple-price-by-pound-6y8-le-beau-market&psig=AOvVaw3ptySEAKqX6vQe8eT-BpNi&ust=1622515040831000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCOiPgNfx8vACFQAAAAAdAAAAABAH)

## Dependency
Add to pubspec.yaml
```
dependencies:
    image_compare: ^1.0.0
```

Import:
```
import 'package:image_compare/image_compare.dart';
```

## Features:
**Pixel Comparison Algorithms**
- Pixel matching
- Euclidean Color Distance
- IMage Euclidean Distance (IMED)

**Histogram Comparison Algorithms**
- Chi Square Difference
- Intersection 

**Hashing Comparison Algorithms**
- Average
- Median

