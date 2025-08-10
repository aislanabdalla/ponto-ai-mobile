import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'api.dart';

class PunchScreen extends StatefulWidget {
  const PunchScreen({super.key});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _busy = false;
  final _idCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    final front = _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => _cameras!.first);
    _controller = CameraController(front, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  Future<Position?> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _captureAndPunch() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_idCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o ID do funcionário')));
      return;
    }
    setState(() => _busy = true);
    try {
      final pos = await _getPosition();
      final file = await _controller!.takePicture();
      final id = int.parse(_idCtrl.text.trim());
      final res = await Api.punch(id, File(file.path), lat: pos?.latitude, lon: pos?.longitude);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ponto registrado!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falhou: ${res.statusCode} - ${res.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bater ponto')),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(controller: _idCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ID do funcionário')),
                ),
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _busy ? null : _captureAndPunch,
                  child: _busy ? const CircularProgressIndicator() : const Text('Capturar e enviar'),
                ),
              ],
            ),
    );
  }
}
