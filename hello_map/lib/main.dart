import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hello_map/cubits/favorites_page_cubit/cubit/favorites_page_cubit.dart';
import 'package:hello_map/cubits/main_page_cubit/main_page_cubit.dart';
import 'package:hello_map/cubits/search_page_cubit/cubit/search_page_cubit.dart';
import 'package:hello_map/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainPageCubit>(create: (context) => MainPageCubit()),
        BlocProvider<SearchPageCubit>(create: (context) => SearchPageCubit()),
        BlocProvider<FavoritesPageCubit>(create: (context) => FavoritesPageCubit()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hello Map',
        home: MainPage(),
      ),
    );
  }
}
