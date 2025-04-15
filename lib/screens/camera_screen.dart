import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../models/container_model.dart';
import '../services/db_service.dart';
import '../services/ocr_service.dart';
import 'container_detail_screen.dart';

class CameraScreen extends StatefulWidget {
  final String containerType;

  const CameraScreen({
    Key? key,
    required this.containerType,
  }) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before camera was initialized
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        _showErrorDialog('Kamera bulunamadı');
      }
    } catch (e) {
      _showErrorDialog('Kamera başlatılamadı: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile imageFile = await _controller!.takePicture();
      
      // Save image to app directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'container_$timestamp.jpg';
      final String filePath = '${appDir.path}/$fileName';
      
      // Copy the image to app directory
      final File imageFileLocal = File(imageFile.path);
      await imageFileLocal.copy(filePath);
      
      // Process image with OCR
      final Map<String, String?> containerInfo = await OCRService.instance.extractContainerInfo(filePath);
      
      if (containerInfo['containerNumber'] == null || containerInfo['containerNumber']!.isEmpty) {
        // No container number found, show error
        _showErrorDialog('Konteyner numarası bulunamadı. Lütfen tekrar deneyin.');
        setState(() {
          _isProcessing = false;
        });
        return;
      }
      
      // Create container model
      final ContainerModel container = ContainerModel(
        containerNumber: containerInfo['containerNumber']!,
        type: widget.containerType,
        typeCode: containerInfo['typeCode'],
        height: containerInfo['height'],
        isoCode: containerInfo['isoCode'],
        warnings: containerInfo['warnings'],
        timestamp: DateTime.now(),
        imagePath: filePath,
      );
      
      // Save to database
      final int containerId = await DBService.instance.addContainer(container);
      
      // Navigate to detail screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ContainerDetailScreen(
              container: container.copyWith(id: containerId),
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog('Fotoğraf çekilemedi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.containerType == 'incoming' ? 'Gelen Konteyner' : 'Giden Konteyner'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.containerType == 'incoming' ? 'Gelen Konteyner' : 'Giden Konteyner'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // Camera preview
                CameraPreview(_controller!),
                
                // Overlay for better positioning
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.yellow,
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Konteyner numarasını çerçeve içine alın',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              backgroundColor: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Processing indicator
                if (_isProcessing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 20),
                            Text(
                              'İşleniyor...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
          // Camera controls
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    // Flip camera logic
                  },
                ),
                GestureDetector(
                  onTap: _isProcessing ? null : _takePicture,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.flash_off,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    // Flash control logic
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 