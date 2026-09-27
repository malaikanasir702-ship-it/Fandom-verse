import 'dart:convert';
import 'package:equatable/equatable.dart';

class TicketEntity extends Equatable {
  final String ticketId;
  final String userId;
  final String eventId;
  final String eventTitle;
  final String? eventBannerUrl;
  final String cityName;
  final String venueName;
  final int eventDate;
  final String tierTitle;
  final int quantity;
  final double unitPrice;
  final double fee;
  final double totalAmount;
  final String attendeeName;
  final String paymentMethod;
  final String? paymentIntentId;
  final String qrData;
  final int purchasedAt;
  final String status;

  const TicketEntity({
    required this.ticketId,
    required this.userId,
    required this.eventId,
    required this.eventTitle,
    this.eventBannerUrl,
    required this.cityName,
    required this.venueName,
    required this.eventDate,
    required this.tierTitle,
    required this.quantity,
    required this.unitPrice,
    required this.fee,
    required this.totalAmount,
    required this.attendeeName,
    this.paymentMethod = 'Stripe Card',
    this.paymentIntentId,
    required this.qrData,
    required this.purchasedAt,
    this.status = 'Confirmed',
  });

  Map<String, dynamic> toMap() {
    return {
      'ticket_id': ticketId,
      'user_id': userId,
      'event_id': eventId,
      'event_title': eventTitle,
      'event_banner_url': eventBannerUrl ?? '',
      'city_name': cityName,
      'venue_name': venueName,
      'event_date': eventDate,
      'tier_title': tierTitle,
      'quantity': quantity,
      'unit_price': unitPrice,
      'fee': fee,
      'total_amount': totalAmount,
      'attendee_name': attendeeName,
      'payment_method': paymentMethod,
      'payment_intent_id': paymentIntentId ?? '',
      'qr_data': qrData,
      'purchased_at': purchasedAt,
      'status': status,
    };
  }

  factory TicketEntity.fromMap(Map<String, dynamic> map) {
    return TicketEntity(
      ticketId: map['ticket_id'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      eventId: map['event_id'] as String? ?? '',
      eventTitle: map['event_title'] as String? ?? '',
      eventBannerUrl: (map['event_banner_url'] as String?)?.isNotEmpty == true
          ? map['event_banner_url'] as String
          : null,
      cityName: map['city_name'] as String? ?? '',
      venueName: map['venue_name'] as String? ?? '',
      eventDate: (map['event_date'] as num?)?.toInt() ?? 0,
      tierTitle: map['tier_title'] as String? ?? 'General Pass',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      fee: (map['fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0.0,
      attendeeName: map['attendee_name'] as String? ?? 'Valued Fan',
      paymentMethod: map['payment_method'] as String? ?? 'Stripe Card',
      paymentIntentId: map['payment_intent_id'] as String?,
      qrData: map['qr_data'] as String? ?? '',
      purchasedAt: (map['purchased_at'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'Confirmed',
    );
  }

  /// Generates verification JSON encoded for the QR code
  static String generateQrPayload({
    required String ticketId,
    required String eventId,
    required String eventTitle,
    required String attendeeName,
    required int quantity,
    required String tierTitle,
    required double totalAmount,
    required String? paymentIntentId,
  }) {
    return jsonEncode({
      'app': 'FandomVerse',
      'type': 'EVENT_TICKET',
      'ticketId': ticketId,
      'eventId': eventId,
      'title': eventTitle,
      'attendee': attendeeName,
      'qty': quantity,
      'tier': tierTitle,
      'paid': totalAmount,
      'stripeRef': paymentIntentId ?? '',
      'verified': true,
    });
  }

  @override
  List<Object?> get props => [
        ticketId,
        userId,
        eventId,
        eventTitle,
        eventBannerUrl,
        cityName,
        venueName,
        eventDate,
        tierTitle,
        quantity,
        unitPrice,
        fee,
        totalAmount,
        attendeeName,
        paymentMethod,
        paymentIntentId,
        qrData,
        purchasedAt,
        status,
      ];
}
