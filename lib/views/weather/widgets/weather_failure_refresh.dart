import 'package:flutter/material.dart';

class WeatherFailureOnRefresh extends StatelessWidget {
  const WeatherFailureOnRefresh({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🙈', style: TextStyle(fontSize: 64)),
        Text(
          'Something went wrong while trying to refresh the weather status',
          style: theme.textTheme.headlineSmall,
        ),
      ],
    );
  }
}
