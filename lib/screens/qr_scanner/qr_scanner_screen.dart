import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../transfer/transfer_screen.dart';
import '../../theme/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleQRCode(String? code) {
    if (code == null || code.isEmpty) return;

    // Parse QR code data (assuming format: accountNumber:amount or just accountNumber)
    final parts = code.split(':');
    String? accountNumber;
    String? amount;

    if (parts.isNotEmpty) {
      accountNumber = parts[0].trim();
    }
    if (parts.length >= 2) {
      amount = parts[1].trim();
    }

    // Navigate to transfer screen with scanned data
    if (accountNumber != null && accountNumber.isNotEmpty) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransferScreen(
            prefillAccountNumber: accountNumber,
            prefillAmount: amount,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR code format'),
          backgroundColor: AppTheme.textSecondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.lightBackground,
        elevation: 0,
        toolbarHeight: 60,
        leadingWidth: 70,
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.surfaceColor,
            size: 24,
          ),
          onPressed: () {
            Navigator.maybePop(context);
          },
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: AppTheme.surfaceColor),
            onPressed: () {
              controller.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: AppTheme.surfaceColor),
            onPressed: () => controller.switchCamera(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.account_balance,
              color: AppTheme.surfaceColor,
              size: 28,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (barcode) {
              if (barcode.barcodes.isNotEmpty) {
                final code = barcode.barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  _handleQRCode(code);
                }
              }
            },
          ),
          // Overlay with scanning frame
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 16,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: 250,
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppTheme.textPrimary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: AppTheme.surfaceColor,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Position QR code within the frame',
                    style: TextStyle(
                      color: AppTheme.surfaceColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan a QR code to transfer money to another account',
                    style: TextStyle(
                      color: AppTheme.surfaceColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom overlay shape for QR scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = AppTheme.accentOrange,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutSizeFinal = cutOutSize < width || cutOutSize < height
        ? (width < height ? width : height) * 0.8
        : cutOutSize;

    final cutOutLeft = (width - cutOutSizeFinal) / 2;
    final cutOutTop = (height - cutOutSizeFinal) / 2;
    final cutOutRight = cutOutLeft + cutOutSizeFinal;
    final cutOutBottom = cutOutTop + cutOutSizeFinal;

    // Draw overlay
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(rect.left, rect.top, width, height));

    final cutOutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(cutOutLeft, cutOutTop, cutOutRight, cutOutBottom),
          Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final backgroundWithCutOut = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutOutPath,
    );

    canvas.drawPath(backgroundWithCutOut, backgroundPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final borderPath = Path()
      // Top left corner
      ..moveTo(cutOutLeft, cutOutTop + borderLength)
      ..lineTo(cutOutLeft, cutOutTop + borderRadius)
      ..quadraticBezierTo(
          cutOutLeft, cutOutTop, cutOutLeft + borderRadius, cutOutTop)
      ..lineTo(cutOutLeft + borderLength, cutOutTop)
      // Top right corner
      ..moveTo(cutOutRight - borderLength, cutOutTop)
      ..lineTo(cutOutRight - borderRadius, cutOutTop)
      ..quadraticBezierTo(
          cutOutRight, cutOutTop, cutOutRight, cutOutTop + borderRadius)
      ..lineTo(cutOutRight, cutOutTop + borderLength)
      // Bottom right corner
      ..moveTo(cutOutRight, cutOutBottom - borderLength)
      ..lineTo(cutOutRight, cutOutBottom - borderRadius)
      ..quadraticBezierTo(
          cutOutRight, cutOutBottom, cutOutRight - borderRadius, cutOutBottom)
      ..lineTo(cutOutRight - borderLength, cutOutBottom)
      // Bottom left corner
      ..moveTo(cutOutLeft + borderLength, cutOutBottom)
      ..lineTo(cutOutLeft + borderRadius, cutOutBottom)
      ..quadraticBezierTo(
          cutOutLeft, cutOutBottom, cutOutLeft, cutOutBottom - borderRadius)
      ..lineTo(cutOutLeft, cutOutBottom - borderLength);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
