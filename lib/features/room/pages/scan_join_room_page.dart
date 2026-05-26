import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:soulfood_front/features/room/room_join_flow.dart';
import 'package:soulfood_front/features/room/room_join_link.dart';

class ScanJoinRoomPage extends StatefulWidget {
  const ScanJoinRoomPage({super.key});

  @override
  State<ScanJoinRoomPage> createState() => _ScanJoinRoomPageState();
}

class _ScanJoinRoomPageState extends State<ScanJoinRoomPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _processing = false;
  String? _lastScanned;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleScan(String raw) async {
    if (_processing) return;
    final code = RoomJoinLink.parseRoomCode(raw);
    if (code == null) return;
    if (code == _lastScanned) return;

    _lastScanned = code;
    setState(() => _processing = true);
    await _controller.stop();

    if (!mounted) return;
    final ok = await joinRoomAndNavigate(context, code);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _processing = false;
        _lastScanned = null;
      });
      await _controller.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码入房'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, _) {
                switch (state.torchState) {
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto);
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off);
                }
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final raw = capture.barcodes.firstOrNull?.rawValue;
              if (raw != null) _handleScan(raw);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_processing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  const Text(
                    '将好友分享的房间二维码放入框内',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '支持 DecideMeal 二维码或 6 位房间号',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
