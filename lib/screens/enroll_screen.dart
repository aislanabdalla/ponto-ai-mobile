import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'api.dart';

class EnrollScreen extends StatefulWidget {
  const EnrollScreen({super.key});

  @override
  State<EnrollScreen> createState() => _EnrollScreenState();
}

class _EnrollScreenState extends State<EnrollScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _busy = false;
  final _nameCtrl = TextEditingController();

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
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _captureAndSend() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o nome')));
      return;
    }
    setState(() => _busy = true);
    try {
      final file = await _controller!.takePicture();
      final res = await Api.enroll(_nameCtrl.text.trim(), File(file.path));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastro facial realizado!')));
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
      appBar: AppBar(title: const Text('Cadastrar rosto')),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nome do funcionário')),
                ),
                AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: CameraPreview(_controller!),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _busy ? null : _captureAndSend,
                  child: _busy ? const CircularProgressIndicator() : const Text('Capturar e enviar'),
                ),
              ],
            ),
    );
  }
}
