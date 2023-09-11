import 'package:gem_kit/gem_kit_map_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:hello_map/repositories/repository.dart';
import 'package:hello_map/repository_impl/repository_impl.dart';

class Controller {
  static final sl = GetIt.instance;

  static void initialize(GemMapController mapController) {
    sl.registerLazySingleton<Repository>(() => RepositoryImpl(mapController: mapController));
  }
}
