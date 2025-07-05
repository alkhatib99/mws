import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class PerformanceService {
  static final Map<String, PerformanceMetric> _metrics = {};
  static final Map<String, Timer> _timers = {};
  static final List<PerformanceEvent> _events = [];
  static const int _maxEvents = 1000;
  
  // Performance thresholds
  static const Duration _slowOperationThreshold = Duration(seconds: 3);
  static const Duration _verySlowOperationThreshold = Duration(seconds: 10);
  static const int _maxConcurrentOperations = 10;
  
  // Current operation tracking
  static final Set<String> _activeOperations = {};
  static final Map<String, DateTime> _operationStartTimes = {};

  /// Start tracking a performance metric
  static void startOperation(String operationName, {Map<String, dynamic>? metadata}) {
    final startTime = DateTime.now();
    _operationStartTimes[operationName] = startTime;
    _activeOperations.add(operationName);
    
    _logEvent(PerformanceEvent(
      type: PerformanceEventType.operationStart,
      operationName: operationName,
      timestamp: startTime,
      metadata: metadata,
    ));
    
    // Set up timeout warning
    _timers[operationName] = Timer(_slowOperationThreshold, () {
      if (_activeOperations.contains(operationName)) {
        _logEvent(PerformanceEvent(
          type: PerformanceEventType.slowOperation,
          operationName: operationName,
          timestamp: DateTime.now(),
          duration: DateTime.now().difference(startTime),
          metadata: {'warning': 'Operation taking longer than expected'},
        ));
      }
    });
  }

  /// End tracking a performance metric
  static void endOperation(String operationName, {bool success = true, String? error, Map<String, dynamic>? metadata}) {
    final endTime = DateTime.now();
    final startTime = _operationStartTimes[operationName];
    
    if (startTime == null) {
      if (kDebugMode) {
        print('Warning: Ending operation "$operationName" that was never started');
      }
      return;
    }
    
    final duration = endTime.difference(startTime);
    _activeOperations.remove(operationName);
    _operationStartTimes.remove(operationName);
    _timers[operationName]?.cancel();
    _timers.remove(operationName);
    
    // Update or create metric
    final metric = _metrics[operationName] ?? PerformanceMetric(operationName);
    metric.addMeasurement(duration, success);
    _metrics[operationName] = metric;
    
    // Log event
    _logEvent(PerformanceEvent(
      type: success ? PerformanceEventType.operationEnd : PerformanceEventType.operationError,
      operationName: operationName,
      timestamp: endTime,
      duration: duration,
      error: error,
      metadata: metadata,
    ));
    
    // Check for performance issues
    if (duration > _verySlowOperationThreshold) {
      _logEvent(PerformanceEvent(
        type: PerformanceEventType.verySlowOperation,
        operationName: operationName,
        timestamp: endTime,
        duration: duration,
        metadata: {'severity': 'high'},
      ));
    }
  }

  /// Measure a function execution time
  static Future<T> measureAsync<T>(String operationName, Future<T> Function() operation, {Map<String, dynamic>? metadata}) async {
    startOperation(operationName, metadata: metadata);
    
    try {
      final result = await operation();
      endOperation(operationName, success: true, metadata: metadata);
      return result;
    } catch (e) {
      endOperation(operationName, success: false, error: e.toString(), metadata: metadata);
      rethrow;
    }
  }

  /// Measure a synchronous function execution time
  static T measureSync<T>(String operationName, T Function() operation, {Map<String, dynamic>? metadata}) {
    startOperation(operationName, metadata: metadata);
    
    try {
      final result = operation();
      endOperation(operationName, success: true, metadata: metadata);
      return result;
    } catch (e) {
      endOperation(operationName, success: false, error: e.toString(), metadata: metadata);
      rethrow;
    }
  }

  /// Get performance metric for an operation
  static PerformanceMetric? getMetric(String operationName) {
    return _metrics[operationName];
  }

  /// Get all performance metrics
  static Map<String, PerformanceMetric> getAllMetrics() {
    return Map.from(_metrics);
  }

  /// Get performance summary
  static PerformanceSummary getSummary() {
    final totalOperations = _metrics.values.fold<int>(0, (sum, metric) => sum + metric.totalCalls);
    final totalErrors = _metrics.values.fold<int>(0, (sum, metric) => sum + metric.errorCount);
    final averageDuration = _metrics.values.isNotEmpty
        ? _metrics.values.fold<double>(0, (sum, metric) => sum + metric.averageDuration.inMilliseconds) / _metrics.length
        : 0.0;
    
    final slowOperations = _metrics.entries
        .where((entry) => entry.value.averageDuration > _slowOperationThreshold)
        .map((entry) => entry.key)
        .toList();
    
    return PerformanceSummary(
      totalOperations: totalOperations,
      totalErrors: totalErrors,
      averageDurationMs: averageDuration,
      slowOperations: slowOperations,
      activeOperations: _activeOperations.length,
      metricsCount: _metrics.length,
    );
  }

  /// Get recent performance events
  static List<PerformanceEvent> getRecentEvents({int limit = 100}) {
    final sortedEvents = List<PerformanceEvent>.from(_events)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return sortedEvents.take(limit).toList();
  }

  /// Get events for a specific operation
  static List<PerformanceEvent> getOperationEvents(String operationName, {int limit = 50}) {
    return _events
        .where((event) => event.operationName == operationName)
        .toList()
        .reversed
        .take(limit)
        .toList();
  }

  /// Clear all performance data
  static void clear() {
    _metrics.clear();
    _events.clear();
    _activeOperations.clear();
    _operationStartTimes.clear();
    
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }

  /// Clear metrics for a specific operation
  static void clearOperation(String operationName) {
    _metrics.remove(operationName);
    _events.removeWhere((event) => event.operationName == operationName);
    _activeOperations.remove(operationName);
    _operationStartTimes.remove(operationName);
    _timers[operationName]?.cancel();
    _timers.remove(operationName);
  }

  /// Check if system is under heavy load
  static bool isUnderHeavyLoad() {
    return _activeOperations.length > _maxConcurrentOperations;
  }

  /// Get current active operations
  static List<String> getActiveOperations() {
    return List.from(_activeOperations);
  }

  /// Get operation duration if currently running
  static Duration? getCurrentOperationDuration(String operationName) {
    final startTime = _operationStartTimes[operationName];
    return startTime != null ? DateTime.now().difference(startTime) : null;
  }

  /// Log a custom performance event
  static void logCustomEvent(String operationName, PerformanceEventType type, {Map<String, dynamic>? metadata}) {
    _logEvent(PerformanceEvent(
      type: type,
      operationName: operationName,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }

  /// Internal method to log events
  static void _logEvent(PerformanceEvent event) {
    _events.add(event);
    
    // Keep only recent events to prevent memory issues
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }
    
    // Log to console in debug mode
    if (kDebugMode) {
      _logToConsole(event);
    }
  }

  /// Log performance event to console
  static void _logToConsole(PerformanceEvent event) {
    final duration = event.duration != null ? ' (${event.duration!.inMilliseconds}ms)' : '';
    final error = event.error != null ? ' - Error: ${event.error}' : '';
    
    switch (event.type) {
      case PerformanceEventType.operationStart:
        print('🚀 Started: ${event.operationName}');
        break;
      case PerformanceEventType.operationEnd:
        print('✅ Completed: ${event.operationName}$duration');
        break;
      case PerformanceEventType.operationError:
        print('❌ Failed: ${event.operationName}$duration$error');
        break;
      case PerformanceEventType.slowOperation:
        print('⚠️ Slow: ${event.operationName}$duration');
        break;
      case PerformanceEventType.verySlowOperation:
        print('🐌 Very Slow: ${event.operationName}$duration');
        break;
      case PerformanceEventType.custom:
        print('📊 Custom: ${event.operationName}$duration');
        break;
    }
  }

  /// Get performance recommendations
  static List<String> getRecommendations() {
    final recommendations = <String>[];
    
    // Check for slow operations
    final slowOps = _metrics.entries
        .where((entry) => entry.value.averageDuration > _slowOperationThreshold)
        .toList();
    
    if (slowOps.isNotEmpty) {
      recommendations.add('Consider optimizing slow operations: ${slowOps.map((e) => e.key).join(', ')}');
    }
    
    // Check for high error rates
    final highErrorOps = _metrics.entries
        .where((entry) => entry.value.errorRate > 0.1) // 10% error rate
        .toList();
    
    if (highErrorOps.isNotEmpty) {
      recommendations.add('High error rates detected in: ${highErrorOps.map((e) => e.key).join(', ')}');
    }
    
    // Check for too many concurrent operations
    if (_activeOperations.length > _maxConcurrentOperations) {
      recommendations.add('Too many concurrent operations (${_activeOperations.length}). Consider implementing queuing.');
    }
    
    // Check for memory usage
    if (_events.length > _maxEvents * 0.8) {
      recommendations.add('High memory usage from performance events. Consider clearing old data.');
    }
    
    return recommendations;
  }
}

class PerformanceMetric {
  final String operationName;
  final List<Duration> _durations = [];
  final List<bool> _successes = [];
  DateTime? _firstCall;
  DateTime? _lastCall;

  PerformanceMetric(this.operationName);

  void addMeasurement(Duration duration, bool success) {
    _durations.add(duration);
    _successes.add(success);
    
    final now = DateTime.now();
    _firstCall ??= now;
    _lastCall = now;
    
    // Keep only recent measurements to prevent memory issues
    if (_durations.length > 1000) {
      _durations.removeRange(0, _durations.length - 1000);
      _successes.removeRange(0, _successes.length - 1000);
    }
  }

  int get totalCalls => _durations.length;
  int get successCount => _successes.where((s) => s).length;
  int get errorCount => _successes.where((s) => !s).length;
  double get errorRate => totalCalls > 0 ? errorCount / totalCalls : 0.0;
  double get successRate => totalCalls > 0 ? successCount / totalCalls : 0.0;

  Duration get averageDuration {
    if (_durations.isEmpty) return Duration.zero;
    final totalMs = _durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: (totalMs / _durations.length).round());
  }

  Duration get minDuration => _durations.isEmpty ? Duration.zero : _durations.reduce((a, b) => a < b ? a : b);
  Duration get maxDuration => _durations.isEmpty ? Duration.zero : _durations.reduce((a, b) => a > b ? a : b);

  Duration get medianDuration {
    if (_durations.isEmpty) return Duration.zero;
    final sorted = List<Duration>.from(_durations)..sort((a, b) => a.compareTo(b));
    final middle = sorted.length ~/ 2;
    return sorted[middle];
  }

  Duration get p95Duration {
    if (_durations.isEmpty) return Duration.zero;
    final sorted = List<Duration>.from(_durations)..sort((a, b) => a.compareTo(b));
    final index = (sorted.length * 0.95).floor();
    return sorted[min(index, sorted.length - 1)];
  }

  DateTime? get firstCall => _firstCall;
  DateTime? get lastCall => _lastCall;

  Map<String, dynamic> toJson() {
    return {
      'operationName': operationName,
      'totalCalls': totalCalls,
      'successCount': successCount,
      'errorCount': errorCount,
      'errorRate': errorRate,
      'successRate': successRate,
      'averageDurationMs': averageDuration.inMilliseconds,
      'minDurationMs': minDuration.inMilliseconds,
      'maxDurationMs': maxDuration.inMilliseconds,
      'medianDurationMs': medianDuration.inMilliseconds,
      'p95DurationMs': p95Duration.inMilliseconds,
      'firstCall': firstCall?.toIso8601String(),
      'lastCall': lastCall?.toIso8601String(),
    };
  }
}

class PerformanceEvent {
  final PerformanceEventType type;
  final String operationName;
  final DateTime timestamp;
  final Duration? duration;
  final String? error;
  final Map<String, dynamic>? metadata;

  PerformanceEvent({
    required this.type,
    required this.operationName,
    required this.timestamp,
    this.duration,
    this.error,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'operationName': operationName,
      'timestamp': timestamp.toIso8601String(),
      'durationMs': duration?.inMilliseconds,
      'error': error,
      'metadata': metadata,
    };
  }
}

enum PerformanceEventType {
  operationStart,
  operationEnd,
  operationError,
  slowOperation,
  verySlowOperation,
  custom,
}

class PerformanceSummary {
  final int totalOperations;
  final int totalErrors;
  final double averageDurationMs;
  final List<String> slowOperations;
  final int activeOperations;
  final int metricsCount;

  PerformanceSummary({
    required this.totalOperations,
    required this.totalErrors,
    required this.averageDurationMs,
    required this.slowOperations,
    required this.activeOperations,
    required this.metricsCount,
  });

  double get errorRate => totalOperations > 0 ? totalErrors / totalOperations : 0.0;
  double get successRate => 1.0 - errorRate;

  Map<String, dynamic> toJson() {
    return {
      'totalOperations': totalOperations,
      'totalErrors': totalErrors,
      'errorRate': errorRate,
      'successRate': successRate,
      'averageDurationMs': averageDurationMs,
      'slowOperations': slowOperations,
      'activeOperations': activeOperations,
      'metricsCount': metricsCount,
    };
  }

  @override
  String toString() {
    return 'PerformanceSummary(ops: $totalOperations, errors: $totalErrors, avgMs: ${averageDurationMs.toStringAsFixed(1)}, active: $activeOperations)';
  }
}

