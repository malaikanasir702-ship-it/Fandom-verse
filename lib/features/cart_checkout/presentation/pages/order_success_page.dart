import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/order_invoice_entity.dart';
import '../../../../core/services/notification_service.dart';

class OrderSuccessPage extends StatefulWidget {
  final OrderInvoiceEntity invoice;

  const OrderSuccessPage({super.key, required this.invoice});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  @override
  void initState() {
    super.initState();
    // Fire order confirmation push notification
    NotificationService.showOrderConfirmation(
      orderId: widget.invoice.orderId,
      total: widget.invoice.totalAmount,
    );
  }

  OrderInvoiceEntity get invoice => widget.invoice;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pushReplacementNamed('/store');
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Text(
            'Official Bill Invoice',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.close_circle),
              onPressed: () => Navigator.of(context).pushReplacementNamed('/store'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Badge Animation
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.success, width: 2),
                ),
                child: const Center(
                  child: Icon(Iconsax.tick_square, color: AppColors.success, size: 40),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'Order Confirmed!',
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Order ID: #${invoice.orderId}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 20),

              // Scannable Simulated QR Code Card
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: _QrCodePainter(data: 'FANDOMVERSE:${invoice.orderId}:${invoice.totalAmount}'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Scan at Convention Booth for Express Pickup',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Itemized Bill Table Card
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'INVOICE RECEIPT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PAID',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _buildInfoRow('Order Date', invoice.orderDate.toString().split('.')[0], isDark),
                    _buildInfoRow('Payment Mode', invoice.paymentMethod, isDark),
                    _buildInfoRow('Shipping Address', invoice.shippingAddress, isDark),

                    const Divider(height: 20),

                    const Text(
                      'Purchased Items',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    ...invoice.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item['quantity']}x',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item['name']} (${item['variant']})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '\$${((item['price'] as num) * (item['quantity'] as num)).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(height: 20),

                    _buildCostRow('Merchandise Subtotal', '\$${invoice.subtotal.toStringAsFixed(2)}', isDark),
                    if (invoice.discountAmount > 0)
                      _buildCostRow(
                        'Coupon Discount (${invoice.appliedCoupon})',
                        '-\$${invoice.discountAmount.toStringAsFixed(2)}',
                        isDark,
                        isHighlight: true,
                      ),
                    _buildCostRow(
                      'Shipping Fee',
                      invoice.shippingFee == 0 ? 'FREE' : '\$${invoice.shippingFee.toStringAsFixed(2)}',
                      isDark,
                      isFree: invoice.shippingFee == 0,
                    ),
                    _buildCostRow('Estimated Sales Tax', '\$${invoice.taxAmount.toStringAsFixed(2)}', isDark),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Paid',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '\$${invoice.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isDark ? AppColors.darkAccentGold : AppColors.lightAccentGold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SkewedButton(
                      text: 'Export PDF',
                      icon: Iconsax.document_download,
                      height: 52,
                      fontSize: 12,
                      backgroundColor: AppColors.comicGray,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invoice #${invoice.orderId} exported to PDF!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SkewedButton(
                      text: 'Back to Store',
                      icon: Iconsax.shop,
                      height: 52,
                      fontSize: 12,
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/store');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextButton.icon(
                icon: const Icon(Iconsax.clock, size: 18),
                label: const Text('View All Past Orders'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/order-history');
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value, bool isDark, {bool isHighlight = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isHighlight
                  ? AppColors.success
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFree
                  ? AppColors.success
                  : (isHighlight
                      ? AppColors.success
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrCodePainter extends CustomPainter {
  final String data;
  _QrCodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final step = size.width / 15;

    // Corner squares (Finder patterns)
    _drawFinderPattern(canvas, 0, 0, step, paint);
    _drawFinderPattern(canvas, size.width - (4 * step), 0, step, paint);
    _drawFinderPattern(canvas, 0, size.height - (4 * step), step, paint);

    // Simulated QR barcode matrix
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        // Skip corner finder boxes
        if ((i < 5 && j < 5) || (i > 9 && j < 5) || (i < 5 && j > 9)) continue;
        if ((i * 7 + j * 13 + data.hashCode) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i * step, j * step, step * 0.85, step * 0.85),
            paint,
          );
        }
      }
    }
  }

  void _drawFinderPattern(Canvas canvas, double x, double y, double step, Paint paint) {
    canvas.drawRect(Rect.fromLTWH(x, y, step * 4, step * 4), paint);
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(x + step * 0.7, y + step * 0.7, step * 2.6, step * 2.6), whitePaint);
    canvas.drawRect(Rect.fromLTWH(x + step * 1.3, y + step * 1.3, step * 1.4, step * 1.4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


