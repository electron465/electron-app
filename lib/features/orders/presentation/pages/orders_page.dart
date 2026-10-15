import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';
import '../widgets/installment_status_chip.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<OrdersBloc>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis compras')),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) => switch (state) {
          OrdersLoading() => const LoadingView(),
          OrdersError(:final message) => ErrorView(
            message: message,
            onRetry: () => bloc.add(const OrdersRequested()),
          ),
          OrdersLoaded(:final orders) when orders.isEmpty => const EmptyView(
            message: 'Aún no tienes compras.',
            icon: Icons.receipt_long_outlined,
          ),
          final OrdersLoaded loaded => RefreshIndicator(
            onRefresh: () async {
              bloc.add(const OrdersRequested());
              await bloc.stream.firstWhere((s) => s is! OrdersLoading);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (loaded.active.isNotEmpty) ...[
                  const _SectionTitle('Activas'),
                  ...loaded.active.map((o) => _OrderCard(order: o)),
                ],
                if (loaded.history.isNotEmpty) ...[
                  const _SectionTitle('Historial'),
                  ...loaded.history.map((o) => _OrderCard(order: o)),
                ],
              ],
            ),
          ),
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final next = order.nextInstallment;
    final text = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await context.push(Routes.orderDetail(order.id));
          // Al volver, refresca por si se pagó una cuota.
          if (context.mounted) {
            context.read<OrdersBloc>().add(const OrdersRequested());
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(order.storeName, style: text.titleMedium),
                  Text(
                    Formatters.money(order.totalCents),
                    style: text.titleMedium,
                  ),
                ],
              ),
              Text(order.description, style: text.bodyMedium),
              if (next != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Próxima: ${Formatters.money(next.amountCents)} · '
                      '${Formatters.date(next.dueDate)}',
                      style: text.bodySmall,
                    ),
                    InstallmentStatusChip(status: next.status),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
