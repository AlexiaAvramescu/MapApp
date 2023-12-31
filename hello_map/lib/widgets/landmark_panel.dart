import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LandmarkPanel extends StatelessWidget {
  final VoidCallback onCancelTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onRouteTap;
  final String name;
  final Uint8List img;
  final String coords;
  final String category;
  final bool isFavoriteLandmark;

  const LandmarkPanel(
      {super.key,
      required this.onCancelTap,
      required this.onFavoritesTap,
      required this.onRouteTap,
      required this.name,
      required this.img,
      required this.coords,
      required this.category,
      required this.isFavoriteLandmark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      height: MediaQuery.of(context).size.height * 0.2,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Image.memory(
              img,
              gaplessPlayback: true,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width - 150,
                child: Row(children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          category,
                          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          coords,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        padding: EdgeInsets.only(right: 10),
                        onPressed: onCancelTap,
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.only(top: 1),
                      onPressed: onFavoritesTap,
                      icon: Icon(
                        isFavoriteLandmark ? Icons.favorite : Icons.favorite_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.only(top: 1),
                      onPressed: onRouteTap,
                      icon: const Icon(
                        Icons.directions,
                        color: Colors.red,
                        size: 40,
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
