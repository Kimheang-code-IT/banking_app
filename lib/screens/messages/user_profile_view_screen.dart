import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';
import 'call_screen.dart';
import 'video_call_screen.dart';

class UserProfileViewScreen extends StatefulWidget {
  final String userId;
  final String? userName;
  final String? userAvatar;
  final bool? isOnline;
  final String? conversationId;

  const UserProfileViewScreen({
    super.key,
    required this.userId,
    this.userName,
    this.userAvatar,
    this.isOnline,
    this.conversationId,
  });

  @override
  State<UserProfileViewScreen> createState() => _UserProfileViewScreenState();
}

class _UserProfileViewScreenState extends State<UserProfileViewScreen> {
  String _selectedMediaType = 'Photos'; // Default to Photos

  List<Map<String, dynamic>> _getSharedMedia() {
    // Mock shared media data
    return [
      {
        'type': 'image',
        'url': 'https://picsum.photos/200/300?random=1',
        'timestamp': DateTime.now().subtract(const Duration(days: 2))
      },
      {
        'type': 'voice',
        'duration': '0:45',
        'timestamp': DateTime.now().subtract(const Duration(days: 1))
      },
      {
        'type': 'file',
        'name': 'document.pdf',
        'size': '2.5 MB',
        'timestamp': DateTime.now().subtract(const Duration(days: 3))
      },
      {
        'type': 'link',
        'url': 'https://example.com/article',
        'title': 'Interesting Article',
        'timestamp': DateTime.now().subtract(const Duration(days: 4))
      },
      {
        'type': 'image',
        'url': 'https://picsum.photos/200/300?random=2',
        'timestamp': DateTime.now().subtract(const Duration(days: 5))
      },
      {
        'type': 'voice',
        'duration': '1:20',
        'timestamp': DateTime.now().subtract(const Duration(days: 6))
      },
      {
        'type': 'file',
        'name': 'presentation.pptx',
        'size': '5.2 MB',
        'timestamp': DateTime.now().subtract(const Duration(days: 7))
      },
      {
        'type': 'link',
        'url': 'https://example.com/resource',
        'title': 'Useful Resource',
        'timestamp': DateTime.now().subtract(const Duration(days: 8))
      },
      {
        'type': 'image',
        'url': 'https://picsum.photos/200/300?random=3',
        'timestamp': DateTime.now().subtract(const Duration(days: 9))
      },
      {
        'type': 'image',
        'url': 'https://picsum.photos/200/300?random=4',
        'timestamp': DateTime.now().subtract(const Duration(days: 10))
      },
      {
        'type': 'file',
        'name': 'spreadsheet.xlsx',
        'size': '1.8 MB',
        'timestamp': DateTime.now().subtract(const Duration(days: 11))
      },
      {
        'type': 'voice',
        'duration': '2:15',
        'timestamp': DateTime.now().subtract(const Duration(days: 12))
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredMedia() {
    final allMedia = _getSharedMedia();
    if (_selectedMediaType == 'Photos') {
      return allMedia.where((m) => m['type'] == 'image').toList();
    } else if (_selectedMediaType == 'Voice') {
      return allMedia.where((m) => m['type'] == 'voice').toList();
    } else if (_selectedMediaType == 'Files') {
      return allMedia.where((m) => m['type'] == 'file').toList();
    } else if (_selectedMediaType == 'Links') {
      return allMedia.where((m) => m['type'] == 'link').toList();
    }
    return allMedia;
  }

  int _getMediaCount(String type) {
    final allMedia = _getSharedMedia();
    if (type == 'Photos') {
      return allMedia.where((m) => m['type'] == 'image').length;
    } else if (type == 'Voice') {
      return allMedia.where((m) => m['type'] == 'voice').length;
    } else if (type == 'Files') {
      return allMedia.where((m) => m['type'] == 'file').length;
    } else if (type == 'Links') {
      return allMedia.where((m) => m['type'] == 'link').length;
    }
    return 0;
  }

  User? _getUserData() {
    if (widget.userName == null) return null;
    return User(
      id: widget.userId,
      name: widget.userName!,
      email: '${widget.userId}@example.com',
      phone: '+855 12 345 678',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _getUserData();
    final filteredMedia = _getFilteredMedia();

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.surfaceColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppTheme.surfaceColor,
              size: 22,
            ),
            color: AppTheme.surfaceColor,
            onSelected: (value) {
              if (value == 'block') {
                _showBlockDialog(context);
              } else if (value == 'delete') {
                _showDeleteDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Icon(
                      Icons.block,
                      color: AppTheme.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Block',
                      style: TextStyle(
                        color: AppTheme.textOnLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppTheme.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete Account',
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppTheme.textSecondaryOnLight.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: TextStyle(
                      color: AppTheme.textSecondaryOnLight,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentOrange,
                    ),
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundColor: AppTheme.surfaceColor,
                              backgroundImage: widget.userAvatar != null
                                  ? NetworkImage(widget.userAvatar!)
                                  : null,
                              child: widget.userAvatar == null
                                  ? Text(
                                      user.name.isNotEmpty
                                          ? user.name
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        color: AppTheme.accentOrange,
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            if (widget.isOnline == true)
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.accentOrange,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.surfaceColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: widget.isOnline == true
                                    ? const Color(0xFF4CAF50)
                                    : AppTheme.textSecondaryOnLight,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isOnline == true ? 'Online' : 'Offline',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.surfaceColor.withOpacity(0.85),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(
                              icon: Icons.phone,
                              label: 'Call',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CallScreen(
                                      userName: user.name,
                                      userAvatar: widget.userAvatar,
                                      isVideoCall: false,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              icon: Icons.videocam,
                              label: 'Video',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoCallScreen(
                                      userName: user.name,
                                      userAvatar: widget.userAvatar,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              icon: Icons.message,
                              label: 'Message',
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyTabBarDelegate(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMediaTypeTab(
                                'Photos', _getMediaCount('Photos')),
                          ),
                          Expanded(
                            child: _buildMediaTypeTab(
                                'Voice', _getMediaCount('Voice')),
                          ),
                          Expanded(
                            child: _buildMediaTypeTab(
                                'Files', _getMediaCount('Files')),
                          ),
                          Expanded(
                            child: _buildMediaTypeTab(
                                'Links', _getMediaCount('Links')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                filteredMedia.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getEmptyIcon(),
                                size: 64,
                                color: AppTheme.textSecondaryOnLight
                                    .withOpacity(0.3),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No $_selectedMediaType',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryOnLight,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _selectedMediaType == 'Photos'
                        ? _buildSliverMediaGrid(filteredMedia)
                        : _buildSliverMediaList(filteredMedia),
              ],
            ),
    );
  }

  IconData _getEmptyIcon() {
    switch (_selectedMediaType) {
      case 'Photos':
        return Icons.photo_library_outlined;
      case 'Voice':
        return Icons.mic_none;
      case 'Files':
        return Icons.insert_drive_file_outlined;
      case 'Links':
        return Icons.link_off;
      default:
        return Icons.folder_outlined;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.surfaceColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.surfaceColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeTab(String label, int count) {
    final isSelected = _selectedMediaType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMediaType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentOrange.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppTheme.accentOrange
                  : AppTheme.textSecondaryOnLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverMediaGrid(List<Map<String, dynamic>> media) {
    return SliverPadding(
      padding: const EdgeInsets.all(2),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = media[index];
            return _buildMediaItem(item);
          },
          childCount: media.length,
        ),
      ),
    );
  }

  Widget _buildSliverMediaList(List<Map<String, dynamic>> media) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = media[index];
          return Column(
            children: [
              _buildMediaRowItem(item),
              if (index < media.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 80,
                  color: AppTheme.dividerColor.withOpacity(0.3),
                ),
            ],
          );
        },
        childCount: media.length,
      ),
    );
  }

  Widget _buildMediaItem(Map<String, dynamic> item) {
    final type = item['type'] as String;

    switch (type) {
      case 'image':
        return GestureDetector(
          onTap: () {
            _showFullScreenImage(context, item['url'] as String);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.textSecondaryOnLight.withOpacity(0.05),
            ),
            child: ClipRRect(
              child: Image.network(
                item['url'] as String,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppTheme.accentOrange,
                      size: 32,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppTheme.textSecondaryOnLight.withOpacity(0.05),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );

      case 'voice':
        return GestureDetector(
          onTap: () {
            // Play voice message
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.08),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mic,
                  color: AppTheme.accentOrange,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Text(
                  item['duration'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'file':
        return GestureDetector(
          onTap: () {
            // Open file
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.08),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  color: AppTheme.accentOrange,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['size'] as String,
                  style: TextStyle(
                    fontSize: 8,
                    color: AppTheme.textSecondaryOnLight,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'link':
        return GestureDetector(
          onTap: () {
            // Open link
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.08),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.link,
                  color: AppTheme.accentOrange,
                  size: 28,
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );

      default:
        return Container();
    }
  }

  Widget _buildMediaRowItem(Map<String, dynamic> item) {
    final type = item['type'] as String;

    switch (type) {
      case 'voice':
        return _buildVoiceRowItem(item);
      case 'file':
        return _buildFileRowItem(item);
      case 'link':
        return _buildLinkRowItem(item);
      default:
        return Container();
    }
  }

  Widget _buildVoiceRowItem(Map<String, dynamic> item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Play voice message
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mic,
                  color: AppTheme.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.graphic_eq,
                          color: AppTheme.accentOrange,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['duration'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppTheme.textOnLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(item['timestamp'] as DateTime),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryOnLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.play_circle_outline,
                  color: AppTheme.accentOrange,
                  size: 28,
                ),
                onPressed: () {
                  // Play voice
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileRowItem(Map<String, dynamic> item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Open file
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insert_drive_file,
                  color: AppTheme.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textOnLight,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item['size'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryOnLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryOnLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(item['timestamp'] as DateTime),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryOnLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.download_outlined,
                  color: AppTheme.accentOrange,
                  size: 24,
                ),
                onPressed: () {
                  // Download file
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkRowItem(Map<String, dynamic> item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Open link
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link,
                  color: AppTheme.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textOnLight,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['url'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.accentOrange,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTimestamp(item['timestamp'] as DateTime),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondaryOnLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondaryOnLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _showBlockDialog(BuildContext context) {
    final user = _getUserData();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Block ${user?.name ?? 'User'}?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textOnLight,
            ),
          ),
          content: Text(
            'Are you sure you want to block this user? You won\'t receive messages from them anymore.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryOnLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textSecondaryOnLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user?.name ?? 'User'} has been blocked'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              },
              child: Text(
                'Block',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.black,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final user = _getUserData();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Delete Account?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textOnLight,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this account? This action cannot be undone.',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryOnLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textSecondaryOnLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${user?.name ?? 'User'}\'s account has been deleted'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Sticky Tab Bar Delegate for SliverPersistentHeader
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 56.0;

  @override
  double get maxExtent => 56.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
