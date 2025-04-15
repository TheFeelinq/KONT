import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/container_model.dart';
import '../services/db_service.dart';

class ContainerDetailScreen extends StatelessWidget {
  final ContainerModel container;

  const ContainerDetailScreen({
    Key? key,
    required this.container,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konteyner Detayı'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareContainerInfo(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Konteyner türü
              _buildTypeIndicator(),
              
              const SizedBox(height: 20),
              
              // Konteyner fotoğrafı
              if (container.imagePath != null)
                _buildContainerImage(),
              
              const SizedBox(height: 20),
              
              // Konteyner numarası ve bilgileri
              _buildContainerInfo(),
              
              const SizedBox(height: 20),
              
              // Zaman bilgisi
              _buildTimestampInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: container.type == 'incoming' ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: container.type == 'incoming' ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            container.type == 'incoming' ? Icons.arrow_downward : Icons.arrow_upward,
            color: container.type == 'incoming' ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            container.type == 'incoming' ? 'Gelen Konteyner' : 'Giden Konteyner',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: container.type == 'incoming' ? Colors.green.shade800 : Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(
        File(container.imagePath!),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildContainerInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konteyner Bilgileri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 10),
            _buildInfoRow('Konteyner Numarası:', container.containerNumber),
            if (container.typeCode != null)
              _buildInfoRow('Tip Kodu:', container.typeCode!),
            if (container.height != null)
              _buildInfoRow('Yükseklik:', container.height!),
            if (container.isoCode != null)
              _buildInfoRow('ISO Kodu:', container.isoCode!),
            if (container.warnings != null)
              _buildInfoRow('Uyarılar:', container.warnings!),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampInfo() {
    final dateFormat = DateFormat('dd.MM.yyyy - HH:mm:ss');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              color: Colors.grey,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kayıt Zamanı',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  dateFormat.format(container.timestamp),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareContainerInfo(BuildContext context) async {
    final dateFormat = DateFormat('dd.MM.yyyy - HH:mm:ss');
    final type = container.type == 'incoming' ? 'Gelen Konteyner' : 'Giden Konteyner';
    
    String shareText = 'Konteyner Bilgileri\n\n';
    shareText += 'Tür: $type\n';
    shareText += 'Konteyner Numarası: ${container.containerNumber}\n';
    
    if (container.typeCode != null) {
      shareText += 'Tip Kodu: ${container.typeCode}\n';
    }
    
    if (container.height != null) {
      shareText += 'Yükseklik: ${container.height}\n';
    }
    
    if (container.isoCode != null) {
      shareText += 'ISO Kodu: ${container.isoCode}\n';
    }
    
    if (container.warnings != null) {
      shareText += 'Uyarılar: ${container.warnings}\n';
    }
    
    shareText += 'Kayıt Zamanı: ${dateFormat.format(container.timestamp)}\n';
    
    List<XFile> files = [];
    if (container.imagePath != null) {
      files.add(XFile(container.imagePath!));
    }
    
    await Share.shareXFiles(
      files,
      text: shareText,
      subject: 'Konteyner: ${container.containerNumber}',
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydı Sil'),
        content: const Text('Bu konteyner kaydını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await DBService.instance.deleteContainer(container.id!);
              if (context.mounted) {
                Navigator.pop(context); // Dialog'u kapat
                Navigator.pop(context); // Detay ekranından çık
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 