part of 'profile_bloc.dart';

sealed class ProfileEvent {}

class ProfileImagePicked extends ProfileEvent {
  final File image;
  ProfileImagePicked(this.image);
}

class ProfileSaved extends ProfileEvent {
  final String name;
  final String status;
  ProfileSaved(this.name, this.status);
}