/// "Servidor" en memoria usado mientras no exista API real
/// (`--dart-define=USE_MOCKS=true`). Guarda JSON crudo para que los
/// datasources mock ejerciten el mismo `fromJson` que usará la API.
class MockBackend {
  MockBackend() : orders = _seedOrders();

  static const _latency = Duration(milliseconds: 600);
  static const validOtp = '123456';

  Future<void> delay() => Future<void>.delayed(_latency);

  final Map<String, dynamic> user = {
    'id': 'usr_001',
    'full_name': 'María González',
    'phone': '+584121234567',
    'document_id': 'V-12345678',
    'email': 'maria@example.com',
  };

  final Map<String, dynamic> creditLine = {
    'total_limit_cents': 30000,
    'available_cents': 18000,
    'level': 3,
    'level_name': 'Nivel 3',
    'initial_payment_percent': 40,
    'installments_count': 3,
    'installment_frequency_days': 14,
  };

  final List<Map<String, dynamic>> stores = [
    {
      'id': 'st_1',
      'name': 'TecnoMarket',
      'category': 'Tecnología',
      'is_online': true,
    },
    {
      'id': 'st_2',
      'name': 'Farmacia Salud+',
      'category': 'Salud',
      'is_online': false,
    },
    {
      'id': 'st_3',
      'name': 'Moda Urbana',
      'category': 'Ropa',
      'is_online': true,
    },
    {
      'id': 'st_4',
      'name': 'HogarCenter',
      'category': 'Hogar',
      'is_online': false,
    },
    {
      'id': 'st_5',
      'name': 'SuperFresco',
      'category': 'Supermercado',
      'is_online': false,
    },
    {
      'id': 'st_6',
      'name': 'Deportes Total',
      'category': 'Deportes',
      'is_online': true,
    },
  ];

  final List<Map<String, dynamic>> orders;

  static List<Map<String, dynamic>> _seedOrders() {
    final now = DateTime.now();
    String iso(int days) => now.add(Duration(days: days)).toIso8601String();

    return [
      {
        'id': 'ord_1001',
        'store_name': 'TecnoMarket',
        'description': 'Audífonos inalámbricos',
        'total_cents': 15000,
        'initial_paid_cents': 6000,
        'created_at': iso(-10),
        'status': 'active',
        'installments': [
          {
            'id': 'ins_1',
            'number': 1,
            'amount_cents': 3000,
            'due_date': iso(4),
            'status': 'pending',
          },
          {
            'id': 'ins_2',
            'number': 2,
            'amount_cents': 3000,
            'due_date': iso(18),
            'status': 'pending',
          },
          {
            'id': 'ins_3',
            'number': 3,
            'amount_cents': 3000,
            'due_date': iso(32),
            'status': 'pending',
          },
        ],
      },
      {
        'id': 'ord_1000',
        'store_name': 'Moda Urbana',
        'description': 'Zapatos deportivos',
        'total_cents': 10000,
        'initial_paid_cents': 4000,
        'created_at': iso(-40),
        'status': 'active',
        'installments': [
          {
            'id': 'ins_4',
            'number': 1,
            'amount_cents': 2000,
            'due_date': iso(-26),
            'status': 'paid',
          },
          {
            'id': 'ins_5',
            'number': 2,
            'amount_cents': 2000,
            'due_date': iso(-12),
            'status': 'paid',
          },
          {
            'id': 'ins_6',
            'number': 3,
            'amount_cents': 2000,
            'due_date': iso(-1),
            'status': 'overdue',
          },
        ],
      },
    ];
  }

  /// Simula el pago de una cuota y libera cupo en la línea de crédito.
  Map<String, dynamic> payInstallment({
    required String orderId,
    required String installmentId,
    required String method,
  }) {
    final order = orders.firstWhere((o) => o['id'] == orderId);
    final installments = (order['installments'] as List)
        .cast<Map<String, dynamic>>();
    final installment = installments.firstWhere(
      (i) => i['id'] == installmentId,
    );

    installment['status'] = 'paid';
    creditLine['available_cents'] =
        (creditLine['available_cents'] as int) +
        (installment['amount_cents'] as int);
    if (installments.every((i) => i['status'] == 'paid')) {
      order['status'] = 'completed';
    }

    final now = DateTime.now();
    return {
      'id': 'pay_${now.millisecondsSinceEpoch}',
      'order_id': orderId,
      'installment_id': installmentId,
      'amount_cents': installment['amount_cents'],
      'method': method,
      'reference': '${now.millisecondsSinceEpoch % 100000000}',
      'paid_at': now.toIso8601String(),
    };
  }
}
