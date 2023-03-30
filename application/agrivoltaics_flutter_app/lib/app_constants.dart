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

enum TimeUnit {
  second, // TODO: remove this, debugging purposes only
  minute,
  hour,
  day,
  week,
  month
}

class TimeInterval {
  TimeInterval(TimeUnit unit, int value) {
    this.unit = unit;
    this.value = value;
  }

  TimeUnit unit = TimeUnit.hour;
  int value = 1;
}

extension TimeIntervalExtension on TimeInterval {
  Duration? get duration {
    switch (this.unit) {
      case TimeUnit.second:
        return Duration(seconds: this.value);
      case TimeUnit.minute:
        return Duration(minutes: this.value);
      case TimeUnit.hour:
        return Duration(hours: this.value);
      case TimeUnit.day:
        return Duration(days: this.value);
      case TimeUnit.week:
        return Duration(days: this.value * 7);
      case TimeUnit.month:
        return Duration(days: this.value * 30);
      default:
        return null;
    }
  }
}

extension TimeUnitExtension on TimeUnit {
  String? get fluxQuery {
    switch (this) {
      case TimeUnit.second:
        return 's';
      case TimeUnit.minute:
        return 'm';
      case TimeUnit.hour:
        return 'h';
      case TimeUnit.day:
        return 'd';
      case TimeUnit.week:
        return 'w';
      case TimeUnit.month:
        return 'mo';
      default:
        return null;
    }
  }
}

enum SensorType {
  humidity,
  temperature,
  light
}

extension SensorTypeExtension on SensorType {
  // TODO: bad practice of String? when we just have to force the result! for use in flutter Text widgets anyways
  String? get displayName {
    switch (this) {
      case SensorType.humidity:
        return 'Humidity';
      case SensorType.temperature:
        return 'Temperature';
      case SensorType.light:
        return 'Light';
      default:
        return null;
    }
  }

  String? get unit {
    switch (this) {
      case SensorType.humidity:
        return '';
      case SensorType.temperature:
        return 'Celsius';
      case SensorType.light:
        return 'Lux';
      default:
        return null;
    }
  }
}