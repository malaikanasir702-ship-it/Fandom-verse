import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/event_entity.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_event.dart';

class EventDetailPage extends StatefulWidget {
  final EventEntity event;
  const EventDetailPage({super.key, required this.event});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late Duration _timeLeft;
  late bool _rsvped;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.event.eventDate.difference(DateTime.now());
    _rsvped = widget.event.isRsvped;
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return 'Event has passed';
    return '${d.inDays}d ${d.inHours.remainder(24)}h ${d.inMinutes.remainder(60)}m';
  }

  void _showRsvpConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_rsvped ? 'Cancel RSVP?' : 'RSVP Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_rsvped
                ? 'Remove yourself from the attendees list for ${widget.event.title}?'
                : 'Simulated RSVP registration for:\n\n${widget.event.title}\n${widget.event.cityName}'),
            if (!_rsvped) ...[
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(Iconsax.calendar_tick, size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Text('Event added to your calendar', style: TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _rsvped = !_rsvped);
              context.read<EventCalendarBloc>().add(ToggleEventRsvpEvent(widget.event.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_rsvped ? 'RSVP removed.' : 'RSVP Confirmed! Added to your calendar.'),
                  backgroundColor: _rsvped ? AppColors.error : AppColors.success,
                ),
              );
            },
            child: Text(_rsvped ? 'Remove RSVP' : 'Confirm RSVP'),
          ),
        ],
      ),
    );
  }

  void _showDirectionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
              children: [
                Icon(Iconsax.location, size: 18, color: AppColors.comicRed),
                SizedBox(width: 8),
                Text('Venue Directions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.event.venueName, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${widget.event.latitude.toStringAsFixed(4)}, Lng: ${widget.event.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Iconsax.copy, size: 16),
                      label: const Text('Copy Coordinates'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: '${widget.event.latitude},${widget.event.longitude}',
                        ));
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coordinates copied!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Iconsax.direct_right, size: 16),
                      label: const Text('Open Maps'),
                      onPressed: () async {
                        final url = Uri.parse(
                          'https://maps.google.com/?q=${widget.event.latitude},${widget.event.longitude}',
                        );
                        if (await canLaunchUrl(url)) await launchUrl(url);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('EEEE, MMMM dd, yyyy').format(widget.event.eventDate);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Banner
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.event.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.darkSurface),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & RSVP status
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.darkPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.darkPrimary.withValues(alpha: 0.3)),
                        ),
                        child: Text(widget.event.category,
                            style: const TextStyle(color: AppColors.darkPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                      if (_rsvped) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.tick_circle, size: 12, color: AppColors.success),
                              SizedBox(width: 4),
                              Text('RSVP\'d', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(widget.event.title, style: AppTextStyles.displaySmall.copyWith(height: 1.2)),
                  const SizedBox(height: 8),

                  // Location & date info
                  Row(
                    children: [
                      const Icon(Iconsax.location, size: 16, color: AppColors.comicRed),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.event.venueName,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.comicRed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1, size: 16),
                      const SizedBox(width: 6),
                      Text(dateStr, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.people, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${NumberFormat.compact().format(widget.event.attendeesCount)} attendees registered',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),

                  // ─── Countdown Timer ───
                  const SizedBox(height: 20),
                  GlassContainer(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.comicRed.withValues(alpha: 0.35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Iconsax.timer_1, size: 16, color: AppColors.comicRed),
                                SizedBox(width: 6),
                                Text('Event Countdown', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDuration(_timeLeft),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                color: AppColors.comicRed,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Iconsax.timer_1, size: 36, color: AppColors.comicRed),
                      ],
                    ),
                  ),

                  // ─── Description ───
                  const SizedBox(height: 20),
                  Text('About This Event', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    widget.event.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.6,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),

                  // ─── Action Buttons ───
                  const SizedBox(height: 24),
                  CustomButton(
                    text: _rsvped ? 'Cancel RSVP' : 'RSVP for this Event',
                    onPressed: _showRsvpConfirmation,
                    backgroundColor: _rsvped ? AppColors.error : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Directions',
                          isOutlined: true,
                          icon: Iconsax.direct_right,
                          onPressed: _showDirectionsSheet,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Buy Tickets',
                          isOutlined: false,
                          icon: Iconsax.ticket,
                          backgroundColor: AppColors.comicRed,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/stripe-ticket-checkout',
                              arguments: widget.event,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

