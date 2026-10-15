import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/order.dart';
import '../cubit/order_detail_cubit.dart';
import '../widgets/installment_status_chip.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de compra')),
      body: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (context, state) => switch (state) {
          OrderDetailLoading() => const LoadingView(),
          OrderDetailError(:final message) => ErrorView(
            message: message,
            onRetry: context.read<OrderDetailCubit>().load,
          ),
          OrderDetailLoaded(:final order) => _OrderDetailView(order: order),
        },
      ),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView({required this.order});

  final Order order;

  Future<void> _pay(BuildContext context, Installment installment) async {
    final paid = await context.push<bool>(
      Routes.payInstallment(
        orderId: order.id,
        installmentId: installment.id,
        amountCents: installment.amountCents,
      ),
    );
    if (paid == true && context.mounted) {
      await context.read<OrderDetailCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final next = order.nextInstallment;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(order.storeName, style: text.headlineSmall),
        Text(order.description),
        Text(
          'Comprado el ${Formatters.date(order.createdAt)}',
          style: text.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _Line('Total', Formatters.money(order.totalCents)),
                _Line(
                  'Inicial pagada',
                  Formatters.money(order.initialPaidCents),
                ),
                _Line('Pendiente', Formatters.money(order.pendingCents)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Cuotas', style: text.titleMedium),
        ...order.installments.map(
          (i) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Cuota ${i.number} · ${Formatters.money(i.amountCents)}',
            ),
            subtitle: Text('Vence ${Formatters.date(i.dueDate)}'),
            trailing: InstallmentStatusChip(status: i.status),
          ),
        ),
        if (next != null) ...[
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: () => _pay(context, next),
            child: Text(
              'Pagar cuota ${next.number} · '
              '${Formatters.money(next.amountCents)}',
            ),
          ),
        ],
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    ),
  );
}
