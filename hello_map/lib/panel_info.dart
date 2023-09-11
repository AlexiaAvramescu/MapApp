import 'dart:typed_data';

class PanelInfo {
  Uint8List? image;
  String name;
  String categoryName;
  String formattedCoords;

  PanelInfo({this.image, required this.name, required this.categoryName, required this.formattedCoords});
}
