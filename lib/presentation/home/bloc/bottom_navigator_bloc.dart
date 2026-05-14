import 'package:bloc/bloc.dart';

part 'bottom_navigator_event.dart';
part 'bottom_navigator_state.dart';

class BottomNavigatorBloc
    extends Bloc<BottomNavigatorEvent, BottomNavigatorState> {
  BottomNavigatorBloc() : super(BottomNavigatorState(0)) {
    on<ChangeTabEvent>(_onPress);
  }

  void _onPress(ChangeTabEvent event, Emitter<BottomNavigatorState> emit) {
    emit(BottomNavigatorState(event.index));
  }
}
