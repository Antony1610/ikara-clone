import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String id;
  final String name;
  final DateTime? birthDay;
  final int? gender;
  final String? email;
  final String? phone;
  final String? country;
  final String? image;
  final DateTime? deletedAt;
  final String? status;
  final String? voiceRange;
  final DateTime? lastNameChangedAt;

  const AppUser({
    required this.id,
    required this.name,
    this.birthDay,
    this.gender,
    this.email,
    this.phone,
    this.country,
    this.image,
    this.deletedAt,
    this.status,
    this.voiceRange,
    this.lastNameChangedAt,
  });

  bool get isPendingDeletion {
    if (deletedAt == null) return false;
    return DateTime.now().difference(deletedAt!).inDays < 30;
  }

  bool get canChangeName {
    if (lastNameChangedAt == null) return true;
    return DateTime.now().difference(lastNameChangedAt!).inDays >= 30;
  }

  factory AppUser.fromJson(String id, Map<String, dynamic> json) {
    return AppUser(
      id: id,
      name: json["name"] ?? "",
      birthDay: json["birthDay"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["birthDay"] as int)
          : null,
      gender: json["gender"],
      email: json["email"],
      phone: json["phone"],
      country: json["country"],
      image: json["image"],
      deletedAt: json["deletedAt"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["deletedAt"] as int)
          : null,
      status: json["status"],
      voiceRange: json["voiceRange"],
      lastNameChangedAt: json["lastNameChangedAt"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["lastNameChangedAt"] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "birthDay": birthDay?.millisecondsSinceEpoch,
      "gender": gender,
      "email": email,
      "phone": phone,
      "country": country,
      "image": image,
      "deletedAt": deletedAt?.millisecondsSinceEpoch,
      "status": status,
      "voiceRange": voiceRange,
      "lastNameChangedAt": lastNameChangedAt?.millisecondsSinceEpoch,
    };
  }

  AppUser copyWith({
    String? name,
    DateTime? birthDay,
    int? gender,
    String? email,
    String? phone,
    String? country,
    String? image,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    String? status,
    String? voiceRange,
    DateTime? lastNameChangedAt,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      birthDay: birthDay ?? this.birthDay,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      image: image ?? this.image,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      status: status ?? this.status,
      voiceRange: voiceRange ?? this.voiceRange,
      lastNameChangedAt: lastNameChangedAt ?? this.lastNameChangedAt,
    );
  }

  factory AppUser.fromFirebase(User user) {
    return AppUser(
      id: user.uid,
      name: user.displayName ?? "",
      email: user.email,
      phone: user.phoneNumber,
      image: user.photoURL,
      status: null,
      voiceRange: null,
      lastNameChangedAt: null,
    );
  }
}