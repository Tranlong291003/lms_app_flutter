import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/theme/theme_bloc.dart';
import '../blocs/theme/theme_event.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((ThemeBloc bloc) => bloc.state.themeMode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Light/Dark Theme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              context.read<ThemeBloc>().add(ThemeToggled());
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          themeMode == ThemeMode.light
              ? 'Chế đsộ hiệấdasdasdasdn tại: LIGHT'
              : 'Chế độ hiện ádasdasdtại: DARK',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
