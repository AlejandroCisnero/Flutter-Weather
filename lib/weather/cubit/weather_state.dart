part of 'weather_cubit.dart';

enum WeatherStatus { initial, loading, success, failure, failureOnRefresh }

extension WeatherStatusX on WeatherStatus {
  bool get isInitial => this == WeatherStatus.initial;
  bool get isLoading => this == WeatherStatus.loading;
  bool get isSuccess => this == WeatherStatus.success;
  bool get isFailure => this == WeatherStatus.failure;
  bool get isFailureOnRefresh => this == WeatherStatus.failureOnRefresh;
}

@JsonSerializable()
// ignore: must_be_immutable
class WeatherState extends Equatable {
  WeatherState({
    this.status = WeatherStatus.initial,
    this.temperatureUnits = TemperatureUnits.celcius,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  WeatherStatus status;
  TemperatureUnits temperatureUnits;
  Weather weather;

  WeatherState copyWith({
    WeatherStatus? status,
    TemperatureUnits? temperatureUnits,
    Weather? weather,
  }) {
    return WeatherState(
      status: status ?? this.status,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      weather: weather ?? this.weather,
    );
  }

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @override
  List<Object> get props => [status, temperatureUnits, weather];
}
