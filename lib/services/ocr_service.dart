import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  final textRecognizer = TextRecognizer();

  // Singleton pattern
  OCRService._privateConstructor();
  static final OCRService instance = OCRService._privateConstructor();

  Future<String> extractContainerNumber(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    
    // Regex pattern for container numbers (4 letters followed by 7 digits)
    // Example: MSBU 6790820
    RegExp containerNumberRegex = RegExp(r'[A-Z]{4}\s*\d{7}');
    
    // Try to find container number match
    final match = containerNumberRegex.firstMatch(text);
    if (match != null) {
      return match.group(0)!.replaceAll(RegExp(r'\s+'), ' ').trim();
    }
    
    // If no match found, return the entire text for manual selection
    return text;
  }

  Future<Map<String, String?>> extractContainerInfo(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    
    // Container info patterns
    RegExp containerNumberRegex = RegExp(r'[A-Z]{4}\s*\d{7}');
    RegExp typeCodeRegex = RegExp(r'\d{2}[A-Z]\d');
    RegExp heightRegex = RegExp(r'(\d+,\d+m|^\d+\'?\d*\"?)');
    RegExp isoCodeRegex = RegExp(r'[A-Z]{2}\s*\d{2}');
    RegExp warningsRegex = RegExp(r'(CAUTION|WARNING|HIGH|HEAVY).*', caseSensitive: false);
    
    // Extract info
    final containerMatch = containerNumberRegex.firstMatch(text);
    final typeCodeMatch = typeCodeRegex.firstMatch(text);
    final heightMatch = heightRegex.firstMatch(text);
    final isoCodeMatch = isoCodeRegex.firstMatch(text);
    final warningsMatch = warningsRegex.firstMatch(text);
    
    Map<String, String?> info = {
      'containerNumber': containerMatch?.group(0)?.replaceAll(RegExp(r'\s+'), ' ').trim(),
      'typeCode': typeCodeMatch?.group(0)?.trim(),
      'height': heightMatch?.group(0)?.trim(),
      'isoCode': isoCodeMatch?.group(0)?.trim(),
      'warnings': warningsMatch?.group(0)?.trim(),
    };
    
    return info;
  }

  void dispose() {
    textRecognizer.close();
  }
} 