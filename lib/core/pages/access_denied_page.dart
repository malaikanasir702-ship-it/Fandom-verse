import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/skewed_button.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.comicBlack,
      appBar: AppBar(
        title: const Text('Access Denied', style: TextStyle(color: AppColors.comicWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.comicBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.comicWhite),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/fan-home');
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.comicRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.shield_tick,
                  size: 48,
                  color: AppColors.comicWhite,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.comicWhite,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You do not have administrator permissions to view this page. This area is reserved exclusively for Fandom Verse administrators.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkTextSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SkewedButton(
                text: 'Return to Fan Hub',
                icon: Iconsax.home_2,
                height: 52,
                fontSize: 14,
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/fan-home', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
