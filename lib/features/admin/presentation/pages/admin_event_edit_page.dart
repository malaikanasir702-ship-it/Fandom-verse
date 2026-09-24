import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class AdminEventEditPage extends StatefulWidget {
  final Map<String, dynamic>? existingEvent;

  const AdminEventEditPage({super.key, this.existingEvent});

  @override
  State<AdminEventEditPage> createState() => _AdminEventEditPageState();
}

class _AdminEventEditPageState extends State<AdminEventEditPage> {
  final _titleController = TextEditingController();
  final _cityController = TextEditingController(text: 'Tokyo');
  final _venueController = TextEditingController();
  final _latController = TextEditingController(text: '35.6298');
  final _lngController = TextEditingController(text: '139.7942');
  final _ticketUrlController = TextEditingController(text: 'https://tickets.fandomverse.com');
  final _bannerController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      final ev = widget.existingEvent!;
      _titleController.text = ev['title'] ?? '';
      _cityController.text = ev['city_name'] ?? '';
      _venueController.text = ev['venue_name'] ?? '';
      _latController.text = (ev['latitude'] ?? 0.0).toString();
      _lngController.text = (ev['longitude'] ?? 0.0).toString();
      _ticketUrlController.text = ev['ticket_link'] ?? '';
      _bannerController.text = ev['banner_url'] ?? '';
      _descController.text = ev['description'] ?? '';
    } else {
      _bannerController.text = 'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _venueController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _ticketUrlController.dispose();
    _bannerController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingEvent != null;

    return Scaffold(
      backgroundColor: const Color(0xFF090C12),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Convention' : 'Schedule New Convention',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Convention / Expo Title',
              hintText: 'e.g. World Otaku Summit & Anime Expo 2026',
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cityController,
                    label: 'Host City',
                    hintText: 'e.g. Tokyo, San Diego, London',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _venueController,
                    label: 'Exhibition Hall / Venue',
                    hintText: 'e.g. Big Sight Arena',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _latController,
                    label: 'GPS Latitude',
                    hintText: '35.6298',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _lngController,
                    label: 'GPS Longitude',
                    hintText: '139.7942',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _ticketUrlController,
              label: 'Official Ticketing Web Link',
              hintText: 'https://...',
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _bannerController,
              label: 'High-Res Event Banner URL',
              hintText: 'https://images.unsplash.com/...',
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _descController,
              label: 'Convention Overview & Key Attractions',
              hintText: 'Panels, cosplay tournaments, creator guests, dealer hall details...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: isEdit ? 'Update Convention' : 'Publish to Global Event Radar',
              icon: Iconsax.radar,
              backgroundColor: AppColors.darkAccentGold,
              onPressed: () {
                final title = _titleController.text.trim();
                final city = _cityController.text.trim();

                if (title.isEmpty || city.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill title and city.')),
                  );
                  return;
                }

                final eventData = {
                  'event_id': isEdit
                      ? widget.existingEvent!['event_id']
                      : 'evt-${DateTime.now().millisecondsSinceEpoch}',
                  'title': title,
                  'city_name': city,
                  'venue_name': _venueController.text.trim(),
                  'latitude': double.tryParse(_latController.text.trim()) ?? 35.6298,
                  'longitude': double.tryParse(_lngController.text.trim()) ?? 139.7942,
                  'event_date': DateTime.now().add(const Duration(days: 90)).millisecondsSinceEpoch,
                  'ticket_link': _ticketUrlController.text.trim(),
                  'banner_url': _bannerController.text.trim(),
                  'description': _descController.text.trim(),
                  'is_bookmarked': 0,
                };

                context.read<AdminBloc>().add(
                      CreateOrUpdateEventEvent(eventData, isEdit: isEdit),
                    );

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Convention updated!' : 'Convention published to Radar!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

