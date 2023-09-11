import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:hello_map/controller.dart';
import 'package:hello_map/panel_info.dart';
import 'package:hello_map/repositories/repository.dart';

part 'main_page_state.dart';

class MainPageCubit extends Cubit<MainPageState> {
  Repository? repo;
  MainPageCubit() : super(MainPageState());

  void setRepo() {
    repo = Controller.sl.get<Repository>();
  }

  Future<PanelInfo> getInfo() => repo!.getPanelInfo(state.focusedLandmark!);

  void onCancelLandmarkPanel() {
    repo!.deactivateAllHighlights;

    emit(MainPageState(focusedLandmark: null));
  }

  void onFavoritesTap() async {
    await repo!.onFavoritesTap(isLandmarkFavorite: state.isLandmarkFavorite, focusedLandmark: state.focusedLandmark!);
    bool value = await repo!.checkIfFavourite(focusedLandmark: state.focusedLandmark!);

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
}