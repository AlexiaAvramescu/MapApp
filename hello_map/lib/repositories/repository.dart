import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_geographicarea.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_searchpreferences.dart';
import 'package:hello_map/landmark_info.dart';

abstract class Repository {
  Future<List<Landmark>> search(String text, Coordinates coordinates,
      {SearchPreferences? preferences, RectangleGeographicArea? geographicArea});

  set favoritesUpdateCallBack(VoidCallback function);
  List<Landmark> getFavorites();
  Coordinates transformScreenToWgs(double x, double y);
  Future<Uint8List?> decodeLandmarkIcon(Landmark landmark);
  Future<String> getAddressFromLandmark(Landmark landmark);
  Future<void> centerOnCoordinates(Coordinates coordinates);
  Future<LandmarkInfo> getPanelInfo(Landmark focusedLandmark);
  void deactivateAllHighlights();
  Future<void> onFavoritesTap({required bool isLandmarkFavorite, required Landmark focusedLandmark});
  Future<bool> checkIfFavourite({required Landmark focusedLandmark});
  Future<Landmark?> registerLandmarkTapCallback(Point<num> pos);
}
