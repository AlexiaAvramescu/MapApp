import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_sdksettings.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:gem_kit/widget/gem_kit_map.dart';
import 'package:hello_map/controller.dart';
import 'package:hello_map/cubits/favorites_page_cubit/cubit/favorites_page_cubit.dart';
import 'package:hello_map/cubits/main_page_cubit/main_page_cubit.dart';
import 'package:hello_map/cubits/search_page_cubit/cubit/search_page_cubit.dart';
import 'package:hello_map/landmark_panel.dart';
import 'package:hello_map/pages/favorites_page.dart';
import 'package:hello_map/pages/route_page.dart';
import 'package:hello_map/pages/search_page.dart';
import 'package:hello_map/landmark_info.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late GemMapController mapController;

  final _token =
      'eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIzYzU4MjE3MC03Y2M0LTRlOWItYjBhNi1kMmFiOTdhNmVlZGMiLCJleHAiOjE4MjU4ODQwMDAsImlzcyI6IkdlbmVyYWwgTWFnaWMiLCJqdGkiOiJmNmI2NzRkOC02YTEwLTQyMmEtYmFmYi0zNmQzYzFhNGNiM2IiLCJuYmYiOjE2OTQ1OTE5NDV9.lBjeLX3XcEhEXpRk1j0LO6YFE85eDeht9fNXMlhGQ0zfGe2I3zgA1Z_QXvKSASFGBfR3nqkS8UBjZQwVchURvQ';

  @override
  void initState() {
    super.initState();
  }

  Future<void> onMapCreated(GemMapController controller) async {
    mapController = controller;
    Controller.initialize(mapController);
    SdkSettings.setAppAuthorization(_token);

    context.read<FavoritesPageCubit>().setRepo();
    context.read<MainPageCubit>().setRepo();
    context.read<SearchPageCubit>().setRepo();

    mapController.registerTouchCallback((pos) async {
      context.read<MainPageCubit>().registerLandmarkTapCallback(pos);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            GemMap(
              onMapCreated: onMapCreated,
            ),
            _searchBar(context),
            _routesButton(context),
            _centerOnPositionButton(),
            _favoritesButton(),
            BlocBuilder<MainPageCubit, MainPageState>(
              builder: (context, state) {
                if (state.focusedLandmark != null) {
                  return Positioned(
                    bottom: 30,
                    left: 10,
                    child: FutureBuilder<LandmarkInfo>(
                        future: context.read<MainPageCubit>().getInfo(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          return LandmarkPanel(
                            onCancelTap: () => context.read<MainPageCubit>().onCancelLandmarkPanel(),
                            onFavoritesTap: () => context.read<MainPageCubit>().onFavoritesTap(),
                            onRouteTap: () => 0, //context.read<MainPage>(). ,
                            isFavoriteLandmark: state.isLandmarkFavorite,
                            coords: snapshot.data!.formattedCoords,
                            category: snapshot.data!.categoryName,
                            img: snapshot.data!.image!,
                            name: snapshot.data!.name,
                          );
                        }),
                  );
                } else {
                  return Container();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Align _routesButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, top: 60),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 81, 138, 185),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RoutePage()));
              },
              iconSize: 30,
              icon: const Icon(
                Icons.directions,
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  Align _favoritesButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 81, 138, 185),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
              onPressed: () async {
                final result =
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesPage()));
                if (result is! Landmark) return;
                await context.read<MainPageCubit>().centerOnLandmark(result);
              },
              iconSize: 30,
              icon: const Icon(
                Icons.favorite_border,
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  Align _centerOnPositionButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 30),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 81, 138, 185),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
              onPressed: () {
                context.read<MainPageCubit>().onFollowPositionButtonPressed();
              },
              iconSize: 30,
              icon: const Icon(
                CupertinoIcons.location,
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  Container _searchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60, left: 20, right: 80),
      decoration: const BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color.fromARGB(255, 134, 134, 134),
          blurRadius: 40,
          spreadRadius: 0,
        ),
      ]),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
        }, //move to search page
        child: TextField(
          enabled: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(15),
            hintText: 'Search location',
            hintStyle: const TextStyle(
              color: Color.fromARGB(255, 160, 160, 160),
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.search_rounded),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
