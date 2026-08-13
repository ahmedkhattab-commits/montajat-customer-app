import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean8,
      BarcodeFormat.ean13,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.code128,
      BarcodeFormat.itf14,
      BarcodeFormat.qrCode,
    ],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value == null || value.isEmpty) continue;
      _handled = true;
      _controller.stop();
      Navigator.pop(context, value);
      return;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: Text(context.tr('products_listing.scan_title')),
      centerTitle: true,
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      actions: [
        IconButton(
          tooltip: context.tr('products_listing.toggle_flash'),
          onPressed: _controller.toggleTorch,
          icon: const Icon(Icons.flash_on_rounded),
        ),
      ],
    ),
    body: Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(controller: _controller, onDetect: _onDetect),
        IgnorePointer(
          child: Container(
            decoration: ShapeDecoration(
              shape: _ScannerOverlayShape(
                borderColor: AppColors.onboardingPrimary,
                borderRadius: 16.r,
                borderLength: 32.w,
                borderWidth: 4.w,
                cutOutSize: 275.w,
              ),
            ),
          ),
        ),
        Positioned(
          left: 24.w,
          right: 24.w,
          bottom: 55.h,
          child: Text(
            context.tr('products_listing.scan_hint'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
        ),
      ],
    ),
  );
}

class _ScannerOverlayShape extends ShapeBorder {
  const _ScannerOverlayShape({
    required this.borderColor,
    required this.borderRadius,
    required this.borderLength,
    required this.borderWidth,
    required this.cutOutSize,
  });

  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {ui.TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {ui.TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {ui.TextDirection? textDirection}) {
    final center = rect.center;
    final scanRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );
    final overlay = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect)
      ..addRRect(
        RRect.fromRectAndRadius(scanRect, Radius.circular(borderRadius)),
      );
    canvas.drawPath(overlay, Paint()..color = Colors.black54);

    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final r = borderRadius;
    final l = borderLength;
    for (final path in [
      Path()
        ..moveTo(scanRect.left, scanRect.top + l)
        ..lineTo(scanRect.left, scanRect.top + r)
        ..quadraticBezierTo(
          scanRect.left,
          scanRect.top,
          scanRect.left + r,
          scanRect.top,
        )
        ..lineTo(scanRect.left + l, scanRect.top),
      Path()
        ..moveTo(scanRect.right - l, scanRect.top)
        ..lineTo(scanRect.right - r, scanRect.top)
        ..quadraticBezierTo(
          scanRect.right,
          scanRect.top,
          scanRect.right,
          scanRect.top + r,
        )
        ..lineTo(scanRect.right, scanRect.top + l),
      Path()
        ..moveTo(scanRect.right, scanRect.bottom - l)
        ..lineTo(scanRect.right, scanRect.bottom - r)
        ..quadraticBezierTo(
          scanRect.right,
          scanRect.bottom,
          scanRect.right - r,
          scanRect.bottom,
        )
        ..lineTo(scanRect.right - l, scanRect.bottom),
      Path()
        ..moveTo(scanRect.left + l, scanRect.bottom)
        ..lineTo(scanRect.left + r, scanRect.bottom)
        ..quadraticBezierTo(
          scanRect.left,
          scanRect.bottom,
          scanRect.left,
          scanRect.bottom - r,
        )
        ..lineTo(scanRect.left, scanRect.bottom - l),
    ]) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  ShapeBorder scale(double t) => this;
}
