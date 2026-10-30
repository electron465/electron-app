import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/order_detail_cubit.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Orden')),
      body: BlocBuilder<OrderDetailCubit, dynamic>(
        builder: (context, state) {
          // Por ahora mostramos un texto simple para que compile
          // y podamos avanzar con el Login/Registro.
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.construction, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('Pantalla de detalle en construcción'),
                Text('(Módulo de pagos desactivado)'),
              ],
            ),
          );
        },
      ),
    );
  }
}