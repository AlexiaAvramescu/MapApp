import 'package:bloc/bloc.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_landmarkstore.dart';
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
    bool value =
        await repo!.checkIfFavourite(favoritesStore: state.favoritesStore!, focusedLandmark: state.focusedLandmark!);

    emit(MainPageState(isLandmarkFavorite: value));

    await repo!.onFavoritesTap(
        isLandmarkFavorite: state.isLandmarkFavorite,
        favoritesStore: state.favoritesStore!,
        focusedLandmark: state.focusedLandmark!);

    emit(MainPageState(isLandmarkFavorite: !state.isLandmarkFavorite));
  }
}
