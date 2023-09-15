import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:hello_map/controller.dart';
import 'package:hello_map/repositories/repository.dart';
part 'search_page_state.dart';

class SearchPageCubit extends Cubit<SearchPageState> {
  Repository? repo;

  SearchPageCubit() : super(SearchPageInitialState());

  void setRepo() {
    repo = Controller.sl.get<Repository>();
  }

  Coordinates getRelevantCoordinates(double x, double y) => repo!.transformScreenToWgs(x, y);

  // void onSearchTextChange(String text, Coordinates coordinates) async {
  //   Timer timer = Timer(Duration(seconds: 1), () async {
  //     await onSubmited(text, coordinates);
  //   });
  // }

  Future<void> onSubmited(String text, Coordinates coordinates) async {
    emit(SearchPageLoadingState());

    final landmarks = await repo!.search(text, coordinates);

    if (landmarks.isNotEmpty) {
      emit(SearchPageFoundState(landmarks: landmarks));
    } else {
      emit(SearchPageNoResultState());
    }
  }

  Future<Uint8List?> decodeLandmarkIcon(Landmark landmark) => repo!.decodeLandmarkIcon(landmark);

  List<Landmark> getLandmarks() => state.landmarks;

  Future<String> getAddress(Landmark landmark) => repo!.getAddressFromLandmark(landmark);

  Future<void> onCenterCoordinates(Coordinates coordinates) async => await repo!.centerOnCoordinates(coordinates);
}
