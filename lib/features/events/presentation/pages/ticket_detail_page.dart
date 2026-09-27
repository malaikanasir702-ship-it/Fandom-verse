import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../domain/entities/ticket_entity.dart';
import '../widgets/ticket_qr_code_widget.dart';

class TicketDetailPage extends StatelessWidget {
  final TicketEntity ticket;

  const TicketDetailPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = ticket.eventDate > 0
        ? DateFormat('EEEE, MMMM d, y').format(
            DateTime.fromMillisecondsSinceEpoch(ticket.eventDate))
        : 'Date Announced Soon';

    final purchaseDateStr = ticket.purchasedAt > 0
        ? DateFormat('MMM d, y • h:mm a').format(
            DateTime.fromMillisecondsSinceEpoch(ticket.purchasedAt))
        : 'Recently';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('E-TICKET PASS',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ─── TICKET CARD ───
            _buildTicketCard(context, isDark, dateStr, purchaseDateStr),
            const SizedBox(height: 24),

            // ─── ACTION BUTTONS ───
            Row(
              children: [
                Expanded(
                  child: SkewedButton(
                    text: 'DONE',
                    icon: Iconsax.tick_circle,
                    backgroundColor: AppColors.comicRed,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    bool isDark,
    String dateStr,
    String purchaseDateStr,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.comicYellow : AppColors.comicBlack,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : AppColors.comicBlack,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Top Header: Event & Banner ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252730) : AppColors.comicBlack,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.comicRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.ticket, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.eventTitle.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.location, size: 12, color: AppColors.comicYellow),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${ticket.venueName}, ${ticket.cityName}',
                              style: const TextStyle(
                                color: Color(0xFFD1D5DB),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── Ticket Details Body ───
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Pass Tier Badge Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.comicYellow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.comicBlack, width: 1.2),
                      ),
                      child: Text(
                        ticket.tierTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.comicBlack,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.verify, size: 13, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            ticket.status.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Info Grid
                _buildInfoRow('Event Date', dateStr, isDark),
                const SizedBox(height: 10),
                _buildInfoRow('Attendee', ticket.attendeeName, isDark),
                const SizedBox(height: 10),
                _buildInfoRow('Quantity', '${ticket.quantity} Pass(es)', isDark),
                const SizedBox(height: 10),
                _buildInfoRow(
                  'Total Paid',
                  '\$${ticket.totalAmount.toStringAsFixed(2)} (${ticket.paymentMethod})',
                  isDark,
                  isHighlight: true,
                ),
                const SizedBox(height: 10),
                _buildInfoRow('Purchased', purchaseDateStr, isDark),
              ],
            ),
          ),

          // ─── Notched Perforation Divider ───
          _buildPerforationDivider(context, isDark),

          // ─── Bottom Stub: Real QR Code & Scan Info ───
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'SCAN FOR VENUE ADMISSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: AppColors.comicGray,
                  ),
                ),
                const SizedBox(height: 14),
                // Real Live QR Code
                TicketQrCodeWidget(
                  qrData: ticket.qrData,
                  size: 160,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252730) : AppColors.comicGrayLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.comicBorderColor),
                  ),
                  child: Text(
                    ticket.ticketId,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.comicRed,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (ticket.paymentIntentId != null &&
                    ticket.paymentIntentId!.isNotEmpty)
                  Text(
                    'Stripe Ref: ${ticket.paymentIntentId}',
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.comicGray,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark,
      {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.comicGray,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
            color: isHighlight
                ? AppColors.comicRed
                : (isDark ? Colors.white : AppColors.comicBlack),
          ),
        ),
      ],
    );
  }

  Widget _buildPerforationDivider(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Left cutout notch
        Container(
          width: 14,
          height: 28,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
            border: Border.all(
              color: isDark ? AppColors.comicYellow : AppColors.comicBlack,
              width: 1.5,
            ),
          ),
        ),
        // Dashed line
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dashWidth = 6.0;
                const dashSpace = 4.0;
                final count = (constraints.constrainWidth() / (dashWidth + dashSpace)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(count, (_) {
                    return SizedBox(
                      width: dashWidth,
                      height: 1.5,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
        // Right cutout notch
        Container(
          width: 14,
          height: 28,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : const Color(0xFFF3F4F6),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
            border: Border.all(
              color: isDark ? AppColors.comicYellow : AppColors.comicBlack,
              width: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
