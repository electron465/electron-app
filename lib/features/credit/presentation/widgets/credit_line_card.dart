import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/credit_line.dart';

class CreditLineCard extends StatelessWidget {
  const CreditLineCard({required this.creditLine, super.key});

  final CreditLine creditLine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final onCard = scheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Disponible para comprar',
                style: text.bodyMedium?.copyWith(color: onCard),
              ),
              Chip(
                avatar: const Icon(Icons.star_rounded, size: 18),
                label: Text(creditLine.levelName),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Text(
            Formatters.money(creditLine.availableCents),
            style: text.displaySmall?.copyWith(
              color: onCard,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 1 - creditLine.usageRatio,
              minHeight: 8,
              color: onCard,
              backgroundColor: onCard.withValues(alpha: 0.25),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Límite total ${Formatters.money(creditLine.totalLimitCents)} · '
            'Inicial ${creditLine.initialPaymentPercent}% · '
            '${creditLine.installmentsCount} cuotas cada '
            '${creditLine.installmentFrequencyDays} días',
            style: text.bodySmall?.copyWith(color: onCard),
          ),
        ],
      ),
    );
  }
}
