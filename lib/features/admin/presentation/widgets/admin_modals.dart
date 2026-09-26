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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              title: const Row(
                children: [
                  Icon(Iconsax.warning_2, color: AppColors.error, size: 24),
                  SizedBox(width: 8),
                  Text('Destructive Action', style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Are you sure you want to permanently delete "$itemName"? This cannot be undone.',
                    style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Type "DELETE" below to unlock removal:',
                    style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: AppColors.adminLightTextPrimary, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    onChanged: (val) {
                      setModalState(() {
                        canDelete = val.trim() == 'DELETE';
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'DELETE',
                      hintStyle: const TextStyle(color: AppColors.adminLightTextMuted),
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.adminLightTextSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canDelete ? AppColors.error : Colors.grey.shade300,
                  ),
                  onPressed: canDelete
                      ? () {
                          Navigator.of(ctx).pop();
                          onConfirmed();
                        }
                      : null,
                  child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            color: Colors.white,
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
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Iconsax.clock, color: Color(0xFF2563EB), size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Operations Audit Trail',
                    style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Chronological log of administrative actions, edits and broadcasts.',
                style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
              ),
              const Divider(height: 24, color: AppColors.adminLightBorder),
              Expanded(
                child: logs.isEmpty
                    ? const Center(
                        child: Text('No audit entries recorded yet.', style: TextStyle(color: AppColors.adminLightTextMuted)),
                      )
                    : ListView.separated(
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const Divider(color: AppColors.adminLightBorder),
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
                                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Iconsax.flash_1, color: Color(0xFF2563EB), size: 20),
                            ),
                            title: Text(
                              log['description'] ?? 'Admin action',
                              style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${log['admin_email']} • ${time.hour}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
                              style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 10),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log['action_type'] ?? 'OP',
                                style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 9, fontWeight: FontWeight.bold),
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
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Fast Stock Restock', style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    productName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
                        icon: const Icon(Iconsax.minus_square, color: AppColors.adminLightTextPrimary),
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
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
                        icon: const Icon(Iconsax.add_square, color: AppColors.adminLightTextPrimary),
                        onPressed: () => setModalState(() => stock++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.adminLightBorder),
                          foregroundColor: AppColors.adminLightTextPrimary,
                        ),
                        onPressed: () => setModalState(() => stock += 5),
                        child: const Text('+5'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.adminLightBorder),
                          foregroundColor: AppColors.adminLightTextPrimary,
                        ),
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
                  child: const Text('Cancel', style: TextStyle(color: AppColors.adminLightTextSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.comicRed),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onStockUpdated(stock);
                  },
                  child: const Text('Save Stock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              color: Colors.white,
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
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Iconsax.notification_bing, color: Color(0xFF2563EB), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Broadcast Push Notification',
                      style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
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
                  style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.adminLightBorder),
                  ),
                  child: DropdownButton<String>(
                    value: audience,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
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
                  backgroundColor: AppColors.comicRed,
                  textColor: Colors.white,
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
