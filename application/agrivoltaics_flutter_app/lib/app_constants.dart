abstract class AppConstants {
  static const String influxdbUrl = String.fromEnvironment(
    'INFLUXDB_URL',
    defaultValue: ''
  );

  static const String influxdbToken = String.fromEnvironment(
    'INFLUXDB_TOKEN',
    defaultValue: ''
  );
  
  static const String influxdbOrg = String.fromEnvironment(
    'INFLUXDB_ORG',
    defaultValue: ''
  );

  static const String influxdbBucket = String.fromEnvironment(
    'INFLUXDB_BUCKET',
    defaultValue: ''
  );

  static const bool influxdbDebug = bool.fromEnvironment(
    'INFLUXDB_DEBUG',
    defaultValue: false
  );
}

enum TimeRange {
  minute,
  hour,
  day,
  week,
  month
}

extension TimeRangeExtension on TimeRange {
  String? get fluxQuery {
    switch (this) {
      case TimeRange.minute:
        return 'm';
      case TimeRange.hour:
        return 'h';
      case TimeRange.day:
        return 'd';
      case TimeRange.week:
        return 'w';
      case TimeRange.month:
        return 'mo';
      default:
        return null;
    }
  }
}