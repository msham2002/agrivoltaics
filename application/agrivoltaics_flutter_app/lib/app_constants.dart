abstract class AppConstants {
  static const String influxdbUrl = String.fromEnvironment(
    'influxdb-url',
    defaultValue: ''
  );

  static const String influxdbToken = String.fromEnvironment(
    'influxdb-token',
    defaultValue: ''
  );
  
  static const String influxdbOrg = String.fromEnvironment(
    'influxdb-org',
    defaultValue: ''
  );

  static const String influxdbBucket = String.fromEnvironment(
    'influxdb-bucket',
    defaultValue: ''
  );

  static const bool influxdbDebug = bool.fromEnvironment(
    'influxdb-debug',
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