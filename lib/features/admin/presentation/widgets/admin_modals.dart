import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class AdminModals {
  AdminModals._();

  // Modal 16: Admin Delete Confirmation Barrier ("Type 'DELETE' to confirm removal")
  static void showDeleteBarrierDialog({
    required BuildContext context,
    required String itemName,
    required VoidCallback onConfirmed,
  }) {
    final controller = TextEditingController();
    bool canDelete = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161B26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
              ),
              title: const Row(
                children: [
              Icon(Iconsax.warning_2, color: AppColors.error, size: 24),
                  SizedBox(width: 8),
                  Text('Destructive Action', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to permanently delete "$itemName"? This cannot be undone.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Type "DELETE" below to unlock removal:',
                    style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                    onChanged: (val) {
                      setModalState(() {
                        canDelete = val.trim() == 'DELETE';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      hintStyle: const TextStyle(color: Colors.white30),
                      fillColor: const Color(0xFF0F131C),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canDelete ? AppColors.error : Colors.grey.withValues(alpha: 0.3),
                  ),
                  onPressed: canDelete
                      ? () {
                          Navigator.of(ctx).pop();
                          onConfirmed();
                        }
                      : null,
                  child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Modal 17: Admin Audit Log Viewer Bottom Sheet
  static void showAuditLogsSheet({
    required BuildContext context,
    required List<Map<String, dynamic>> logs,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF131722),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Iconsax.clock, color: AppColors.darkSecondary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Operations Audit Trail',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Chronological log of administrative actions, edits and broadcasts.',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const Divider(height: 24, color: Colors.white12),
              Expanded(
                child: logs.isEmpty
                    ? const Center(
                        child: Text('No audit entries recorded yet.', style: TextStyle(color: Colors.white38)),
                      )
                    : ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final time = DateTime.fromMillisecondsSinceEpoch(
                            (log['timestamp'] as num?)?.toInt() ?? 0,
                          );
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.darkPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Iconsax.flash_1, color: AppColors.darkSecondary, size: 20),
                            ),
                            title: Text(
                              log['description'] ?? 'Admin action',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${log['admin_email']} • ${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log['action_type'] ?? 'OP',
                                style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Modal 18: Fast Stock Update Dialog
  static void showFastStockUpdateDialog({
    required BuildContext context,
    required String productName,
    required int currentStock,
    required ValueChanged<int> onStockUpdated,
  }) {
    int stock = currentStock;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF161B26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Fast Stock Restock', style: TextStyle(color: Colors.white, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.white10),
                        icon: const Icon(Iconsax.minus_square, color: Colors.white),
                        onPressed: stock > 0
                            ? () => setModalState(() => stock--)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$stock',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkAccentGold,
                          ),
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.white10),
                        icon: const Icon(Iconsax.add_square, color: Colors.white),
                        onPressed: () => setModalState(() => stock++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => setModalState(() => stock += 5),
                        child: const Text('+5'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => setModalState(() => stock += 10),
                        child: const Text('+10'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onStockUpdated(stock);
                  },
                  child: const Text('Save Stock', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Modal 19: Broadcast Notification Modal
  static void showBroadcastModal({
    required BuildContext context,
    required void Function(String title, String message, String audience) onBroadcastSent,
  }) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String audience = 'All Fans (1,240 Registered)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF131722),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Iconsax.notification_bing, color: AppColors.darkSecondary, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Broadcast Push Notification',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: titleController,
                  label: 'Alert Title',
                  hintText: 'e.g. Summer Fandom Festival Tickets Live!',
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: messageController,
                  label: 'Message Body',
                  hintText: 'Dispatched in real-time to active app users...',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Target Audience Segment',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F2C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButton<String>(
                    value: audience,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1F2C),
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: 'All Fans (1,240 Registered)', child: Text('All Fans (1,240 Registered)')),
                      DropdownMenuItem(value: 'Anime & Manga Enthusiasts', child: Text('Anime & Manga Enthusiasts')),
                      DropdownMenuItem(value: 'Gaming & Speedrunning Hub', child: Text('Gaming & Speedrunning Hub')),
                      DropdownMenuItem(value: 'Comic Con Ticket Holders', child: Text('Comic Con Ticket Holders')),
                    ],
                    onChanged: (val) {
                      if (val != null) audience = val;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SkewedButton(
                  text: 'Simulate Push Dispatch',
                  icon: Iconsax.send_1,
                  height: 52,
                  fontSize: 13,
                  backgroundColor: AppColors.darkPrimary,
                  onPressed: () {
                    final t = titleController.text.trim();
                    final m = messageController.text.trim();
                    if (t.isNotEmpty && m.isNotEmpty) {
                      Navigator.of(ctx).pop();
                      onBroadcastSent(t, m, audience);
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}


