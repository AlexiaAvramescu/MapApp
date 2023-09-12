import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_map/cubits/favorites_page_cubit/cubit/favorites_page_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Favorites list"),
        backgroundColor: Colors.deepPurple[900],
      ),
      body: BlocBuilder<FavoritesPageCubit, FavoritesPageState>(
        builder: (context, state) {
          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: state.landmarkList.length,
            controller: ScrollController(),
            itemBuilder: (context, index) {
              final lmk = state.landmarkList[index];
              return FavoritesItem(
                landmark: lmk,
              );
            },
          );
        },
      ),
    );
  }
}

class FavoritesItem extends StatefulWidget {
  final bool isLast;
  final Landmark landmark;

  const FavoritesItem({super.key, this.isLast = false, required this.landmark});

  @override
  State<FavoritesItem> createState() => _FavoritesItemState();
}

class _FavoritesItemState extends State<FavoritesItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pop(widget.landmark);
          await context.read<FavoritesPageCubit>().onCenterCoordinates(widget.landmark.getCoordinates());
        },
        child: Column(
          children: [
            Row(
              children: [
                FutureBuilder<Uint8List?>(
                    future: context.read<FavoritesPageCubit>().decodeLandmarkIcon(widget.landmark),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done || snapshot.data == null) {
                        return Container();
                      }
                      return Container(
                        padding: const EdgeInsets.all(8),
                        width: 50,
                        child: Image.memory(snapshot.data!),
                      );
                    }),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          widget.landmark.getName(),
                          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 3),
                            child: Text(
                              widget.landmark.getCategories().isNotEmpty
                                  ? widget.landmark.getCategories().elementAt(0).name ?? ' '
                                  : ' ',
                              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                          ),
                          FutureBuilder<Coordinates>(
                            future: context.read<FavoritesPageCubit>().getCoordinates(widget.landmark),
                            builder: (context, snapshot) {
                              Coordinates coords;
                              String textCoords = '';

                              if (snapshot.hasData) {
                                coords = snapshot.data!;
                                textCoords = "${coords.latitude}, ${coords.longitude}";
                              }

                              return SizedBox(
                                width: MediaQuery.of(context).size.width - 210,
                                child: Text(
                                  textCoords,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
                                ),
                              );
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.north_west_outlined,
                        color: Colors.grey,
                      )),
                )
              ],
            ),
            if (!widget.isLast)
              const Divider(
                color: Colors.grey,
                indent: 10,
                endIndent: 20,
              )
          ],
        ),
      ),
    );
  }
}
