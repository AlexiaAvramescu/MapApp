import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:hello_map/controller.dart';
import 'package:hello_map/landmark_info.dart';
import 'package:hello_map/repositories/repository.dart';

part 'main_page_state.dart';

class MainPageCubit extends Cubit<MainPageState> {
  Repository? repo;
  MainPageCubit() : super(MainPageState());

  void setRepo() {
    repo = Controller.sl.get<Repository>();
  }

  Future<LandmarkInfo> getInfo() => repo!.getLandmarkInfo(state.focusedLandmark!);

  void onCancelLandmarkPanel() {
    repo!.deactivateAllHighlights;

    emit(MainPageState(focusedLandmark: null));
  }

  void onFavoritesTap() async {
    bool value = await repo!
        .onFavoritesTap(isLandmarkFavorite: state.isLandmarkFavorite, focusedLandmark: state.focusedLandmark!);

    repo!.updateFavoritesPageList();

    emit(MainPageState(focusedLandmark: state.focusedLandmark, isLandmarkFavorite: value));
  }

  Future<void> registerLandmarkTapCallback(Point<num> pos) async {
    final landmark = await repo!.registerLandmarkTapCallback(pos);
    if (landmark != null) {
      if (await repo!.checkIfFavourite(focusedLandmark: landmark)) {
        emit(MainPageFocusedLandmark(landmark: landmark, isFavoriteLandmark: true));
      } else {
        emit(MainPageFocusedLandmark(landmark: landmark));
      }
    }
  }

  Future<void> centerOnLandmark(Landmark landmark) async {
    await repo!.centerOnLandmark(landmark);

    bool isFavoriteLandmark = await repo!.checkIfFavourite(focusedLandmark: landmark);
    emit(MainPageFocusedLandmark(landmark: landmark, isFavoriteLandmark: isFavoriteLandmark));
  }

  void mapViewUpdate(Coordinates coordinates) {
    emit(MainPageState(currentPosition: coordinates));
  }

  Future<void> onFollowPositionButtonPressed() async {
    repo!.onFollowPositionButtonPressed(mapViewUpdate);
  }

  void onRouteTap() {
    repo!.calculateRoute(state.focusedLandmark!);
  }
}
