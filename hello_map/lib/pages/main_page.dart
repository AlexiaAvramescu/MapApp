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
import 'package:hello_map/widgets/landmark_panel.dart';
import 'package:hello_map/pages/favorites_page.dart';
import 'package:hello_map/pages/route_page.dart';
import 'package:hello_map/landmark_info.dart';
import 'package:hello_map/widgets/search_bar.dart';
import 'package:hello_map/widgets/top_navigation_panel.dart';

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
      await context.read<MainPageCubit>().registerTapCallback(pos);
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
            const CustomSearchBar(),
            Align(
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
            ),
            BlocBuilder<MainPageCubit, MainPageState>(builder: (context, state) {
              if (state.hasRoutes) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: IconButton(
                        onPressed: () {
                          //context.read<MainPageCubit>().startSimulation();
                        },
                        iconSize: 50,
                        icon: const Icon(
                          Icons.directions,
                          color: Colors.red,
                        )),
                  ),
                );
              }
              return Container();
            }),
            BlocBuilder<MainPageCubit, MainPageState>(builder: (context, state) {
              if (state.isNavigating) {
                return Positioned(
                  top: 40,
                  left: 10,
                  child: NavigationInstructionPanel(
                    instruction: state.currentInstruction!,
                  ),
                );
              }
              return Container();
            }),
            Align(
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
            ),
            Align(
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
                        final result = await Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const FavoritesPage()));
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
            ),
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
                            onRouteTap: () => context.read<MainPageCubit>().onRouteTap(),
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
}
