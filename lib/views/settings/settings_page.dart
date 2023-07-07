import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_weather/weather/cubit/weather_cubit.dart';
import 'package:flutter_weather/weather/models/models.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static Route<void> route(WeatherCubit weatherCubit) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: weatherCubit,
        child: const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) => ListTile(
              title: const Text('Temperature Units'),
              isThreeLine: true,
              subtitle:
                  const Text('Use metric measurements for temperature units.'),
              trailing: CupertinoSwitch(
                value: state.temperatureUnits.isCelcius,
                onChanged: (value) =>
                    context.read<WeatherCubit>().toogleUnits(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
