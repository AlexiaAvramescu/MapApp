part of 'main_page_cubit.dart';

final class MainPageState {
  Landmark? focusedLandmark;
  bool isLandmarkFavorite;
  MainPageState({this.focusedLandmark, this.isLandmarkFavorite = false});
}

final class MainPageInitial extends MainPageState {
  MainPageInitial() : super();
}

final class MainPageFocusedLandmark extends MainPageState {
  MainPageFocusedLandmark({required Landmark landmark, bool isFavoriteLandmark = false})
      : super(focusedLandmark: landmark, isLandmarkFavorite: isFavoriteLandmark);
}
