import 'package:equatable/equatable.dart';
import 'package:flutter_weather/packages/weather_repository/lib/weather_repository.dart'
    hide Weather;
import 'package:flutter_weather/weather/models/weather.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(WeatherState());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) return;
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(city),
      );
      final units = state.temperatureUnits;
      final value = units.isFarenheit
          ? weather.temperature.value.toFarenheit()
          : weather.temperature.value;
      emit(state.copyWith(
          status: WeatherStatus.success,
          weather: weather.copyWith(temperature: Temperature(value: value)),
          temperatureUnits: units));
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  Future<void> refreshWeather() async {
    //Avoid when we are in a failure case
    if (!state.status.isSuccess) return;
    //Avoid when we dont have a weather yet
    if (state.weather == Weather.empty) return;
    final city = state.weather.location;
    if (city == null || city.isEmpty) return;
    try {
      final weather =
          Weather.fromRepository(await _weatherRepository.getWeather(city));
      final units = state.temperatureUnits;
      final value = units.isFarenheit
          ? weather.temperature.value.toFarenheit()
          : weather.temperature.value;
      emit(state.copyWith(
          status: WeatherStatus.success,
          weather: weather.copyWith(
              temperature: Temperature(value: value),
              lastUpdate: DateTime.now()),
          temperatureUnits: units));
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failureOnRefresh));
    }
  }

  void toogleUnits() {
    if (!state.status.isSuccess) return;
    //Toggle the temperature units
    final units = state.temperatureUnits.isFarenheit
        ? TemperatureUnits.celcius
        : TemperatureUnits.farenheit;

    //In case of no weather just toggle the units
    if (!state.status.isSuccess) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }

    //Get the current weather
    final weather = state.weather;
    if (weather != Weather.empty) {
      //Get the current temperature
      final temperature = weather.temperature;
      //Convert the current temperature to the correct temperature units
      final value = units.isCelcius
          ? temperature.value.toCelcius()
          : temperature.value.toFarenheit();
      emit(
        state.copyWith(
          temperatureUnits: units,
          weather: state.weather.copyWith(
            temperature: Temperature(value: value),
          ),
        ),
      );
    }
  }

  //??
  @override
  WeatherState? fromJson(Map<String, dynamic> json) {
    return WeatherState.fromJson(json);
  }

  //??
  @override
  Map<String, dynamic>? toJson(WeatherState state) {
    return state.toJson();
  }
}

extension on double {
  double toFarenheit() => (this * 9 / 5) + 32;
  double toCelcius() => (this - 32) * 5 / 9;
}
