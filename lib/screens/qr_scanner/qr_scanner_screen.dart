import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../transfer/transfer_screen.dart';
import '../../theme/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  final ImagePicker _imagePicker = ImagePicker();

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

  Future<void> _uploadQRCode() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image == null) return;

      // Use the controller's analyzeImage method
      // This will process the image and trigger onDetect if a barcode is found
      await controller.analyzeImage(image.path);
      
      // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Processing QR code from image...'),
            backgroundColor: AppTheme.accentOrange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError('Error reading QR code: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
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
          // Blue overlay with scanning frame
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Colors.blue,
                frameColor: Colors.white,
                borderRadius: 8,
                borderLength: 40,
                borderWidth: 4,
                cutOutSize: 280,
              ),
            ),
          ),
          // Instructions at the top
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Place an QR at the center of your camera and the QR will be automatically scanned.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Text in scanning area - Payment Accepted Here
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4 - 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Payment Accepted Here',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'scan here to pay',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Closer indicator below scanning area
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4 + 160,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Closer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Upload QR Code Button (positioned above flashlight)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _uploadQRCode,
                icon: const Icon(Icons.upload_file, size: 20),
                label: const Text(
                  'Upload QR Code',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
          // Flashlight button at bottom center
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.flashlight_on, size: 28),
                  color: Colors.white,
                  onPressed: () {
                    controller.toggleTorch();
                  },
                ),
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
  final Color frameColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.blue,
    this.frameColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(33, 150, 243, 200), // Blue overlay
    this.borderRadius = 8,
    this.borderLength = 40,
    this.cutOutSize = 280,
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

    // Draw white frame
    final framePaint = Paint()
      ..color = frameColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cutOutLeft, cutOutTop, cutOutRight, cutOutBottom),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(frameRect, framePaint);

    // Draw blue corner brackets
    final cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final cornerLength = borderLength;
    
    // Top left corner
    canvas.drawLine(
      Offset(cutOutLeft, cutOutTop + cornerLength),
      Offset(cutOutLeft, cutOutTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutLeft, cutOutTop),
      Offset(cutOutLeft + cornerLength, cutOutTop),
      cornerPaint,
    );
    
    // Top right corner
    canvas.drawLine(
      Offset(cutOutRight - cornerLength, cutOutTop),
      Offset(cutOutRight, cutOutTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRight, cutOutTop),
      Offset(cutOutRight, cutOutTop + cornerLength),
      cornerPaint,
    );
    
    // Bottom right corner
    canvas.drawLine(
      Offset(cutOutRight, cutOutBottom - cornerLength),
      Offset(cutOutRight, cutOutBottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutRight, cutOutBottom),
      Offset(cutOutRight - cornerLength, cutOutBottom),
      cornerPaint,
    );
    
    // Bottom left corner
    canvas.drawLine(
      Offset(cutOutLeft + cornerLength, cutOutBottom),
      Offset(cutOutLeft, cutOutBottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutOutLeft, cutOutBottom),
      Offset(cutOutLeft, cutOutBottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      frameColor: frameColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}
