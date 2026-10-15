import 'package:flutter/material.dart';

/// Se muestra mientras [AuthBloc] restaura la sesión (estado `unknown`).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Icon(
          Icons.shopping_bag_rounded,
          size: 72,
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}
