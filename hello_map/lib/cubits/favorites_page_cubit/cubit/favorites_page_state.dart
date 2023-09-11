part of 'favorites_page_cubit.dart';

@immutable
sealed class FavoritesPageState {
  final List<Landmark> landmarkList;
  const FavoritesPageState({required this.landmarkList});
}

final class FavoritesPageInitial extends FavoritesPageState {
  FavoritesPageInitial() : super(landmarkList: []);
}

final class FavoritesPageWithItems extends FavoritesPageState {
  const FavoritesPageWithItems({required List<Landmark> landmarks}) : super(landmarkList: landmarks);
}
