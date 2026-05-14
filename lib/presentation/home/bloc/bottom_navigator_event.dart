part of 'bottom_navigator_bloc.dart';

sealed class BottomNavigatorEvent {}

class ChangeTabEvent extends BottomNavigatorEvent {
  final int index;
  ChangeTabEvent(this.index);
}
