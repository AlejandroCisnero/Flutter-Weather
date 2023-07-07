import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/packages/weather_repository/lib/weather_repository.dart'
    hide Weather;
import 'package:flutter_weather/theme/cubit/theme_cubit.dart';
import 'package:flutter_weather/views/search/search_page.dart';
import 'package:flutter_weather/views/settings/settings_page.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';

import 'widgets/weather_barrel.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit(context.read<WeatherRepository>()),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Weather'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                SettingsPage.route(
                  context.read<WeatherCubit>(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          // do stuff here based on WeatherCubit's state
          listener: (context, state) {
            if (state.status.isSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          // return widget here based on WeatherCubit's state
          builder: (context, state) {
            switch (state.status) {
              case WeatherStatus.initial:
                return const WeatherEmpty();
              case WeatherStatus.loading:
                return const WeatherLoading();
              case WeatherStatus.success:
                return WeatherSuccess(
                  weather: state.weather,
                  units: state.temperatureUnits,
                  onRefresh: context.read<WeatherCubit>().refreshWeather,
                );
              case WeatherStatus.failure:
                return const WeatherFailure();
              case WeatherStatus.failureOnRefresh:
                return const WeatherFailureOnRefresh();
              default:
                return const WeatherEmpty();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String city =
              await Navigator.of(context).push(SearchPage.route()) as String;
          if (!mounted) return;
          //Perform a search using the weather cubit upper in the tree
          await context.read<WeatherCubit>().fetchWeather(city);
        },
        child: const Icon(
          Icons.search,
          semanticLabel: 'Search',
        ),
      ),
    );
  }
}
