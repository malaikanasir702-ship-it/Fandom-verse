import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/ticket_entity.dart';
import '../widgets/ticket_qr_code_widget.dart';
import 'ticket_detail_page.dart';
import 'ticket_history_page.dart';

class StripeTicketCheckoutPage extends StatefulWidget {
  final EventEntity event;

  const StripeTicketCheckoutPage({super.key, required this.event});

  @override
  State<StripeTicketCheckoutPage> createState() => _StripeTicketCheckoutPageState();
}

class _StripeTicketCheckoutPageState extends State<StripeTicketCheckoutPage> {
  int _quantity = 1;
  int _selectedTierIndex = 0;
  bool _isProcessing = false;

  final _cardNumberController = TextEditingController(text: '4242 •••• •••• 4242');
  final _expiryController = TextEditingController(text: '12/28');
  final _cvcController = TextEditingController(text: '888');
  final _nameController = TextEditingController(text: 'Alex Mercer');

  final List<Map<String, dynamic>> _ticketTiers = [
    {
      'title': 'Standard Fan Pass',
      'desc': 'Single day access to exhibition & main stage',
      'price': 45.0,
      'badge': 'GENERAL',
    },
    {
      'title': 'VIP Fast-Track Pass',
      'desc': 'Priority queue, exclusive badge & lanyard',
      'price': 85.0,
      'badge': 'POPULAR',
    },
    {
      'title': 'Cosplayer Ultimate Pass',
      'desc': 'Green room access, locker + VIP seating',
      'price': 120.0,
      'badge': 'ALL-IN',
    },
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  double get _unitPrice => _ticketTiers[_selectedTierIndex]['price'] as double;
  double get _subtotal => _unitPrice * _quantity;
  double get _fee => 3.50;
  double get _total => _subtotal + _fee;

  void _processStripePayment() async {
    final cardNumber = _cardNumberController.text.trim();
    final expiry = _expiryController.text.trim();
    final cvc = _cvcController.text.trim();
    final name = _nameController.text.trim();

    if (cardNumber.replaceAll(RegExp(r'\s+'), '').length < 14) {
      AppSnackbar.showError(context, 'Please enter a valid card number');
      return;
    }

    final expiryParts = expiry.split('/');
    if (expiryParts.length != 2) {
      AppSnackbar.showError(context, 'Expiry must be in MM/YY format');
      return;
    }

    final expMonth = expiryParts[0].trim();
    final expYear = expiryParts[1].trim();

    if (cvc.length < 3) {
      AppSnackbar.showError(context, 'Please enter a valid 3 or 4-digit CVC');
      return;
    }

    setState(() => _isProcessing = true);

    final tier = _ticketTiers[_selectedTierIndex];
    final tierTitle = tier['title'] as String;

    final result = await StripeService.processTicketPayment(
      amount: _total,
      cardNumber: cardNumber,
      expMonth: expMonth,
      expYear: expYear,
      cvc: cvc,
      cardholderName: name,
      eventTitle: widget.event.title,
      tierTitle: tierTitle,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (!result.success) {
      AppSnackbar.showError(
        context,
        result.errorMessage ?? 'Payment failed. Please check your card details.',
      );
      return;
    }

    // Payment succeeded! Build and persist TicketEntity
    final ticketId = 'FV-TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final user = context.read<AuthBloc>().currentUser;
    final userId = user?.id ?? 'guest_user';
    final attendeeName = name.isNotEmpty ? name : (user?.name ?? 'Valued Fan');

    final qrPayload = TicketEntity.generateQrPayload(
      ticketId: ticketId,
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      attendeeName: attendeeName,
      quantity: _quantity,
      tierTitle: tierTitle,
      totalAmount: _total,
      paymentIntentId: result.paymentIntentId,
    );

    final newTicket = TicketEntity(
      ticketId: ticketId,
      userId: userId,
      eventId: widget.event.id,
      eventTitle: widget.event.title,
      eventBannerUrl: widget.event.bannerUrl,
      cityName: widget.event.cityName,
      venueName: widget.event.venueName,
      eventDate: widget.event.eventDate.millisecondsSinceEpoch,
      tierTitle: tierTitle,
      quantity: _quantity,
      unitPrice: _unitPrice,
      fee: _fee,
      totalAmount: _total,
      attendeeName: attendeeName,
      paymentMethod: 'Stripe Card',
      paymentIntentId: result.paymentIntentId,
      qrData: qrPayload,
      purchasedAt: DateTime.now().millisecondsSinceEpoch,
      status: 'Confirmed',
    );

    await SqliteHelper.instance.insertTicket(newTicket);

    if (!mounted) return;
    _showTicketSuccessDialog(newTicket);
  }

  void _showTicketSuccessDialog(TicketEntity ticket) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.comicBorderColor, width: 2),
        ),
        title: const Column(
          children: [
            Icon(Iconsax.tick_circle, color: AppColors.success, size: 54),
            SizedBox(height: 10),
            Text(
              'PAYMENT SUCCESSFUL!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.comicBlack,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Your ticket for ${ticket.eventTitle} is confirmed via Stripe!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.comicBlack, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.comicGrayLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.comicBorderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Booking ID:', style: TextStyle(fontSize: 11, color: AppColors.comicGray)),
                        Text(
                          ticket.ticketId,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.comicRed),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pass Tier:', style: TextStyle(fontSize: 11, color: AppColors.comicGray)),
                        Text(
                          '${ticket.quantity}x ${ticket.tierTitle}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Paid:', style: TextStyle(fontSize: 11, color: AppColors.comicGray)),
                        Text(
                          '\$${ticket.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.comicRed),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Real Live QR Code
                    TicketQrCodeWidget(
                      qrData: ticket.qrData,
                      size: 130,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan this real QR code at venue check-in',
                      style: TextStyle(fontSize: 10, color: AppColors.comicGray, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // View Ticket Template Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Iconsax.eye, size: 16, color: AppColors.comicBlack),
                  label: const Text(
                    'VIEW TICKET PASS TEMPLATE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11.5,
                      color: AppColors.comicBlack,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.comicBlack, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) => TicketDetailPage(ticket: ticket),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          SkewedButton(
            text: 'DONE (TICKET HISTORY)',
            height: 48,
            fontSize: 13,
            backgroundColor: AppColors.comicRed,
            icon: Iconsax.tick_circle,
            onPressed: () {
              Navigator.of(ctx).pop(); // pop dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const TicketHistoryPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: const Text(
          'STRIPE CHECKOUT',
          style: TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Summary Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.event.bannerUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72,
                        height: 72,
                        color: AppColors.comicGrayLight,
                        child: const Icon(Iconsax.calendar, color: AppColors.comicGray),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.comicYellow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.event.category.toUpperCase(),
                            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.comicBlack),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.event.title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.event.cityName} • ${widget.event.venueName}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Select Ticket Tier
            Text(
              'SELECT TICKET TIER',
              style: AppTextStyles.comicSectionHeader.copyWith(
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.comicBlack,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(_ticketTiers.length, (index) {
              final tier = _ticketTiers[index];
              final isSelected = _selectedTierIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTierIndex = index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.comicRed : (isDark ? AppColors.darkBorder : AppColors.comicBorderColor),
                      width: isSelected ? 2 : 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Iconsax.tick_circle : Iconsax.record_circle,
                        color: isSelected ? AppColors.comicRed : AppColors.comicGray,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tier['title'] as String,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.comicRed : AppColors.comicGrayLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tier['badge'] as String,
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AppColors.comicBlack,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tier['desc'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(tier['price'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Quantity Stepper
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Number of Tickets', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.minus_cirlce, size: 22),
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.add_circle, size: 22, color: AppColors.comicRed),
                        onPressed: _quantity < 10 ? () => setState(() => _quantity++) : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stripe Payment Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'STRIPE SECURE PAYMENT',
                  style: AppTextStyles.comicSectionHeader.copyWith(
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.comicBlack,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF635BFF), // Stripe signature purple
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'stripe',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Card Information', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cardNumberController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Iconsax.card, color: AppColors.comicRed),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text('VISA', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1A1F71))),
                      ),
                      hintText: 'Card Number',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _expiryController,
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _cvcController,
                          decoration: InputDecoration(
                            hintText: 'CVC',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Cardholder Name',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Iconsax.lock, size: 14, color: AppColors.success),
                      SizedBox(width: 6),
                      Text('256-bit SSL encrypted • Stripe Certified Gateway',
                          style: TextStyle(fontSize: 10, color: AppColors.comicGray)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Order Total Summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tickets Subtotal ($_quantity x \$${_unitPrice.toStringAsFixed(0)})',
                          style: const TextStyle(fontSize: 12)),
                      Text('\$${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stripe Processing Fee', style: TextStyle(fontSize: 12)),
                      Text('\$3.50', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.comicRed),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pay Button
            SkewedButton(
              text: _isProcessing
                  ? 'PROCESSING PAYMENT...'
                  : 'PAY \$${_total.toStringAsFixed(2)} VIA STRIPE',
              icon: _isProcessing ? null : Iconsax.lock,
              height: 54,
              fontSize: 14,
              backgroundColor: AppColors.comicRed,
              onPressed: _isProcessing ? null : _processStripePayment,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

