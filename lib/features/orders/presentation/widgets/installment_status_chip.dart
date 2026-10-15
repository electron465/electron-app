import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/order.dart';

class InstallmentStatusChip extends StatelessWidget {
  const InstallmentStatusChip({required this.status, super.key});

  final InstallmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      InstallmentStatus.paid => ('Pagada', AppColors.success),
      InstallmentStatus.pending => ('Pendiente', AppColors.warning),
      InstallmentStatus.overdue => ('Vencida', AppColors.danger),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
