import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  // Future<List<Map<String, dynamic>>> fetchParts() async {
  //   final snap = await colLessons.get();
  //   final data = snap.value;
  //   if (data == null) return [];
  //
  //   if (data is Map && data.containsKey(kdbParts)) {
  //     return _toNodeList(data[kdbParts]);
  //   }
  //   return _toNodeList(data);
  // }
  //
  // Future<List<Map<String, dynamic>>> fetchLesson(String partId,) async {
  //   final snap = await colLessons.child('$partId/$kdbLessons').get();
  //   return _toNodeList(snap.value);
  // }
  //
  // Future<List<Map<String, dynamic>>> fetchQuestion(
  //   String partId,
  //   String lessonChildId,
  // ) async {
  //   final snap = await colLessons
  //       .child('$partId/$kdbLessons/$lessonChildId/$kdbQuestions')
  //       .get();
  //   return _toNodeList(snap.value);
  // }
  //
  // List<Map<String, dynamic>> _toNodeList(dynamic data) {
  //   if (data == null) return [];
  //
  //   if (data is Map) {
  //     return data.entries
  //         .where((entry) => entry.value is Map)
  //         .map((entry) {
  //           final item = Map<String, dynamic>.from(entry.value as Map);
  //           return {kdbId: entry.key.toString(), ...item};
  //         })
  //         .toList();
  //   }
  //
  //   if (data is List) {
  //     return data.asMap().entries
  //         .where((entry) => entry.value is Map)
  //         .map((entry) {
  //           final item = Map<String, dynamic>.from(entry.value as Map);
  //           return {kdbId: entry.key.toString(), ...item};
  //         })
  //         .toList();
  //   }
  //
  //   return [];
  // }

  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  // List<T> _mapToList<T>({
  //   required dynamic data,
  //   required T Function(Map<String, dynamic>, String id) fromJson,
  // }) {
  //   if (data == null) return [];
  //   if (data is Map) {
  //     return data.entries
  //         .where((e) => e.value is Map)
  //         .map((e) => fromJson(
  //       Map<String, dynamic>.from(e.value as Map),
  //       e.key.toString(),
  //     ))
  //         .toList();
  //   }
  //   if (data is List) {
  //     return data.asMap().entries
  //         .where((e) => e.value is Map)
  //         .map((e) {
  //       final map = Map<String, dynamic>.from(e.value as Map);
  //       return fromJson(map, e.key.toString());
  //     })
  //         .toList();
  //   }
  //   return [];
  // }

  Future<List<T>> getList<T>({
    required String path,
    required T Function(Map<String, dynamic>, String id) fromJson,
  }) async {
    final snapshot = await _db.child(path).get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final data = snapshot.value;

    // ✅ Trường hợp Map
    if (data is Map) {
      return data.entries
          .where((e) => e.value is Map)
          .map(
            (e) => fromJson(
              Map<String, dynamic>.from(e.value as Map),
              e.key.toString(),
            ),
          )
          .toList();
    }

    // ✅ Trường hợp List
    if (data is List) {
      return data
          .asMap()
          .entries
          .where((e) => e.value is Map)
          .map(
            (e) => fromJson(
              Map<String, dynamic>.from(e.value as Map),
              e.key.toString(),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<T?> getItem<T>({
    required String path,
    required T Function(Map<String, dynamic>, String id) fromJson,
  }) async {
    final snapshot = await _db.child(path).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    final data = snapshot.value;
    if (data is Map) {
      return fromJson(Map<String, dynamic>.from(data), snapshot.key ?? '');
    }
    return null;
  }
}
