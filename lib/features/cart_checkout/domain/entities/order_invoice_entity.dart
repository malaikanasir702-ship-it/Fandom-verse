import 'package:equatable/equatable.dart';

class OrderInvoiceEntity extends Equatable {
  final String orderId;
  final String userId;
  final DateTime orderDate;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String appliedCoupon;
  final String shippingAddress;
  final String paymentMethod;
  final List<Map<String, dynamic>> items;
  final String status;

  const OrderInvoiceEntity({
    required this.orderId,
    required this.userId,
    required this.orderDate,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    this.appliedCoupon = '',
    required this.shippingAddress,
    required this.paymentMethod,
    required this.items,
    this.status = 'Simulated Completed',
  });

  Map<String, dynamic> toDbMap() {
    final summary = items
        .map((i) => '${i['name']} (${i['variant']}) x${i['quantity']}')
        .join(', ');

    return {
      'order_id': orderId,
      'user_id': userId,
      'order_date': orderDate.millisecondsSinceEpoch,
      'total_amount': totalAmount,
      'items_summary': summary,
      'shipping_address': shippingAddress,
      'order_status': status,
    };
  }

  factory OrderInvoiceEntity.fromDbMap(Map<String, dynamic> map) {
    return OrderInvoiceEntity(
      orderId: map['order_id'] ?? '',
      userId: map['user_id'] ?? '',
      orderDate: DateTime.fromMillisecondsSinceEpoch((map['order_date'] as num?)?.toInt() ?? 0),
      subtotal: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      shippingFee: 0.0,
      discountAmount: 0.0,
      taxAmount: 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      shippingAddress: map['shipping_address'] ?? '',
      paymentMethod: 'Simulated Fast Pay',
      items: [],
      status: map['order_status'] ?? 'Simulated Completed',
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        userId,
        orderDate,
        subtotal,
        shippingFee,
        discountAmount,
        taxAmount,
        totalAmount,
        appliedCoupon,
        shippingAddress,
        paymentMethod,
        items,
        status,
      ];
}
