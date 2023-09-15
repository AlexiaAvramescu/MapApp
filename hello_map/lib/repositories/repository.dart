import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_geographicarea.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_searchpreferences.dart';
import 'package:hello_map/instruction_model.dart';
import 'package:hello_map/landmark_info.dart';

abstract class Repository {
  Future<List<Landmark>> search(String text, Coordinates coordinates,
      {SearchPreferences? preferences, RectangleGeographicArea? geographicArea});

  set favoritesUpdateCallBack(VoidCallback function);
  Future<void> initializeServices();
  List<Landmark> getFavorites();
  void updateFavoritesPageList();
  Coordinates transformScreenToWgs(double x, double y);
  Future<Uint8List?> decodeLandmarkIcon(Landmark landmark);
  Future<String> getAddressFromLandmark(Landmark landmark);
  Future<void> centerOnLandmark(Landmark landmark);
  Future<void> centerOnCoordinates(Coordinates coordinates);
  Future<LandmarkInfo> getLandmarkInfo(Landmark focusedLandmark);
  void deactivateAllHighlights();
  Future<bool> onFavoritesTap({required bool isLandmarkFavorite, required Landmark focusedLandmark});
  Future<bool> checkIfFavourite({required Landmark focusedLandmark});
  Future<Landmark?> registerTapCallback(Point<num> pos);
  Future<void> onFollowPositionButtonPressed(void Function(Coordinates) mapUpdateCallback);
  Future<void> calculateRoute(Landmark destiantion);
  Future<void> startSimulation({required void Function(InstructionModel) updateInstructionCallBack});
}
