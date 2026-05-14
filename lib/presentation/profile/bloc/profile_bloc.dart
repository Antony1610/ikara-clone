import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/data/repositories/auth_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState>{
  final AuthRepository _repository;
  final UserRepository _userRepository;
  ProfileBloc(this._repository, this._userRepository) : super(ProfileInitial()) {
    on<ProfileImagePicked>(_onProfileImagePicker);
    on<ProfileSaved>(_onProfileSaved);
  }

  Future<void> _onProfileImagePicker(ProfileImagePicked event, Emitter emit) async {
    try {
      emit(ProfileLoading());
      final uid = _repository.currentUser?.id;
      if (uid == null) {
        emit(ProfileError('Không tìm thấy người dùng'));
        return;
      }
      final imageUrl = await _userRepository.uploadAvatar(uid, event.image);
      final user = _repository.currentUser!;
      await _userRepository.updateUser(user.copyWith(image: imageUrl));
      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onProfileSaved(ProfileSaved event, Emitter emit) async {
    try {
      emit(ProfileLoading());
      final user = _repository.currentUser;
      if (user == null) {
        emit(ProfileError('Không tìm thấy người dùng'));
        return;
      }
      if (event.name != user.name && !user.canChangeName) {
        emit(ProfileError('Bạn chỉ có thể đổi tên sau 30 ngày kể từ lần gần nhất'));
        return;
      }

      final updateUser = user.copyWith(
        name: event.name,
        status: event.status.isEmpty ? null : event.status,
        lastNameChangedAt: event.name != user.name ? DateTime.now() : user.lastNameChangedAt
      );
      await _userRepository.updateUser(updateUser);
      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}