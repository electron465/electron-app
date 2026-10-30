// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import '../../../../core/theme/app_theme.dart';
// import '../../../../core/utils/formatters.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../../domain/entities/payment.dart';
// import '../cubit/payment_cubit.dart';
//
// class PaymentPage extends StatelessWidget {
//   const PaymentPage({required this.amountCents, super.key});
//
//   /// Solo para mostrar; el backend calcula el monto real a cobrar.
//   final int amountCents;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<PaymentCubit, PaymentState>(
//       listenWhen: (p, c) => p.status != c.status,
//       listener: (context, state) {
//         if (state.status == PaymentStatus.failure) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.errorMessage ?? 'Error')),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state.status == PaymentStatus.success && state.receipt != null) {
//           return _ReceiptView(receipt: state.receipt!);
//         }
//         return _MethodSelectionView(amountCents: amountCents, state: state);
//       },
//     );
//   }
// }
//
// class _MethodSelectionView extends StatelessWidget {
//   const _MethodSelectionView({required this.amountCents, required this.state});
//
//   final int amountCents;
//   final PaymentState state;
//
//   @override
//   Widget build(BuildContext context) {
//     final cubit = context.read<PaymentCubit>();
// //     final text = Theme.of(context).textTheme;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Pagar cuota')),
//       body: Padding(
//         padding: const EdgeInsets.all(AppSpacing.md),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text('Monto a pagar', style: text.bodyMedium),
//             Text(Formatters.money(amountCents), style: text.displaySmall),
//             const SizedBox(height: AppSpacing.lg),
//             Text('Método de pago', style: text.titleMedium),
//             RadioGroup<PaymentMethod>(
//               groupValue: state.method,
//               onChanged: (m) => m == null ? null : cubit.selectMethod(m),
//               child: Column(
//                 children: [
//                   for (final method in PaymentMethod.values)
//                     RadioListTile<PaymentMethod>(
//                       value: method,
//                       title: Text(method.label),
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                 ],
//               ),
//             ),
//             const Spacer(),
//             AppButton(
//               label: 'Confirmar pago',
//               isLoading: state.status == PaymentStatus.submitting,
//               onPressed: cubit.submit,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ReceiptView extends StatelessWidget {
//   const _ReceiptView({required this.receipt});
//
//   final PaymentReceipt receipt;
//
//   @override
//   Widget build(BuildContext context) {
//     final text = Theme.of(context).textTheme;
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(AppSpacing.lg),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Spacer(),
//               const Icon(
//                 Icons.check_circle,
//                 size: 80,
//                 color: AppColors.success,
//               ),
//               const SizedBox(height: AppSpacing.md),
//               Text(
//                 '¡Pago exitoso!',
//                 textAlign: TextAlign.center,
//                 style: text.headlineSmall,
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               Text(
//                 '${Formatters.money(receipt.amountCents)} vía '
//                 '${receipt.method.label}\nReferencia: ${receipt.reference}',
//                 textAlign: TextAlign.center,
//               ),
//               const Spacer(),
//               AppButton(label: 'Listo', onPressed: () => context.pop(true)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
