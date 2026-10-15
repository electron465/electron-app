import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/store.dart';
import '../bloc/stores_bloc.dart';

class StoresPage extends StatelessWidget {
  const StoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiendas aliadas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar tienda o categoría',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (q) =>
                  context.read<StoresBloc>().add(StoresQueryChanged(q)),
            ),
          ),
          Expanded(
            child: BlocBuilder<StoresBloc, StoresState>(
              builder: (context, state) => switch (state) {
                StoresLoading() => const LoadingView(),
                StoresError(:final message) => ErrorView(
                  message: message,
                  onRetry: () =>
                      context.read<StoresBloc>().add(const StoresRequested()),
                ),
                StoresLoaded(:final stores) when stores.isEmpty =>
                  const EmptyView(message: 'No encontramos tiendas.'),
                StoresLoaded(:final stores) => ListView.separated(
                  itemCount: stores.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => _StoreTile(store: stores[i]),
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(store.name.characters.first)),
      title: Text(store.name),
      subtitle: Text(store.category),
      trailing: Icon(
        store.isOnline ? Icons.language : Icons.storefront,
        semanticLabel: store.isOnline ? 'Online' : 'Tienda física',
      ),
      onTap: () {
        // TODO: detalle de tienda / catálogo / pagar con QR.
      },
    );
  }
}
