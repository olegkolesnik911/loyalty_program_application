import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:loyalty_program_application/src/pages/history_page.dart';
import 'package:loyalty_program_application/src/pages/product_info_page.dart';
import 'package:loyalty_program_application/src/providers/guest_provider.dart';
import 'package:loyalty_program_application/src/providers/user_provider.dart';
import 'package:loyalty_program_application/src/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:loyalty_program_application/src/components/CornerPainter.dart';
import 'package:loyalty_program_application/src/pages/history_page.dart';
import 'package:loyalty_program_application/src/pages/earn_point_page.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({super.key});

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<AuthenticatePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  late AnimationController _animationController;
  late Animation<double> _animation;

  final double scanBoxSize = 250;

  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: scanBoxSize).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    print("resum -----------");
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  Widget _buildHistoryButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.work_history, color: Colors.white),
      tooltip: 'History',
      onPressed: () {
        // TODO: Navigate to history details page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HistoryPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: const Text('Authenticate Product'),
        // actions: [_buildHistoryButton(context)],
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            cameraFacing: CameraFacing.back,
            // autofocus: true by default
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 20,
              borderWidth: 5,
              cutOutSize: scanBoxSize,
            ),
          ),
          Center(
            child: Stack(
              children: [
                Container(
                  width: scanBoxSize,
                  height: scanBoxSize,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: _cornerBox(Alignment.topLeft),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _cornerBox(Alignment.topRight),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: _cornerBox(Alignment.bottomLeft),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _cornerBox(Alignment.bottomRight),
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned(
                      top: _animation.value,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: scanBoxSize,
                        height: 2,
                        color: Colors.redAccent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (result != null) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _cornerBox(Alignment alignment) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: CornerPainter(color: Colors.red, alignment: alignment),
      ),
    );
  }

  Widget _buildResultOverlay() {
    final isClaiming = context.watch<UserProvider>().isClaiming;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Scan Complete',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Barcode Type: ${describeEnum(result!.format)}\nData: ${result!.code}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                const Text(
                  'You can now scan another QR code if needed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await controller?.resumeCamera();
                    if (!mounted) return;
                    setState(() {
                      result = null;
                      isProcessing = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Scan Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final guestProvider = Provider.of<GuestProvider>(
                      context,
                      listen: false,
                    );

                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    await guestProvider.authenticateProductByQR(
                      '${result!.code}',
                    );

                    // Close the loading dialog
                    Navigator.of(context, rootNavigator: true).pop();

                    final productInfo = guestProvider.productInfo;
                    if (productInfo is Map<String, dynamic>) {
                      if (productInfo.containsKey('detail')) {
                        // ❌ Show error dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Error'),
                            content: Text(productInfo['detail']),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // // ✅ Show success dialog with points
                        // showDialog(
                        //   context: context,
                        //   builder: (context) => AlertDialog(
                        //     title: Text('Success'),
                        //     content: Text('ProductInfo: ${productInfo}'),
                        //     actions: [
                        //       TextButton(
                        //         onPressed: () => Navigator.of(context).pop(),
                        //         child: Text('OK'),
                        //       ),
                        //     ],
                        //   ),
                        // );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductInfoPage(productInfo: productInfo),
                          ),
                        );
                      }
                    } else {
                      // 🚫 Show unexpected format dialog
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Error'),
                          content: Text('Unexpected response format.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Check Product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isProcessing && result == null) {
        isProcessing = true; // prevent multiple triggers immediately

        setState(() {
          result = scanData;
        });

        try {
          await controller.pauseCamera();

          // Optional: handle heavy processing here with compute() if needed
          // await compute(processScanData, scanData);
        } catch (e) {
          debugPrint('Camera error: $e');
        }
        // Don't resume camera automatically here to avoid UI flicker.
        // Let user tap "Scan Again" button to resume.
      }
    });
  }
}
