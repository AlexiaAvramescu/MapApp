import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_geographicarea.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_landmarkstore.dart';
import 'package:gem_kit/api/gem_searchpreferences.dart';
import 'package:hello_map/panel_info.dart';

abstract class Repository {
  Future<List<Landmark>> search(String text, Coordinates coordinates,
      {SearchPreferences? preferences, RectangleGeographicArea? geographicArea});

  transformScreenToWgs(double x, double y);
  decodeLandmarkIcon(Landmark landmark);
  Future<String> getAddressFromLandmark(Landmark landmark);
  Future<void> onCenterCoordinatesButtonPressed(Coordinates coordinates);
  Future<PanelInfo> getPanelInfo(Landmark focusedLandmark);
  void deactivateAllHighlights();
  Future<void> onFavoritesTap(
      {required bool isLandmarkFavorite, required LandmarkStore favoritesStore, required Landmark focusedLandmark});
  Future<bool> checkIfFavourite({required LandmarkStore favoritesStore, required Landmark focusedLandmark});
}
