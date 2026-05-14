import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class AppBlocObserver extends BlocObserver {
  // Lưu thời gian log gần nhất cho mỗi loại event
  final Map<String, DateTime> _lastEventLog = {};
  final Map<String, DateTime> _lastChangeLog = {};

  // Các event được coi là "spam" - chỉ log 1 lần mỗi N giây
  static const _throttledEvents = {
    'VideoPositionChanged',
    'UpdateTick',
  };

  static const _throttleDuration = Duration(seconds: 3);

  bool _shouldLog(String key, Map<String, DateTime> cache) {
    final now = DateTime.now();
    final last = cache[key];
    if (last == null || now.difference(last) > _throttleDuration) {
      cache[key] = now;
      return true;
    }
    return false;
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    final eventType = event.runtimeType.toString();
    final isThrottled = _throttledEvents.contains(eventType);

    if (!isThrottled || _shouldLog('${bloc.runtimeType}_$eventType', _lastEventLog)) {
      final suffix = isThrottled ? ' [throttled - chỉ log mỗi ${_throttleDuration.inSeconds}s]' : '';
      debugPrint('[BlocObserver] ${bloc.runtimeType} Event: $event$suffix');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    final eventType = change.nextState.runtimeType.toString();
    // Throttle change log nếu bloc đang xử lý event spam
    final isThrottled = _throttledEvents.any(
          (e) => _lastEventLog.containsKey('${bloc.runtimeType}_$e'),
    );

    if (!isThrottled || _shouldLog('${bloc.runtimeType}_change_$eventType', _lastChangeLog)) {
      debugPrint('[BlocObserver] ${bloc.runtimeType} Change: $change');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('[BlocObserver] ${bloc.runtimeType} Error: $error');
    debugPrint('[BlocObserver] StackTrace: $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}