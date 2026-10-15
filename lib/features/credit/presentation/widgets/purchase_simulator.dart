import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/credit_line.dart';

/// Simulador "¿cuánto pagaría?". La lógica vive en el dominio
/// ([CreditLine.simulate]); este widget solo la presenta.
class PurchaseSimulator extends StatefulWidget {
  const PurchaseSimulator({required this.creditLine, super.key});

  final CreditLine creditLine;

  @override
  State<PurchaseSimulator> createState() => _PurchaseSimulatorState();
}

class _PurchaseSimulatorState extends State<PurchaseSimulator> {
  PurchasePlan? _plan;

  void _onChanged(String value) {
    final dollars = int.tryParse(value) ?? 0;
    setState(() {
      _plan = dollars > 0 ? widget.creditLine.simulate(dollars * 100) : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final plan = _plan;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Simula tu compra', style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Precio del producto',
                prefixText: r'$ ',
              ),
              onChanged: _onChanged,
            ),
            if (plan != null) ...[
              const SizedBox(height: AppSpacing.md),
              _Row(
                'Pagas hoy (inicial)',
                Formatters.money(plan.initialCents),
                bold: true,
              ),
              for (final (i, amount) in plan.installmentsCents.indexed)
                _Row(
                  'Cuota ${i + 1} · día ${(i + 1) * plan.frequencyDays}',
                  Formatters.money(amount),
                ),
              const Divider(),
              Text('Sin intereses', style: text.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold)
        : const TextStyle();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
