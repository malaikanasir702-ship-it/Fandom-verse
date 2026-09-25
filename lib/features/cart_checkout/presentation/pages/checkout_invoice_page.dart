import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/glass_container.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import 'order_success_page.dart';

class CheckoutInvoicePage extends StatefulWidget {
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final String appliedCoupon;

  const CheckoutInvoicePage({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.appliedCoupon,
  });

  @override
  State<CheckoutInvoicePage> createState() => _CheckoutInvoicePageState();
}

class _CheckoutInvoicePageState extends State<CheckoutInvoicePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  String _userId = 'fan-01';

  String _selectedPaymentMethod = 'Cash on Delivery';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().currentUser;
    _userId = user?.id ?? 'fan-01';
    _nameController = TextEditingController(text: user?.name ?? '');
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _phoneController = TextEditingController();
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'title': 'Cash on Delivery',
      'desc': 'Pay when your order arrives',
      'icon': Iconsax.shop,
    },
    {
      'title': 'Credit / Debit Card',
      'desc': 'Visa, Mastercard, or any debit card',
      'icon': Iconsax.card,
    },
    {
      'title': 'Fan Reward Points',
      'desc': 'Redeem your Otaku Lore XP Points',
      'icon': Iconsax.star_1,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderSuccessPage(invoice: state.invoice),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Text(
            'Checkout',
            style: AppTextStyles.headlineMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping Address Form
              Text(
                'Shipping Destination',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      prefixIcon: const Icon(Iconsax.profile_circle, size: 18),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _addressController,
                      label: 'Street Address',
                      prefixIcon: const Icon(Iconsax.location, size: 18),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _cityController,
                            label: 'City / Region',
                            prefixIcon: const Icon(Iconsax.buildings, size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Contact',
                            prefixIcon: const Icon(Iconsax.call, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment Method Picker
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ..._paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method['title'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedPaymentMethod = method['title']),
                    borderRadius: BorderRadius.circular(14),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(14),
                      borderRadius: 14,
                      borderColor: isSelected
                          ? (isDark ? AppColors.darkSecondary : AppColors.lightPrimary)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      backgroundColor: isSelected
                          ? (isDark ? AppColors.darkSecondary : AppColors.lightPrimary).withValues(alpha: 0.08)
                          : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                      child: Row(
                        children: [
                          Icon(
                            method['icon'] as IconData,
                            color: isSelected
                                ? (isDark ? AppColors.darkSecondary : AppColors.lightPrimary)
                                : Colors.grey,
                            size: 24,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['title'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  method['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            isSelected ? Iconsax.tick_circle : Iconsax.record_circle,
                            color: isSelected
                                ? (isDark ? AppColors.darkSecondary : AppColors.lightPrimary)
                                : Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Itemized Bill Summary Box
              Text(
                'Itemized Bill Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 10),
              GlassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: Column(
                  children: [
                    _buildBillRow('Merchandise Subtotal', '\$${widget.subtotal.toStringAsFixed(2)}', isDark),
                    if (widget.discountAmount > 0)
                      _buildBillRow(
                        'Coupon Savings (${widget.appliedCoupon})',
                        '-\$${widget.discountAmount.toStringAsFixed(2)}',
                        isDark,
                        isHighlight: true,
                      ),
                    _buildBillRow(
                      'Shipping & Handling',
                      widget.shippingFee == 0 ? 'FREE' : '\$${widget.shippingFee.toStringAsFixed(2)}',
                      isDark,
                      isFree: widget.shippingFee == 0,
                    ),
                    _buildBillRow('Estimated Sales Tax (8%)', '\$${widget.taxAmount.toStringAsFixed(2)}', isDark),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '\$${widget.totalAmount.toStringAsFixed(2)}',
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

              // Submit & Generate Invoice CTA
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  final isLoading = state is CartLoading;
                  return CustomButton(
                    text: 'Confirm & Generate Invoice Bill',
                    icon: Iconsax.receipt_1,
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    isLoading: isLoading,
                    onPressed: () {
                      final fullAddress =
                          '${_nameController.text.trim()}, ${_addressController.text.trim()}, ${_cityController.text.trim()} (Phone: ${_phoneController.text.trim()})';

                      context.read<CartBloc>().add(
                            ExecuteCheckoutEvent(
                              userId: _userId,
                              shippingAddress: fullAddress,
                              paymentMethod: _selectedPaymentMethod,
                            ),
                          );
                    },
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, bool isDark, {bool isHighlight = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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



