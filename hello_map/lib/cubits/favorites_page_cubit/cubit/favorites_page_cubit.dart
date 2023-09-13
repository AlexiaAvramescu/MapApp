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
    repo!.favoritesUpdateCallBack = updateFavorites;
    repo!.initializeServices();
  }

  Future<Uint8List?> decodeLandmarkIcon(Landmark landmark) => repo!.decodeLandmarkIcon(landmark);
  Future<Coordinates> getCoordinates(Landmark landmark) async => landmark.getCoordinates();
  void updateFavorites() async {
    var favorites = repo!.getFavorites().reversed.toList();
    if (favorites.isEmpty) {
      emit(FavoritesPageInitial());
    } else {
      emit(FavoritesPageWithItems(landmarks: favorites));
    }
  }

  Future<void> onCenterCoordinates(Coordinates coordinates) async => await repo!.centerOnCoordinates(coordinates);
}
