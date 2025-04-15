import 'package:flutter/material.dart';
import '../services/db_service.dart';
import 'camera_screen.dart';
import 'container_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konteyner Takip'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Arama ekranına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContainerListScreen(filter: 'all'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_rounded,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Konteyner Takip',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Konteynerleri takip etmek ve kaydetmek için kamera kullanın',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 50),
                _buildOptionButton(
                  context,
                  title: 'Gelen Konteyner',
                  description: 'Gelen konteynerleri kaydet',
                  icon: Icons.arrow_downward,
                  color: Colors.green,
                  onTap: () => _navigateToCamera(context, 'incoming'),
                ),
                const SizedBox(height: 20),
                _buildOptionButton(
                  context,
                  title: 'Giden Konteyner',
                  description: 'Giden konteynerleri kaydet',
                  icon: Icons.arrow_upward,
                  color: Colors.orange,
                  onTap: () => _navigateToCamera(context, 'outgoing'),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildListButton(
                      context,
                      title: 'Gelen Listesi',
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                      onTap: () => _navigateToList(context, 'incoming'),
                    ),
                    _buildListButton(
                      context,
                      title: 'Giden Listesi',
                      icon: Icons.arrow_upward,
                      color: Colors.orange,
                      onTap: () => _navigateToList(context, 'outgoing'),
                    ),
                    _buildListButton(
                      context,
                      title: 'Tüm Kayıtlar',
                      icon: Icons.list_alt,
                      color: Colors.blue,
                      onTap: () => _navigateToList(context, 'all'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCamera(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(containerType: type),
      ),
    );
  }

  void _navigateToList(BuildContext context, String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContainerListScreen(filter: filter),
      ),
    );
  }
} 