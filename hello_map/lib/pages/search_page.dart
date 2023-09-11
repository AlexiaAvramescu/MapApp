import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:hello_map/cubits/search_page_cubit/cubit/search_page_cubit.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 70, left: 30, right: 20),
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 134, 134, 134),
                blurRadius: 40,
                spreadRadius: 0,
              ),
            ]),
            child: GestureDetector(
              onTap: () {
                if (!Navigator.of(context).canPop()) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                }
              }, //move to search page
              child: TextField(
                onSubmitted: (text) {
                  final x = MediaQuery.of(context).size.width / 2;
                  final y = MediaQuery.of(context).size.height / 2;
                  final coordinates = context.read<SearchPageCubit>().getRelevantCoordinates(x, y);
                  context.read<SearchPageCubit>().onSubmited(text, coordinates);
                },
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
          ),
          BlocBuilder<SearchPageCubit, SearchPageState>(
            builder: (context, state) {
              if (state is SearchPageLoadingState) {
                return Icon(Icons.refresh_outlined);
              } else if (state is SearchPageNoResultState) {
                return const Text('No result found');
              } else if (state is SearchPageFoundState) {
                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: state.landmarks.length,
                    controller: ScrollController(),
                    itemBuilder: (context, index) {
                      final lmk = state.landmarks.elementAt(index);
                      return SearchResultItem(
                        landmark: lmk,
                      );
                    },
                  ),
                );
              } else
                return Container();
            },
          )
        ],
      ),
    );
  }
}

class SearchResultItem extends StatefulWidget {
  final bool isLast;
  final Landmark landmark;

  const SearchResultItem({super.key, required this.landmark, this.isLast = false});

  @override
  State<SearchResultItem> createState() => _SearchResultItemState();
}

class _SearchResultItemState extends State<SearchResultItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: InkWell(
        onTap: () async {
          Navigator.of(context).pop(widget.landmark);
          await context.read<SearchPageCubit>().onCenterCoordinates(widget.landmark.getCoordinates());
        },
        child: Column(
          children: [
            Row(
              children: [
                FutureBuilder<Uint8List?>(
                    future: context.read<SearchPageCubit>().decodeLandmarkIcon(widget.landmark),
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
                            child: Builder(
                              builder: (context) {
                                String formattedDistance = '';

                                final extraInfo = widget.landmark.getExtraInfo();
                                double distance = (extraInfo.getByKey(PredefinedExtraInfoKey.gmSearchResultDistance) /
                                    1000) as double;
                                formattedDistance = "${distance.toStringAsFixed(0)}km";

                                return Text(formattedDistance);
                              },
                            ),
                          ),
                          FutureBuilder<String>(
                            future: context.read<SearchPageCubit>().getAddress(widget.landmark),
                            builder: (context, snapshot) {
                              String address = '';

                              if (snapshot.hasData) {
                                address = snapshot.data!;
                              }

                              return SizedBox(
                                width: MediaQuery.of(context).size.width - 210,
                                child: Text(
                                  address,
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
                      onPressed: () async =>
                          await context.read<SearchPageCubit>().onCenterCoordinates(widget.landmark.getCoordinates()),
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
