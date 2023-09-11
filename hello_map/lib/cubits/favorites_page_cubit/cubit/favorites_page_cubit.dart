import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:hello_map/controller.dart';
import 'package:hello_map/repositories/repository.dart';
import 'package:meta/meta.dart';

part 'favorites_page_state.dart';

class FavoritesPageCubit extends Cubit<FavoritesPageState> {
  Repository? repo;

  FavoritesPageCubit() : super(FavoritesPageInitial());

  void setRepo() {
    repo = Controller.sl.get<Repository>();
  }

  Future<Uint8List?> decodeLandmarkIcon(Landmark landmark) => repo!.decodeLandmarkIcon(landmark);
  Future<Coordinates> getCoordinates(Landmark landmark) async => landmark.getCoordinates();
  Future<List<Landmark>> fromLandmarkListToListOfLandmarks() async {
    var length = state.landmarkList.length;
    List<Landmark> landmarks = [];

    for (int i = 0; i < length; i++) {
      Landmark landmark = state.landmarkList[i];
      landmarks.add(landmark);
    }
    return landmarks.reversed.toList();
  }
}
