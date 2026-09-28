import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/multimedia_service.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../widgets/admin_image_picker_field.dart';

class AdminMultimediaEditPage extends StatefulWidget {
  final Map<String, dynamic>? existingItem;

  const AdminMultimediaEditPage({super.key, this.existingItem});

  @override
  State<AdminMultimediaEditPage> createState() => _AdminMultimediaEditPageState();
}

class _AdminMultimediaEditPageState extends State<AdminMultimediaEditPage> {
  final _formKey = GlobalKey<FormState>();

  late String _type; // 'fan_art', 'cosplay', 'video', 'podcast'
  late String _fandom;
  String? _mediaImageUrl;
  bool _isSaving = false;

  // ── Media file upload state (podcast audio / video) ─────────────────
  bool _isUploadingAudio = false;
  bool _isUploadingVideo = false;
  String _audioUploadStatus = '';
  String _videoUploadStatus = '';

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _creatorController; // artist, cosplayer, channel, host
  late TextEditingController _secondaryController; // event, views, episode
  late TextEditingController _tertiaryController; // award, duration, date
  late TextEditingController _mediaUrlController; // videoUrl, podcastUrl
  late TextEditingController _descriptionController; // podcast description
  late TextEditingController _likesController;

  static const List<String> _fandoms = [
    'Anime & Manga',
    'Gaming & Esports',
    'Marvel & DC Comics',
    'Sci-Fi & Fantasy',
    'K-Pop & Idol Culture',
    'Pop Culture & Movies',
    'Comics & Events',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem ?? {};

    _type = item['type'] as String? ?? 'fan_art';
    _fandom = item['fandom'] as String? ?? _fandoms.first;
    if (!_fandoms.contains(_fandom)) {
      _fandom = _fandoms.first;
    }

    _mediaImageUrl = item['imageUrl'] as String? ??
        item['thumbnailUrl'] as String? ??
        item['coverUrl'] as String?;

    _titleController = TextEditingController(
      text: (item['title'] ?? item['character'] ?? '').toString(),
    );

    // Dynamic field mapping
    String creator = '';
    String secondary = '';
    String tertiary = '';
    String mediaUrl = '';
    String desc = item['description']?.toString() ?? '';
    String likes = (item['likes'] ?? 0).toString();

    switch (_type) {
      case 'fan_art':
        creator = item['artist']?.toString() ?? '';
        break;
      case 'cosplay':
        creator = item['cosplayer']?.toString() ?? '';
        secondary = item['event']?.toString() ?? '';
        tertiary = item['award']?.toString() ?? '';
        break;
      case 'video':
        creator = item['channel']?.toString() ?? '';
        secondary = item['views']?.toString() ?? '';
        tertiary = item['duration']?.toString() ?? '';
        mediaUrl = item['videoUrl']?.toString() ?? '';
        break;
      case 'podcast':
        creator = item['host']?.toString() ?? '';
        secondary = item['episode']?.toString() ?? '';
        tertiary = item['duration']?.toString() ?? '';
        mediaUrl = item['podcastUrl']?.toString() ?? '';
        break;
    }

    _creatorController = TextEditingController(text: creator);
    _secondaryController = TextEditingController(text: secondary);
    _tertiaryController = TextEditingController(text: tertiary);
    _mediaUrlController = TextEditingController(text: mediaUrl);
    _descriptionController = TextEditingController(text: desc);
    _likesController = TextEditingController(text: likes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _secondaryController.dispose();
    _tertiaryController.dispose();
    _mediaUrlController.dispose();
    _descriptionController.dispose();
    _likesController.dispose();
    super.dispose();
  }

  String get _cloudinaryFolder {
    switch (_type) {
      case 'video':
        return CloudinaryService.folderVideos;
      case 'podcast':
        return CloudinaryService.folderPodcasts;
      case 'cosplay':
      case 'fan_art':
      default:
        return CloudinaryService.folderPosts;
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mediaImageUrl == null || _mediaImageUrl!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please select or upload an image/thumbnail to Cloudinary CDN.'),
          backgroundColor: AppColors.comicRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final isEdit = widget.existingItem != null && widget.existingItem!['id'] != null;
      final id = isEdit ? widget.existingItem!['id'] as String : '';

      final payload = <String, dynamic>{
        'type': _type,
        'fandom': _fandom,
        'title': _titleController.text.trim(),
      };

      switch (_type) {
        case 'fan_art':
          payload['artist'] = _creatorController.text.trim();
          payload['imageUrl'] = _mediaImageUrl;
          payload['likes'] = int.tryParse(_likesController.text.trim()) ?? 0;
          payload['isLiked'] = widget.existingItem?['isLiked'] ?? false;
          break;
        case 'cosplay':
          payload['character'] = _titleController.text.trim();
          payload['cosplayer'] = _creatorController.text.trim();
          payload['event'] = _secondaryController.text.trim();
          payload['award'] = _tertiaryController.text.trim();
          payload['imageUrl'] = _mediaImageUrl;
          break;
        case 'video':
          payload['channel'] = _creatorController.text.trim();
          payload['views'] = _secondaryController.text.trim().isEmpty ? '1.0M' : _secondaryController.text.trim();
          payload['duration'] = _tertiaryController.text.trim().isEmpty ? '10:00' : _tertiaryController.text.trim();
          payload['videoUrl'] = _mediaUrlController.text.trim();
          payload['thumbnailUrl'] = _mediaImageUrl;
          payload['isBookmarked'] = widget.existingItem?['isBookmarked'] ?? false;
          break;
        case 'podcast':
          payload['host'] = _creatorController.text.trim();
          payload['episode'] = _secondaryController.text.trim().isEmpty ? 'EP 01' : _secondaryController.text.trim();
          payload['duration'] = _tertiaryController.text.trim().isEmpty ? '45m' : _tertiaryController.text.trim();
          payload['date'] = 'Today';
          payload['podcastUrl'] = _mediaUrlController.text.trim();
          payload['coverUrl'] = _mediaImageUrl;
          payload['description'] = _descriptionController.text.trim();
          payload['isPlaying'] = false;
          break;
      }

      if (isEdit) {
        await MultimediaService.instance.updateItem(id, payload);
      } else {
        await MultimediaService.instance.createItem(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? '✅ Multimedia item updated successfully!'
                  : '✅ Multimedia item created & saved to Cloudinary + Firestore!',
            ),
            backgroundColor: AppColors.comicRed,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: AppColors.comicRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadPodcastAudio() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'aac', 'm4a', 'wav', 'ogg', 'flac'],
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final name = result.files.single.name;

    setState(() {
      _isUploadingAudio = true;
      _audioUploadStatus = '⬆️ Uploading "$name" to Cloudinary...';
    });

    try {
      final url = await CloudinaryService.instance.uploadAudio(
        file,
        folder: CloudinaryService.folderPodcasts,
      );
      setState(() {
        _mediaUrlController.text = url;
        _audioUploadStatus = '✅ Uploaded: $name';
      });
    } catch (e) {
      setState(() {
        _audioUploadStatus = '❌ Upload failed: $e';
      });
    } finally {
      setState(() => _isUploadingAudio = false);
    }
  }

  Future<void> _pickAndUploadVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
    );
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final name = result.files.single.name;

    setState(() {
      _isUploadingVideo = true;
      _videoUploadStatus = '⬆️ Uploading "$name" to Cloudinary...';
    });

    try {
      final url = await CloudinaryService.instance.uploadVideo(
        file,
        folder: CloudinaryService.folderVideos,
      );
      setState(() {
        _mediaUrlController.text = url;
        _videoUploadStatus = '✅ Uploaded: $name';
      });
    } catch (e) {
      setState(() {
        _videoUploadStatus = '❌ Upload failed: $e';
      });
    } finally {
      setState(() => _isUploadingVideo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingItem != null && widget.existingItem!['id'] != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Color(0xFF111216), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Edit Multimedia Content' : 'Add New Multimedia',
          style: const TextStyle(
            color: Color(0xFF111216),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: SafeArea(
          child: SkewedButton(
            text: isEdit ? 'Save Multimedia Changes' : 'Publish to Multimedia Hub',
            icon: Iconsax.tick_circle,
            height: 50,
            fontSize: 13,
            backgroundColor: AppColors.comicRed,
            textColor: Colors.white,
            isLoading: _isSaving,
            onPressed: _saveItem,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Select Media Type (Segmented Solid Red & White)
              const Text(
                'MEDIA TYPE',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTypeOption('fan_art', 'Fan Art'),
                    _buildTypeOption('cosplay', 'Cosplay'),
                    _buildTypeOption('video', 'Video'),
                    _buildTypeOption('podcast', 'Podcast'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Fandom Universe Selector
              const Text(
                'FANDOM UNIVERSE',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _fandom,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    icon: const Icon(Iconsax.arrow_down_1, color: Color(0xFF6B7280), size: 16),
                    items: _fandoms.map((f) {
                      return DropdownMenuItem<String>(
                        value: f,
                        child: Text(
                          f,
                          style: const TextStyle(
                            color: Color(0xFF111216),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _fandom = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Title / Character Name
              Text(
                _type == 'cosplay' ? 'CHARACTER NAME *' : 'CONTENT TITLE *',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildSolidTextField(
                controller: _titleController,
                hintText: _type == 'cosplay'
                    ? 'e.g. Malenia, Blade of Miquella'
                    : 'e.g. Neo-Tokyo Cyberpunk Reimagined',
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 20),

              // 4. Creator field (Artist / Cosplayer / Channel / Host)
              Text(
                '${_creatorLabel.toUpperCase()} *',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildSolidTextField(
                controller: _creatorController,
                hintText: _creatorHint,
                validator: (val) => val == null || val.trim().isEmpty ? '$_creatorLabel is required' : null,
              ),
              const SizedBox(height: 20),

              // 5. Cloudinary Image Picker Field
              Text(
                '${_imageLabel.toUpperCase()} (CLOUDINARY CDN) *',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.all(12),
                child: AdminImagePickerField(
                  initialImagePathOrUrl: _mediaImageUrl,
                  label: _imageLabel,
                  cloudinaryFolder: _cloudinaryFolder,
                  helperText: 'Pick from gallery or camera — auto uploads to Cloudinary folder "$_cloudinaryFolder"',
                  onImageSelected: (url) {
                    setState(() => _mediaImageUrl = url);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 6. Type Specific Fields
              if (_type == 'cosplay') ...[
                const Text(
                  'CONVENTION / EVENT NAME',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSolidTextField(
                  controller: _secondaryController,
                  hintText: 'e.g. Tokyo Game Show 2024 or San Diego Comic-Con',
                ),
                const SizedBox(height: 20),
                const Text(
                  'AWARD / RECOGNITION (OPTIONAL)',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSolidTextField(
                  controller: _tertiaryController,
                  hintText: 'e.g. Best Armor Crafting or Audience Favorite',
                ),
                const SizedBox(height: 20),
              ],

              if (_type == 'video') ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DURATION',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSolidTextField(
                            controller: _tertiaryController,
                            hintText: 'e.g. 12:34',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VIEWS DISPLAY',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSolidTextField(
                            controller: _secondaryController,
                            hintText: 'e.g. 2.4M',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // VIDEO UPLOAD
                const Text(
                  'VIDEO FILE (CLOUDINARY UPLOAD)',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMediaUploadSection(
                  isUploading: _isUploadingVideo,
                  statusMessage: _videoUploadStatus,
                  onPickFile: _pickAndUploadVideo,
                  pickButtonLabel: 'Pick Video from Device',
                  pickButtonIcon: Iconsax.video_add,
                  urlController: _mediaUrlController,
                  urlHint: 'Or paste Cloudinary / YouTube URL',
                ),
                const SizedBox(height: 20),
              ],
              if (_type == 'podcast') ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EPISODE #',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSolidTextField(
                            controller: _secondaryController,
                            hintText: 'e.g. EP 47',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DURATION',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildSolidTextField(
                            controller: _tertiaryController,
                            hintText: 'e.g. 1h 12m',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // PODCAST AUDIO UPLOAD
                const Text(
                  'PODCAST AUDIO FILE (CLOUDINARY UPLOAD)',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMediaUploadSection(
                  isUploading: _isUploadingAudio,
                  statusMessage: _audioUploadStatus,
                  onPickFile: _pickAndUploadPodcastAudio,
                  pickButtonLabel: 'Pick Audio from Device',
                  pickButtonIcon: Iconsax.microphone_2,
                  urlController: _mediaUrlController,
                  urlHint: 'Or paste Cloudinary Audio URL',
                ),
                const SizedBox(height: 20),
                const Text(
                  'EPISODE DESCRIPTION',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSolidTextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  hintText: 'Brief summary of the podcast episode and lore topics discussed...',
                ),
                const SizedBox(height: 20),
              ],

              if (_type == 'fan_art') ...[
                const Text(
                  'INITIAL LIKES COUNT',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSolidTextField(
                  controller: _likesController,
                  keyboardType: TextInputType.number,
                  hintText: 'e.g. 1200',
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(String typeKey, String label) {
    final isSelected = _type == typeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _type = typeKey;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.comicRed : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _creatorLabel {
    switch (_type) {
      case 'fan_art':
        return 'Artist Name';
      case 'cosplay':
        return 'Cosplayer Name';
      case 'video':
        return 'YouTube / Channel Name';
      case 'podcast':
        return 'Podcast Host(s)';
      default:
        return 'Creator';
    }
  }

  String get _creatorHint {
    switch (_type) {
      case 'fan_art':
        return 'e.g. Kenji_Art';
      case 'cosplay':
        return 'e.g. ValkyrieCrafts';
      case 'video':
        return 'e.g. AnimeVault or VaatiVidya';
      case 'podcast':
        return 'e.g. Alex Rivera & Mia Chen';
      default:
        return 'Creator name';
    }
  }

  String get _imageLabel {
    switch (_type) {
      case 'fan_art':
        return 'Artwork Image';
      case 'cosplay':
        return 'Cosplay Photo';
      case 'video':
        return 'Video Thumbnail';
      case 'podcast':
        return 'Podcast Cover Art';
      default:
        return 'Media Image';
    }
  }

  /// Shared media file upload widget used for both podcast audio and video.
  Widget _buildMediaUploadSection({
    required bool isUploading,
    required String statusMessage,
    required VoidCallback onPickFile,
    required String pickButtonLabel,
    required IconData pickButtonIcon,
    required TextEditingController urlController,
    required String urlHint,
    String? Function(String?)? urlValidator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload button row
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: isUploading ? null : onPickFile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isUploading
                        ? const Color(0xFFF3F4F6)
                        : AppColors.comicRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUploading
                          ? const Color(0xFFE5E7EB)
                          : AppColors.comicRed.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isUploading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.comicRed,
                          ),
                        )
                      else
                        Icon(pickButtonIcon, size: 18, color: AppColors.comicRed),
                      const SizedBox(width: 8),
                      Text(
                        isUploading ? 'Uploading...' : pickButtonLabel,
                        style: TextStyle(
                          color: isUploading
                              ? const Color(0xFF9CA3AF)
                              : AppColors.comicRed,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Upload status message
        if (statusMessage.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusMessage.startsWith('✅')
                  ? const Color(0xFFD1FAE5)
                  : statusMessage.startsWith('❌')
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: statusMessage.startsWith('✅')
                    ? const Color(0xFF6EE7B7)
                    : statusMessage.startsWith('❌')
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFFFDE68A),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    statusMessage,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusMessage.startsWith('✅')
                          ? const Color(0xFF065F46)
                          : statusMessage.startsWith('❌')
                              ? const Color(0xFF991B1B)
                              : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 10),

        // Divider label
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const Text(
                'OR PASTE URL MANUALLY',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          ],
        ),
        const SizedBox(height: 8),

        // URL text field
        TextFormField(
          controller: urlController,
          validator: urlValidator,
          style: const TextStyle(
            color: Color(0xFF111216),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: urlHint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.comicRed, width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSolidTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Color(0xFF111216), fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.comicRed, width: 1.8),
        ),
      ),
    );
  }
}
