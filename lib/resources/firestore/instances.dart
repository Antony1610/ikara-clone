import 'package:firebase_database/firebase_database.dart';
import 'api_endpoint.dart';
final _db = FirebaseDatabase.instance.ref();

DatabaseReference get colBreaths => _db.child(kdbBreaths);
DatabaseReference get colLessons => _db.child(kdbLessons);
DatabaseReference get colRhythms => _db.child(kdbRhythms);
DatabaseReference get colPratices => _db.child(kdbPractices);
DatabaseReference get colPerformances => _db.child(kdbPerformances);
DatabaseReference get colSetting => _db.child(kdbSetting);
DatabaseReference get colUsers => _db.child(kdbUsers);