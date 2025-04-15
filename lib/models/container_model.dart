class ContainerModel {
  final int? id;
  final String containerNumber;
  final String type; // 'incoming' veya 'outgoing'
  final String? typeCode;
  final String? height;
  final String? isoCode;
  final String? warnings;
  final DateTime timestamp;
  final String? imagePath;

  ContainerModel({
    this.id,
    required this.containerNumber,
    required this.type,
    this.typeCode,
    this.height,
    this.isoCode,
    this.warnings,
    required this.timestamp,
    this.imagePath,
  });

  // JSON'dan modele dönüştürme
  factory ContainerModel.fromJson(Map<String, dynamic> json) {
    return ContainerModel(
      id: json['id'],
      containerNumber: json['containerNumber'],
      type: json['type'],
      typeCode: json['typeCode'],
      height: json['height'],
      isoCode: json['isoCode'],
      warnings: json['warnings'],
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
    );
  }

  // Modelden JSON'a dönüştürme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'containerNumber': containerNumber,
      'type': type,
      'typeCode': typeCode,
      'height': height,
      'isoCode': isoCode,
      'warnings': warnings,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  // Veritabanı sorgusundan model oluşturma
  factory ContainerModel.fromMap(Map<String, dynamic> map) {
    return ContainerModel(
      id: map['id'],
      containerNumber: map['containerNumber'],
      type: map['type'],
      typeCode: map['typeCode'],
      height: map['height'],
      isoCode: map['isoCode'],
      warnings: map['warnings'],
      timestamp: DateTime.parse(map['timestamp']),
      imagePath: map['imagePath'],
    );
  }

  // Modelden veritabanı için harita oluşturma
  Map<String, dynamic> toMap() {
    return {
      'containerNumber': containerNumber,
      'type': type,
      'typeCode': typeCode,
      'height': height,
      'isoCode': isoCode,
      'warnings': warnings,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  // Kopya oluşturma ve güncelleme için
  ContainerModel copyWith({
    int? id,
    String? containerNumber,
    String? type,
    String? typeCode,
    String? height,
    String? isoCode,
    String? warnings,
    DateTime? timestamp,
    String? imagePath,
  }) {
    return ContainerModel(
      id: id ?? this.id,
      containerNumber: containerNumber ?? this.containerNumber,
      type: type ?? this.type,
      typeCode: typeCode ?? this.typeCode,
      height: height ?? this.height,
      isoCode: isoCode ?? this.isoCode,
      warnings: warnings ?? this.warnings,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
    );
  }
} 