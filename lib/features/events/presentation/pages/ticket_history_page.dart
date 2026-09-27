import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/ticket_entity.dart';
import '../widgets/ticket_qr_code_widget.dart';
import 'ticket_detail_page.dart';

class TicketHistoryPage extends StatefulWidget {
  const TicketHistoryPage({super.key});

  @override
  State<TicketHistoryPage> createState() => _TicketHistoryPageState();
}

class _TicketHistoryPageState extends State<TicketHistoryPage> {
  List<TicketEntity> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    setState(() => _isLoading = true);
    final userId = context.read<AuthBloc>().currentUser?.id;
    List<TicketEntity> list = [];
    if (userId != null && userId.isNotEmpty) {
      list = await SqliteHelper.instance.getTicketsByUser(userId);
    }
    // If user has none or logged in as guest, also check allTickets
    if (list.isEmpty) {
      list = await SqliteHelper.instance.getAllTickets();
    }
    if (mounted) {
      setState(() {
        _tickets = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TICKET HISTORY',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0),
            ),
            if (_tickets.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.comicRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_tickets.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.comicRed),
            )
          : RefreshIndicator(
              color: AppColors.comicRed,
              onRefresh: _loadTickets,
              child: _tickets.isEmpty
                  ? _buildEmptyState(context, isDark)
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return _buildTicketHistoryCard(context, ticket, isDark);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.comicGrayLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.comicBorderColor, width: 2),
                ),
                child: const Icon(Iconsax.ticket, size: 48, color: AppColors.comicGray),
              ),
              const SizedBox(height: 20),
              const Text(
                'NO TICKETS PURCHASED YET',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Book event passes for upcoming conventions, cosplays, and tournaments with instant Stripe checkout.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: AppColors.comicGray, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: SkewedButton(
                  text: 'EXPLORE EVENTS',
                  icon: Iconsax.calendar_1,
                  backgroundColor: AppColors.comicRed,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTicketHistoryCard(
    BuildContext context,
    TicketEntity ticket,
    bool isDark,
  ) {
    final dateStr = ticket.eventDate > 0
        ? DateFormat('EEE, MMM d, y').format(
            DateTime.fromMillisecondsSinceEpoch(ticket.eventDate))
        : 'TBA';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TicketDetailPage(ticket: ticket),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.comicYellow : AppColors.comicBlack,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : AppColors.comicBlack,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF252730) : AppColors.comicBlack,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.eventTitle.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.comicYellow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ticket.tierTitle.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.comicBlack,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Mini QR thumbnail
                  TicketQrCodeWidget(
                    qrData: ticket.qrData,
                    size: 72,
                    showBorder: true,
                  ),
                  const SizedBox(width: 14),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.calendar_1, size: 12, color: AppColors.comicGray),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Iconsax.location, size: 12, color: AppColors.comicGray),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${ticket.venueName}, ${ticket.cityName}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.comicGray,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${ticket.quantity} Pass(es)',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${ticket.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.comicRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'VIEW TICKET PASS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.comicYellow : AppColors.comicRed,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Iconsax.arrow_right_3,
                              size: 10,
                              color: isDark ? AppColors.comicYellow : AppColors.comicRed,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
