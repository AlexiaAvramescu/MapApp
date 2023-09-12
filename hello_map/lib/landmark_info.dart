import 'dart:typed_data';

class LandmarkInfo {
  Uint8List? image;
  String name;
  String categoryName;
  String formattedCoords;

  LandmarkInfo({this.image, required this.name, required this.categoryName, required this.formattedCoords});
}
