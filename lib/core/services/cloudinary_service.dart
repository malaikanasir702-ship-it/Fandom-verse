import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

/// Cloudinary CDN Service for Fandom Verse Pocket Edition
/// Handles image, video, and audio uploads via REST API (unsigned + signed)
/// Cloud: hpihaiub
class CloudinaryService {
  static const String _cloudName = 'hpihaiub';
  static const String _apiKey = '515492813748927';
  static const String _apiSecret = 'uKfG2Ok2tUsMOCDejh15TMrN8B0';
  static const String _uploadBaseUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName';

  // ── Folder constants ──────────────────────────────────────────────────────
  static const String folderAvatars = 'fandom_verse/avatars';
  static const String folderPosts = 'fandom_verse/posts';
  static const String folderEvents = 'fandom_verse/events';
  static const String folderMerchandise = 'fandom_verse/merchandise';
  static const String folderHeroStories = 'fandom_verse/hero_stories';
  static const String folderPodcasts = 'fandom_verse/podcasts';
  static const String folderVideos = 'fandom_verse/videos';
  static const String folderCategories = 'fandom_verse/categories';

  static final CloudinaryService _instance = CloudinaryService._();
  CloudinaryService._();
  static CloudinaryService get instance => _instance;

  // ── Upload Image from File ────────────────────────────────────────────────
  /// Upload any local image file to Cloudinary.
  /// Returns the secure_url on success, throws on failure.
  Future<String> uploadImage(File imageFile, {String folder = folderPosts}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signature = _generateSignature(folder: folder, timestamp: timestamp);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadBaseUrl/image/upload'),
    );

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['folder'] = folder;
    request.fields['signature'] = signature;
    // Auto quality + auto format for 60-80% smaller files
    request.fields['transformation'] = 'q_auto,f_auto';

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    debugPrint('[Cloudinary] Uploading image to folder: $folder');
    final response = await request.send().timeout(const Duration(seconds: 30));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final url = data['secure_url'] as String;
      debugPrint('[Cloudinary] ✅ Image uploaded: $url');
      return url;
    } else {
      debugPrint('[Cloudinary] ❌ Upload failed (${response.statusCode}): $body');
      throw Exception('Cloudinary upload failed: ${response.statusCode}');
    }
  }

  // ── Upload Image from Bytes ───────────────────────────────────────────────
  Future<String> uploadImageBytes(
    Uint8List bytes,
    String filename, {
    String folder = folderPosts,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signature = _generateSignature(folder: folder, timestamp: timestamp);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadBaseUrl/image/upload'),
    );

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['folder'] = folder;
    request.fields['signature'] = signature;
    request.fields['transformation'] = 'q_auto,f_auto';

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final response = await request.send().timeout(const Duration(seconds: 30));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } else {
      throw Exception('Cloudinary image bytes upload failed: ${response.statusCode}');
    }
  }

  // ── Upload Video from File ────────────────────────────────────────────────
  Future<String> uploadVideo(File videoFile, {String folder = folderVideos}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signature = _generateSignature(folder: folder, timestamp: timestamp, resourceType: 'video');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadBaseUrl/video/upload'),
    );

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['folder'] = folder;
    request.fields['signature'] = signature;

    request.files.add(
      await http.MultipartFile.fromPath('file', videoFile.path),
    );

    debugPrint('[Cloudinary] Uploading video to folder: $folder');
    final response = await request.send().timeout(const Duration(seconds: 120));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final url = data['secure_url'] as String;
      debugPrint('[Cloudinary] ✅ Video uploaded: $url');
      return url;
    } else {
      throw Exception('Cloudinary video upload failed: ${response.statusCode}');
    }
  }

  // ── Upload Audio from File ────────────────────────────────────────────────
  Future<String> uploadAudio(File audioFile, {String folder = folderPodcasts}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signature = _generateSignature(folder: folder, timestamp: timestamp, resourceType: 'video');

    // Cloudinary treats audio as 'video' resource type
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_uploadBaseUrl/video/upload'),
    );

    request.fields['api_key'] = _apiKey;
    request.fields['timestamp'] = timestamp.toString();
    request.fields['folder'] = folder;
    request.fields['signature'] = signature;

    request.files.add(
      await http.MultipartFile.fromPath('file', audioFile.path),
    );

    debugPrint('[Cloudinary] Uploading audio/podcast to folder: $folder');
    final response = await request.send().timeout(const Duration(seconds: 120));
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final url = data['secure_url'] as String;
      debugPrint('[Cloudinary] ✅ Audio uploaded: $url');
      return url;
    } else {
      throw Exception('Cloudinary audio upload failed: ${response.statusCode}');
    }
  }

  // ── Upload via URL (fetch from external URL → store on Cloudinary) ────────
  /// Migrates any external URL (Unsplash, etc.) to Cloudinary automatically.
  Future<String> uploadFromUrl(String sourceUrl, {String folder = folderPosts}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signature = _generateSignature(folder: folder, timestamp: timestamp);

    final response = await http.post(
      Uri.parse('$_uploadBaseUrl/image/upload'),
      body: {
        'file': sourceUrl,
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'folder': folder,
        'signature': signature,
        'transformation': 'q_auto,f_auto',
      },
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String;
    } else {
      debugPrint('[Cloudinary] uploadFromUrl failed (${response.statusCode}): ${response.body}');
      // Return original URL as fallback — non-critical
      return sourceUrl;
    }
  }

  // ── Delete Asset ─────────────────────────────────────────────────────────
  Future<bool> deleteAsset(String publicId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final sigString = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    final signature = sha1.convert(utf8.encode(sigString)).toString();

    final response = await http.post(
      Uri.parse('$_uploadBaseUrl/image/destroy'),
      body: {
        'public_id': publicId,
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'signature': signature,
      },
    );

    return response.statusCode == 200;
  }

  // ── URL Optimization Helpers ──────────────────────────────────────────────

  /// Add auto-quality + auto-format transformations to any Cloudinary URL.
  /// Also resizes to the specified width for faster loading.
  static String optimizeUrl(
    String url, {
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
  }) {
    if (!url.contains('res.cloudinary.com')) return url;

    // Build transformation string
    final transforms = <String>['q_$quality', 'f_$format'];
    if (width != null) transforms.add('w_$width');
    if (height != null) transforms.add('h_$height');
    if (width != null || height != null) transforms.add('c_$crop');

    final transform = transforms.join(',');

    // Insert transformation before the version/public_id part
    return url.replaceFirst(
      '/upload/',
      '/upload/$transform/',
    );
  }

  /// Quick helper: thumbnail URL (400px wide, auto quality)
  static String thumbnail(String url, {int width = 400}) =>
      optimizeUrl(url, width: width);

  /// Quick helper: avatar URL (200x200 fill, auto quality)
  static String avatar(String url) =>
      optimizeUrl(url, width: 200, height: 200, crop: 'fill');

  /// Quick helper: banner URL (800px wide, auto quality)
  static String banner(String url) =>
      optimizeUrl(url, width: 800);

  /// Returns true if a URL is hosted on Cloudinary
  static bool isCloudinaryUrl(String url) =>
      url.contains('res.cloudinary.com') && url.contains('hpihaiub');

  // ── HMAC-SHA1 Signature Generation ───────────────────────────────────────
  String _generateSignature({
    required String folder,
    required int timestamp,
    String resourceType = 'image',
  }) {
    // Cloudinary signature: alphabetically sorted params + api_secret
    final paramsToSign =
        'folder=$folder&timestamp=$timestamp$_apiSecret';
    final bytes = utf8.encode(paramsToSign);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
}
