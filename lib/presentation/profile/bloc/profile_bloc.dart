import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:ikara_clone/data/repositories/auth_repository.dart';
import 'package:ikara_clone/data/repositories/user_repository.dart';

import '../../../base/blocs/auth/auth_bloc.dart';
part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState>{
  final AuthRepository _repository;
  final UserRepository _userRepository;
  final AuthBloc _authBloc;
  ProfileBloc(this._repository, this._userRepository, this._authBloc) : super(ProfileInitial()) {
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
      final updatedUser = user.copyWith(image: imageUrl);
      await _userRepository.updateUser(updatedUser);
      _authBloc.add(AuthUserUpdate(updatedUser));
      emit(ProfileImageUpdate(event.image));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onProfileSaved(ProfileSaved event, Emitter emit) async {
    try {
      emit(ProfileLoading());
      final uid = _repository.currentUser?.id;
      if (uid == null) {
        emit(ProfileError('Không tìm thấy người dùng'));
        return;
      }

      final user = await _userRepository.getUser(uid);
      if (user == null) {
        emit(ProfileError('Không tìm thấy người dùng'));
        return;
      }

      if (event.name != user.name && !user.canChangeName) {
        emit(ProfileError('Bạn chỉ có thể đổi tên sau 30 ngày kể từ lần gần nhất'));
        return;
      }

      final updatedUser = user.copyWith(
        name: event.name,
        status: event.status.isEmpty ? null : event.status,
        lastNameChangedAt: event.name != user.name
            ? DateTime.now()
            : user.lastNameChangedAt,
      );

      // Lưu Firebase trước, sau đó mới update AuthBloc
      await _userRepository.updateUser(updatedUser);
      _authBloc.add(AuthUserUpdate(updatedUser));
      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}