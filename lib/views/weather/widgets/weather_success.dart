import 'package:flutter/material.dart';
import 'package:flutter_weather/weather/models/weather.dart';

import 'package:weather_repository/weather_repository.dart' hide Weather;

class WeatherSuccess extends StatelessWidget {
  const WeatherSuccess({
    super.key,
    required this.weather,
    required this.units,
    required this.onRefresh,
  });

  final Weather weather;
  final TemperatureUnits units;
  final ValueGetter<Future<void>> onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        const _WeatherBackground(),
        RefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.none,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  _WeatherIcon(condition: weather.condition),
                  Text(
                    weather.location,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.formattedTemperature(units),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '''Last Updated at ${TimeOfDay.fromDateTime(weather.lastUpdate).format(context)}''',
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({super.key, required this.condition});

  static const double _iconSize = 75.0;
  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}

extension on WeatherCondition {
  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
        return '❓';
    }
  }
}

class _WeatherBackground extends StatelessWidget {
  const _WeatherBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0.25,
                0.75,
                0.90,
                1.0
              ],
              colors: [
                color,
                color.brighten(),
                color.brighten(33),
                color.brighten(50),
              ]),
        ),
      ),
    );
  }
}

extension on Color {
  Color brighten([int percent = 10]) {
    assert(
        1 <= percent && percent <= 100, 'percentage must be between 1 and 100');
    final p = percent / 100;
    return Color.fromARGB(
      alpha,
      red + ((225 - red) * p).round(),
      green + ((225 - green) * p).round(),
      blue + ((225 - blue) * p).round(),
    );
  }
}

extension on Weather {
  String formattedTemperature(TemperatureUnits units) {
    return '''${temperature.value.toStringAsPrecision(2)}°${units.isCelcius ? 'C' : 'F'}''';
  }
}
