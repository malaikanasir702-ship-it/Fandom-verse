import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class TicketQrCodeWidget extends StatelessWidget {
  final String qrData;
  final double size;
  final bool showBorder;

  const TicketQrCodeWidget({
    super.key,
    required this.qrData,
    this.size = 140,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: showBorder
            ? Border.all(color: AppColors.comicBorderColor, width: 1.5)
            : null,
        boxShadow: showBorder
            ? const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: size,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF111216),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF111216),
        ),
      ),
    );
  }
}
