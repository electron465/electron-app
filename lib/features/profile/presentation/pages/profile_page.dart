import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Perfil: por ahora solo lee la sesión del [AuthBloc].
/// Cuando crezca (KYC, métodos de pago guardados, referidos...) tendrá
/// sus propias capas domain/data como el resto de features.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc b) => b.state.user);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              user.fullName.characters.first,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Cédula'),
            subtitle: Text(user.documentId),
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Teléfono'),
            subtitle: Text(user.phone),
          ),
          if (user.email != null)
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Correo'),
              subtitle: Text(user.email!),
            ),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Ayuda y soporte'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}
