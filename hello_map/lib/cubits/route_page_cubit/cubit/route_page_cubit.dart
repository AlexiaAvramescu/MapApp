import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'route_page_state.dart';

class RoutePageCubit extends Cubit<RoutePageState> {
  RoutePageCubit() : super(RoutePageInitial());
}
