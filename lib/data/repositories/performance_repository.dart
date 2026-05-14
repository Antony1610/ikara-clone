import 'package:ikara_clone/data/model/model.dart';

abstract class PerformanceRepository {
  Future<List<PerformanceLesson>> getListPerformance();
  Future<PerformanceLesson> getDetailPerformance(String id);
}
