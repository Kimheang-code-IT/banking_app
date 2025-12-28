import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import 'scanned_data_verification_screen.dart';

class IdCardScannerScreen extends StatefulWidget {
  const IdCardScannerScreen({super.key});

  @override
  State<IdCardScannerScreen> createState() => _IdCardScannerScreenState();
}

class _IdCardScannerScreenState extends State<IdCardScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  final StorageService _storageService = StorageService();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _handleIdCardScan() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Simulate OCR processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock extracted data from ID card
    final mockExtractedData = {
      'name': 'John Doe',
      'idNumber': '123456789',
      'dateOfBirth': '1990-05-15',
    };

    // Save scanned data
    await _storageService.saveScannedIdData(mockExtractedData);
    await _storageService.setIdCardScanned(true);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // Navigate to scanned data verification screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScannedDataVerificationScreen(),
        ),
      );
    }
  }

  Future<void> _handleSkipScan() async {
    // Mark as scanned (even though we're skipping) so flow continues
    await _storageService.setIdCardScanned(true);

    // Save empty scanned data for manual entry
    await _storageService.saveScannedIdData({
      'name': '',
      'idNumber': '',
      'dateOfBirth': '',
    });

    // Navigate to scanned data verification screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ScannedDataVerificationScreen(),
        ),
      );
    }
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
          'Scan ID Card',
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
              Icons.credit_card,
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
              if (!_isProcessing && barcode.barcodes.isNotEmpty) {
                _handleIdCardScan();
              }
            },
          ),
          // Overlay with ID card frame (rectangular)
          Container(
            decoration: ShapeDecoration(
              shape: IdCardOverlayShape(
                borderColor: AppTheme.accentOrange,
                borderRadius: 12,
                borderLength: 30,
                borderWidth: 8,
                cutOutWidth: 300,
                cutOutHeight: 200,
              ),
            ),
          ),
          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentOrange,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Processing ID Card...',
                      style: TextStyle(
                        color: AppTheme.surfaceColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Control buttons
          if (!_isProcessing)
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.flash_on,
                        color: AppTheme.surfaceColor,
                      ),
                      onPressed: () {
                        controller.toggleTorch();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.cameraswitch,
                        color: AppTheme.surfaceColor,
                      ),
                      onPressed: () => controller.switchCamera(),
                    ),
                  ),
                ],
              ),
            ),
          // Instructions and Skip Button
          if (!_isProcessing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: AppTheme.textPrimary.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.credit_card,
                          color: AppTheme.surfaceColor,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Position your ID card within the frame',
                          style: TextStyle(
                            color: AppTheme.surfaceColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ensure the card is flat and well-lit',
                          style: TextStyle(
                            color: AppTheme.surfaceColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Skip/Enter Manually Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _handleSkipScan,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.surfaceColor,
                          side: const BorderSide(
                            color: AppTheme.surfaceColor,
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusM),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Enter Manually',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Custom overlay shape for ID card scanner (rectangular)
class IdCardOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutWidth;
  final double cutOutHeight;

  const IdCardOverlayShape({
    this.borderColor = AppTheme.accentOrange,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutWidth = 300,
    this.cutOutHeight = 200,
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
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    // Calculate cutout position (centered)
    final cutOutLeft = (width - cutOutWidth) / 2;
    final cutOutTop = (height - cutOutHeight) / 2;
    final cutOutRight = cutOutLeft + cutOutWidth;
    final cutOutBottom = cutOutTop + cutOutHeight;

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
    return IdCardOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutWidth: cutOutWidth,
      cutOutHeight: cutOutHeight,
    );
  }
}
