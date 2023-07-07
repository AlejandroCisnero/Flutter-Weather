import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' hide Weather;
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

part 'weather.g.dart';

enum TemperatureUnits { farenheit, celcius }

extension TemperatureUnitsX on TemperatureUnits {
  bool get isFarenheit => this == TemperatureUnits.farenheit;
  bool get isCelcius => this == TemperatureUnits.celcius;
}



@JsonSerializable()
class Temperature extends Equatable {
  const Temperature({required this.value});

  final double value;

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  @override
  List<Object?> get props => [value];
}

@JsonSerializable()
class Weather extends Equatable {
  const Weather({
    required this.condition,
    required this.temperature,
    required this.lastUpdate,
    required this.location,
  });

  final WeatherCondition condition;
  final Temperature temperature;
  final DateTime lastUpdate;
  final String location;

  static final empty = Weather(
    condition: WeatherCondition.unknown,
    temperature: const Temperature(value: 0),
    lastUpdate: DateTime.now(),
    location: '--',
  );

  Weather copyWith({
    WeatherCondition? condition,
    Temperature? temperature,
    DateTime? lastUpdate,
    String? location,
  }) {
    return Weather(
      condition: condition ?? this.condition,
      temperature: temperature ?? this.temperature,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      location: location ?? this.location,
    );
  }

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  ///This will receive a weather_repository weather object and create a weather[Weather] object
  factory Weather.fromRepository(weather_repository.Weather weather) {
    return Weather(
        condition: weather.condition,
        temperature: Temperature(value: weather.temperature),
        lastUpdate: DateTime.now(),
        location: weather.location);
  }

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  @override
  List<Object?> get props => [condition, temperature, lastUpdate, location];
}
