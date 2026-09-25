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
    this.status = 'Completed',
  });

  Map<String, dynamic> toDbMap() {
    final summary = items
        .map((i) => '${i['name']} (${i['variant']}) x${i['quantity']}')
        .join(', ');

    return {
      'order_id': orderId,
      'user_id': userId,
      'order_date': orderDate.millisecondsSinceEpoch,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'applied_coupon': appliedCoupon,
      'items_summary': summary,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
      'order_status': status,
    };
  }

  factory OrderInvoiceEntity.fromDbMap(Map<String, dynamic> map) {
    return OrderInvoiceEntity(
      orderId: (map['order_id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      orderDate: DateTime.fromMillisecondsSinceEpoch((map['order_date'] as num?)?.toInt() ?? 0),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? ((map['total_amount'] as num?)?.toDouble() ?? 0.0),
      shippingFee: (map['shipping_fee'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      appliedCoupon: (map['applied_coupon'] ?? '').toString(),
      shippingAddress: (map['shipping_address'] ?? '').toString(),
      paymentMethod: (map['payment_method'] ?? 'Cash on Delivery').toString(),
      items: [],
      status: (map['order_status'] ?? 'Completed').toString(),
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
