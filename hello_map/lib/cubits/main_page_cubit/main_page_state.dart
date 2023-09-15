part of 'main_page_cubit.dart';

final class MainPageState {
  Landmark? focusedLandmark;
  bool isLandmarkFavorite;
  Coordinates? currentPosition;
  InstructionModel? currentInstruction;
  bool isNavigating;
  bool hasRoutes;

  MainPageState({
    this.focusedLandmark,
    this.isLandmarkFavorite = false,
    this.currentPosition,
    this.currentInstruction,
    this.hasRoutes = false,
    this.isNavigating = false,
  });
}

final class MainPageInitial extends MainPageState {
  MainPageInitial() : super();
}

final class MainPageFocusedLandmark extends MainPageState {
  MainPageFocusedLandmark({required Landmark landmark, bool isFavoriteLandmark = false})
      : super(focusedLandmark: landmark, isLandmarkFavorite: isFavoriteLandmark);
}

final class MainPageHasRoutes extends MainPageState {
  MainPageHasRoutes() : super(hasRoutes: true);
}

final class MainPageNavigating extends MainPageState {
  MainPageNavigating({required InstructionModel instruction})
      : super(hasRoutes: true, isNavigating: true, currentInstruction: instruction);
}
