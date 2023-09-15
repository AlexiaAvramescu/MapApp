import 'dart:async';
import 'dart:ffi';

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gem_kit/api/gem_addressinfo.dart';
import 'package:gem_kit/api/gem_coordinates.dart';
import 'package:gem_kit/api/gem_geographicarea.dart';
import 'package:gem_kit/api/gem_landmark.dart';
import 'package:gem_kit/api/gem_landmarkstore.dart';
import 'package:gem_kit/api/gem_landmarkstoreservice.dart';
import 'package:gem_kit/api/gem_mapviewpreferences.dart';
import 'package:gem_kit/api/gem_mapviewrendersettings.dart';
import 'package:gem_kit/api/gem_navigationservice.dart';
import 'package:gem_kit/api/gem_progresslistener.dart';
import 'package:gem_kit/api/gem_routingpreferences.dart';
import 'package:gem_kit/api/gem_routingservice.dart';
import 'package:gem_kit/api/gem_searchpreferences.dart';
import 'package:gem_kit/api/gem_types.dart';
import 'package:gem_kit/gem_kit_basic.dart';
import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:gem_kit/gem_kit_position.dart';
import 'package:hello_map/instruction_model.dart';
import 'package:hello_map/landmark_info.dart';
import 'package:hello_map/repositories/repository.dart';
import 'package:gem_kit/api/gem_searchservice.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gem_kit/api/gem_routingservice.dart' as gem;
import 'dart:ui' as ui;

import 'package:hello_map/utility.dart';

class RepositoryImpl implements Repository {
  final GemMapController _mapController;

  late SearchService _gemSearchService;
  ProgressListener? _searchProgress;

  LandmarkStoreService? _landmarkStoreService;
  LandmarkStore? _favoritesStore;
  final List<Landmark> _favorites = [];
  VoidCallback? _updateFavoritesListCallBack;

  late PermissionStatus _locationPermissionStatus = PermissionStatus.denied;
  late PositionService? _positionService;
  late bool? _hasLiveDataSource = false;
  Coordinates? _currentPosition;

  late gem.RoutingService _routingService;
  final List<gem.Route> _shownRoutes = [];

  NavigationService? _navigationService;

  late Completer<List<Landmark>> completer;

  @override
  set favoritesUpdateCallBack(VoidCallback function) => _updateFavoritesListCallBack = function;

  RepositoryImpl({required GemMapController mapController}) : _mapController = mapController {
    SearchService.create(_mapController.mapId).then((service) => _gemSearchService = service);
  }

  @override
  void updateFavoritesPageList() => _updateFavoritesListCallBack!();

  @override
  Future<void> initializeServices() async {
    _navigationService = await NavigationService.create(_mapController.mapId);
    _routingService = await gem.RoutingService.create(_mapController.mapId);
    _positionService = await PositionService.create(_mapController.mapId);

    LandmarkStoreService.create(_mapController.mapId).then((service) {
      _landmarkStoreService = service;

      String favoritesStoreName = 'Favorites';

      _landmarkStoreService!.getLandmarkStoreByName(favoritesStoreName).then((value) async {
        value ??= await _landmarkStoreService!.createLandmarkStore(favoritesStoreName);
        _favoritesStore = value;

        final landmarkList = await _favoritesStore!.getLandmarks();
        final size = await landmarkList.size();

        for (int i = 0; i < size; i++) {
          _favorites.add(await landmarkList.at(i));
        }
        _updateFavoritesListCallBack!();
      });
    });
  }

  @override
  Coordinates transformScreenToWgs(double x, double y) =>
      _mapController.transformScreenToWgs(XyType(x: x.toInt(), y: y.toInt()))!;

  @override
  Future<List<Landmark>> search(String text, Coordinates coordinates,
      {SearchPreferences? preferences, RectangleGeographicArea? geographicArea}) async {
    completer = Completer<List<Landmark>>();

    //if (searchProgress != null) await gemSearchService.cancelSearch(searchProgress!);

    _searchProgress = await _gemSearchService.search(text, coordinates, (err, results) async {
      if (err != GemError.success || results == null) {
        completer.complete([]);
        return;
      }

      final size = await results.size();
      List<Landmark> searchResults = [];

      for (int i = 0; i < size; i++) {
        final gemLmk = await results.at(i);

        searchResults.add(gemLmk);
      }

      if (!completer.isCompleted) completer.complete(searchResults);
    });

    return await completer.future;
  }

  @override
  Future<Uint8List?> decodeLandmarkIcon(Landmark landmark) {
    final data = landmark.getImage(100, 100);
    Completer<Uint8List?> c = Completer<Uint8List?>();

    int width = 100;
    int height = 100;

    ui.decodeImageFromPixels(data, width, height, ui.PixelFormat.rgba8888, (ui.Image img) async {
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        c.complete(null);
      }
      final list = data!.buffer.asUint8List();
      c.complete(list);
    });

    return c.future;
  }

  @override
  Future<String> getAddressFromLandmark(Landmark landmark) async {
    final addressInfo = landmark.getAddress();
    final street = addressInfo.getField(EAddressField.StreetName);
    final city = addressInfo.getField(EAddressField.City);
    final country = addressInfo.getField(EAddressField.Country);

    return '$street $city $country';
  }

  @override
  Future<void> centerOnCoordinates(Coordinates coordinates) async {
    final animation = GemAnimation(type: EAnimation.AnimationLinear);

    // Use the map controller to center on coordinates
    await _mapController.centerOnCoordinates(
      coordinates,
      animation: animation,
      viewAngle: 0,
      xy: XyType(x: _mapController.viewport.width ~/ 2, y: _mapController.viewport.height ~/ 2),
    );
  }

  @override
  Future<LandmarkInfo> getLandmarkInfo(Landmark focusedLandmark) async {
    late Uint8List? iconFuture;
    late String name;
    late Coordinates coords;
    late String coordsText;
    late List<LandmarkCategory> categories;

    iconFuture = await _decodeLandmarkIcon(focusedLandmark);
    name = focusedLandmark.getName();
    coords = focusedLandmark.getCoordinates();
    coordsText = "${coords.latitude.toString()}, ${coords.longitude.toString()}";
    categories = focusedLandmark.getCategories();

    return LandmarkInfo(
        image: iconFuture,
        name: name,
        categoryName: categories.isNotEmpty ? categories.first.name! : '',
        formattedCoords: coordsText);
  }

  Future<Uint8List?> _decodeLandmarkIcon(Landmark landmark) {
    final data = landmark.getImage(100, 100);

    return decodeImageData(data);
  }

  @override
  void deactivateAllHighlights() => _mapController.deactivateAllHighlights();

  @override
  Future<bool> checkIfFavourite({required Landmark focusedLandmark}) async {
    final focusedLandmarkCoords = focusedLandmark.getCoordinates();
    final favourites = await _favoritesStore!.getLandmarks();
    final favoritesSize = await favourites.size();

    for (int i = 0; i < favoritesSize; i++) {
      final lmk = await favourites.at(i);
      final coords = lmk.getCoordinates();

      if (focusedLandmarkCoords.latitude == coords.latitude && focusedLandmarkCoords.longitude == coords.longitude) {
        return true;
      }
    }

    return false;
  }

  bool isSameLandmark(Landmark a, Landmark b) {
    return a.getCoordinates().latitude == b.getCoordinates().latitude &&
        a.getCoordinates().longitude == b.getCoordinates().longitude;
  }

  @override
  Future<bool> onFavoritesTap({required bool isLandmarkFavorite, required Landmark focusedLandmark}) async {
    if (isLandmarkFavorite) {
      await _favoritesStore!.removeLandmark(focusedLandmark);
      _favorites.removeWhere((element) => isSameLandmark(element, focusedLandmark));
    } else {
      await _favoritesStore!.addLandmark(focusedLandmark);
      _favorites.add(focusedLandmark);
    }
    return !isLandmarkFavorite;
  }

  @override
  Future<Landmark?> registerTapCallback(Point<num> pos) async {
    // Select the object at the tap position.
    await _mapController.selectMapObjects(pos);

    // Get the selected landmarks.
    final landmarks = await _mapController.cursorSelectionLandmarks();
    final landmarksSize = await landmarks.size();

    // Check if there is a selected Landmark.
    if (landmarksSize == 0) {
      final routes = await _mapController.cursorSelectionRoutes();
      final routesSize = await routes.size();

      if (routesSize == 0) return null;

      final route = await routes.at(0);
      final prefs = _mapController.preferences();
      final routesMap = await prefs.routes();
      routesMap.setMainRoute(route);

      return null;
    }
    // Highlight the landmark on the map.
    await _mapController.activateHighlight(landmarks);

    final lmk = await landmarks.at(0);

    return lmk;
  }

  @override
  List<Landmark> getFavorites() => _favorites;

  @override
  Future<void> centerOnLandmark(Landmark landmark) async {
    LandmarkList landmarks = await LandmarkList.create(_mapController.mapId);
    await landmarks.push_back(landmark);
    await _mapController.activateHighlight(landmarks, renderSettings: RenderSettings());
  }

  Future<void> getLocationPermission() async {
    if (kIsWeb) {
      // On web platform permission are handled differently than other platforms.
      // The SDK handles the request of permission for location
      _locationPermissionStatus = PermissionStatus.granted;
    } else {
      // For Android & iOS platforms, permission_handler package is used to ask for permissions
      _locationPermissionStatus = await Permission.locationWhenInUse.request();
    }

    if (_locationPermissionStatus != PermissionStatus.granted) {
      return;
    }

    // After the permission was granted, we can set the live data source (in most cases the GPS)
    // The data source should be set only once, otherwise we'll get -5 error
    if (!_hasLiveDataSource!) {
      await _positionService!.removeDataSource();
      await _positionService!.setLiveDataSource();
      _hasLiveDataSource = true;

      Completer<Coordinates> completer = Completer<Coordinates>();

      await _positionService!.addPositionListener((p0) {
        if (!completer.isCompleted) completer.complete(p0.coordinates);
      });

      _currentPosition = await completer.future;
    }
  }

  @override
  Future<void> onFollowPositionButtonPressed(void Function(Coordinates) mapUpdateCallback) async {
    getLocationPermission();
    // After data source is set, startFollowingPosition can be safely called
    if (_locationPermissionStatus == PermissionStatus.granted) {
      // Optionally, we can set an animation
      final animation = GemAnimation(type: EAnimation.AnimationLinear);

      _mapController.startFollowingPosition(animation: animation);
    }
  }

  removeRoutes(List<gem.Route> routes) async {
    final prefs = _mapController.preferences();
    final routesMap = await prefs.routes();

    for (final route in routes) {
      routesMap.remove(route);
    }
  }

  @override
  Future<void> calculateRoute(Landmark destiantion) async {
    await removeRoutes(_shownRoutes);

    await getLocationPermission();

    // Create a landmark list
    final landmarkWaypoints = await gem.LandmarkList.create(_mapController.mapId);

    // add currernt pos
    var landmark = Landmark.create();
    await landmark
        .setCoordinates(Coordinates(latitude: _currentPosition!.latitude, longitude: _currentPosition!.longitude));
    landmarkWaypoints.push_back(landmark);

    // add destination
    landmarkWaypoints.push_back(destiantion);

    final routePreferences = RoutePreferences();

    await _routingService.calculateRoute(landmarkWaypoints, routePreferences, (err, routes) async {
      if (err != GemError.success || routes == null) {
        return;
      } else {
        // Get the controller's preferences
        final mapViewPreferences = _mapController.preferences();
        // Get the routes from the preferences
        final routesMap = await mapViewPreferences.routes();
        //Get the number of routes
        final routesSize = await routes.size();

        for (int i = 0; i < routesSize; i++) {
          final route = await routes.at(i);
          _shownRoutes.add(route);

          final timeDistance = await route.getTimeDistance();

          final totalDistance = convertDistance(timeDistance.unrestrictedDistanceM + timeDistance.restrictedDistanceM);

          final totalTime = convertDuration(timeDistance.unrestrictedTimeS + timeDistance.restrictedTimeS);
          // Add labels to the routes
          await routesMap.add(route, i == 0, label: '$totalDistance \n $totalTime');
        }
        // Select the first route as the main one
        final mainRoute = await routes.at(0);

        await _mapController.centerOnRoute(mainRoute);
      }
    });
  }

  _navigateOnRoute({required gem.Route route, required Function(InstructionModel) onInstructionUpdated}) async {
    await _navigationService!.startSimulation(route, (type, instruction) async {
      if (type != NavigationEventType.navigationInstructionUpdate || instruction == null) {
        //is nav = false
        removeRoutes(_shownRoutes);
        return;
      }

      // isNavigating set to true

      final ins = await InstructionModel.fromGemInstruction(instruction);
      onInstructionUpdated(ins);

      instruction.dispose();
    });
  }

  @override
  Future<void> startSimulation({required void Function(InstructionModel) updateInstructionCallBack}) async {
    final prefs = _mapController.preferences();
    final routesMap = await prefs.routes();
    await _navigateOnRoute(
        route: await routesMap.getMainRoute(),
        onInstructionUpdated: (instruction) {
          updateInstructionCallBack(instruction);
        });

    _mapController.startFollowingPosition(animation: GemAnimation(duration: 200, type: EAnimation.AnimationLinear));
  }
}
