import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/container_model.dart';
import '../services/db_service.dart';
import 'container_detail_screen.dart';

class ContainerListScreen extends StatefulWidget {
  final String filter; // 'all', 'incoming', 'outgoing'

  const ContainerListScreen({
    Key? key,
    required this.filter,
  }) : super(key: key);

  @override
  State<ContainerListScreen> createState() => _ContainerListScreenState();
}

class _ContainerListScreenState extends State<ContainerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ContainerModel> _containers = [];
  List<ContainerModel> _filteredContainers = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadContainers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContainers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      switch (widget.filter) {
        case 'incoming':
          _containers = await DBService.instance.getIncomingContainers();
          break;
        case 'outgoing':
          _containers = await DBService.instance.getOutgoingContainers();
          break;
        case 'all':
        default:
          _containers = await DBService.instance.getAllContainers();
          break;
      }

      _filteredContainers = List.from(_containers);
    } catch (e) {
      // Handle error
      _showErrorSnackBar('Kayıtlar yüklenirken hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterContainers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContainers = List.from(_containers);
      } else {
        _filteredContainers = _containers
            .where((container) => container.containerNumber
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredContainers = List.from(_containers);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Konteyner numarası ara...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _filterContainers,
              )
            : Text(_getScreenTitle()),
        centerTitle: !_isSearching,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContainers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredContainers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox,
                        size: 70,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isSearching
                            ? 'Arama sonucu bulunamadı'
                            : 'Konteyner kaydı bulunamadı',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredContainers.length,
                  itemBuilder: (context, index) {
                    final container = _filteredContainers[index];
                    return _buildContainerCard(container);
                  },
                ),
    );
  }

  String _getScreenTitle() {
    switch (widget.filter) {
      case 'incoming':
        return 'Gelen Konteynerler';
      case 'outgoing':
        return 'Giden Konteynerler';
      case 'all':
      default:
        return 'Tüm Konteynerler';
    }
  }

  Widget _buildContainerCard(ContainerModel container) {
    final dateFormat = DateFormat('dd.MM.yyyy - HH:mm');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToDetailScreen(container),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tip simgesi
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: container.type == 'incoming'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  container.type == 'incoming'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: container.type == 'incoming'
                      ? Colors.green
                      : Colors.orange,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      container.containerNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (container.typeCode != null || container.height != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          [
                            if (container.typeCode != null) container.typeCode,
                            if (container.height != null) container.height,
                          ].where((e) => e != null).join(' - '),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    Text(
                      dateFormat.format(container.timestamp),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Fotoğraf önizleme
              if (container.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.file(
                      File(container.imagePath!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetailScreen(ContainerModel container) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContainerDetailScreen(
          container: container,
        ),
      ),
    ).then((value) {
      // Ekrandan dönüldüğünde listeyi güncelle
      _loadContainers();
    });
  }
} 