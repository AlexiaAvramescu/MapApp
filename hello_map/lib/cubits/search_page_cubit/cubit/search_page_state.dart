part of 'search_page_cubit.dart';

abstract class SearchPageState {
  final List<Landmark> landmarks;

  SearchPageState({required this.landmarks});
}

final class SearchPageInitialState extends SearchPageState {
  SearchPageInitialState() : super(landmarks: []);
}

final class SearchPageLoadingState extends SearchPageState {
  SearchPageLoadingState() : super(landmarks: []);
}

final class SearchPageNoResultState extends SearchPageState {
  SearchPageNoResultState() : super(landmarks: []);
}

final class SearchPageFoundState extends SearchPageState {
  SearchPageFoundState({required landmarks}) : super(landmarks: landmarks);
}
