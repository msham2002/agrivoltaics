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

  // TODO: remove
  static const String adminEmail = String.fromEnvironment(
    'ADMIN_EMAIL',
    defaultValue: ''
  );

  static const String ownerEmail = String.fromEnvironment(
    'OWNER_EMAIL',
    defaultValue: ''
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

enum SensorType {
  humidity,
  temperature
}

extension SensorTypeExtension on SensorType {
  // TODO: bad practice of String? when we just have to force the result! for use in flutter Text widgets anyways
  String? get displayName {
    switch (this) {
      case SensorType.humidity:
        return 'Humidity';
      case SensorType.temperature:
        return 'Temperature';
      default:
        return null;
    }
  }
}