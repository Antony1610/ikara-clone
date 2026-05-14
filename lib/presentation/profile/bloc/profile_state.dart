part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileImageUpdate extends ProfileState {
  final File image;
  const ProfileImageUpdate(this.image);
  @override
  List<Object> get props => [image];
}

class ProfileSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

