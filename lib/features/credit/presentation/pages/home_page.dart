import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/credit_cubit.dart';
import '../widgets/credit_line_card.dart';
import '../widgets/purchase_simulator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.select((AuthBloc b) => b.state.user?.firstName ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, $name'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: BlocBuilder<CreditCubit, CreditState>(
        builder: (context, state) => switch (state) {
          CreditLoading() => const LoadingView(),
          CreditError(:final message) => ErrorView(
            message: message,
            onRetry: context.read<CreditCubit>().load,
          ),
          CreditLoaded(:final creditLine) => RefreshIndicator(
            onRefresh: context.read<CreditCubit>().load,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                CreditLineCard(creditLine: creditLine),
                const SizedBox(height: AppSpacing.md),
                PurchaseSimulator(creditLine: creditLine),
              ],
            ),
          ),
        },
      ),
    );
  }
}
