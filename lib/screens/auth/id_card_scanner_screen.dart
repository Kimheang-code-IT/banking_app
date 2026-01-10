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

class _IdCardScannerScreenState extends State<IdCardScannerScreen>
    with TickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  final StorageService _storageService = StorageService();
  bool _isProcessing = false;
  bool _isTorchOn = false;
  late AnimationController _loadingAnimationController;

  @override
  void initState() {
    super.initState();
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    try {
      await controller.toggleTorch();
      setState(() {
        _isTorchOn = !_isTorchOn;
      });
    } catch (e) {
      // Torch not available on this device
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flashlight not available'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
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
                borderRadius: 8,
                borderLength: 20,
                borderWidth: 5,
                cutOutWidth: 330,
                cutOutHeight: 250,
              ),
            ),
          ),
          // Processing indicator with enhanced loading UI
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated loading indicator
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentOrange.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentOrange,
                            ),
                            strokeWidth: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Scanning ID Card',
                        style: TextStyle(
                          color: AppTheme.textOnLight,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please wait while we process\nyour identification card',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondaryOnLight,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Animated progress dots
                      AnimatedBuilder(
                        animation: _loadingAnimationController,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              final delay = index * 0.2;
                              final animationValue =
                                  (_loadingAnimationController.value + delay) %
                                      1.0;
                              final opacity = 0.3 +
                                  (0.7 *
                                      (0.5 - (animationValue - 0.5).abs()) *
                                      2);

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accentOrange.withOpacity(
                                    opacity.clamp(0.3, 1.0),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Flashlight toggle button at bottom center
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: _isTorchOn
                      ? AppTheme.accentOrange.withOpacity(0.9)
                      : Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isTorchOn ? Icons.flashlight_on : Icons.flashlight_off,
                    color: AppTheme.surfaceColor,
                    size: 28,
                  ),
                  onPressed: _toggleTorch,
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(),
                ),
              ),
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
    this.borderRadius = 12,
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
