import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../models/message.dart';
import '../../services/mock_data_service.dart';
import 'user_profile_view_screen.dart';
import 'call_screen.dart';
import 'video_call_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatDetailScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final MockDataService _mockDataService = MockDataService();
  final ImagePicker _imagePicker = ImagePicker();
  List<Message> _messages = [];
  final String _currentUserId = '1';
  String? _editingMessageId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Auto-scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _loadMessages() {
    setState(() {
      _messages = _mockDataService.getMockMessages(widget.conversation.id);
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // If editing a message, update it instead of creating a new one
    if (_editingMessageId != null) {
      _editMessage(_editingMessageId!, text);
      _cancelEdit();
      return;
    }

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      receiverId: widget.conversation.participantIds
          .firstWhere((id) => id != _currentUserId),
      content: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _cancelEdit() {
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppTheme.accentOrange,
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(
                    color: AppTheme.textOnLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.accentOrange,
                ),
                title: const Text(
                  'Camera',
                  style: TextStyle(
                    color: AppTheme.textOnLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        _sendImageMessage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _sendImageMessage(File imageFile) {
    // In a real app, you would upload the image to a server and get a URL
    // For now, we'll use the file path as a placeholder
    final imagePath = imageFile.path;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: _currentUserId,
      receiverId: widget.conversation.participantIds
          .firstWhere((id) => id != _currentUserId),
      content: '📷 Photo',
      timestamp: DateTime.now(),
      isRead: false,
      imageUrl: imagePath,
    );

    setState(() {
      _messages.add(newMessage);
    });

    _scrollToBottom();
  }

  void _showReactionPicker(BuildContext context, Message message,
      GlobalKey messageKey, bool isSent) {
    final RenderBox? renderBox =
        messageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate position for reaction picker (Telegram style - centered above message)
    final pickerWidth = 300.0;
    final pickerHeight = 56.0;

    // Center the picker relative to the message bubble
    final messageCenterX = position.dx + (size.width / 2);
    double left = messageCenterX - (pickerWidth / 2);

    // Position above the message with spacing
    double top = position.dy - pickerHeight - 12;

    // Ensure it doesn't go off screen horizontally
    if (left < 12) left = 12;
    if (left + pickerWidth > screenWidth - 12) {
      left = screenWidth - pickerWidth - 12;
    }

    // If not enough space above, show below the message
    if (top < 12) {
      top = position.dy + size.height + 12;
    }

    // If not enough space below either, center vertically
    if (top + pickerHeight > screenHeight - 12) {
      top = (screenHeight - pickerHeight) / 2;
    }

    HapticFeedback.selectionClick();

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Stack(
          children: [
            // Transparent backdrop to close on tap
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Reaction picker with animation
            Positioned(
              left: left,
              top: top,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: Material(
                        color: Colors.transparent,
                        elevation: 0,
                        child: Container(
                          width: pickerWidth,
                          height: pickerHeight,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              '👍',
                              '❤️',
                              '😂',
                              '😮',
                              '😢',
                              '🙏',
                              '🔥',
                              '👏',
                              '🎉',
                              '💯'
                            ].asMap().entries.map((entry) {
                              final emoji = entry.value;
                              final index = entry.key;
                              final hasReaction =
                                  message.reactions.containsKey(emoji);
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(
                                  milliseconds: 150 + (index * 20),
                                ),
                                curve: Curves.easeOutBack,
                                builder: (context, animValue, child) {
                                  return Transform.scale(
                                    scale: animValue,
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.of(dialogContext).pop();
                                        if (hasReaction) {
                                          _toggleReaction(message.id, emoji);
                                        } else {
                                          _addReaction(message.id, emoji);
                                        }
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: hasReaction
                                              ? AppTheme.accentOrange
                                                  .withOpacity(0.2)
                                              : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: hasReaction
                                              ? Border.all(
                                                  color: AppTheme.accentOrange,
                                                  width: 2.5,
                                                )
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            emoji,
                                            style: const TextStyle(
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessageOptions(BuildContext context, Message message, int index) {
    final isSent = message.senderId == _currentUserId;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick reactions with more emojis
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        '👍',
                        '❤️',
                        '😂',
                        '😮',
                        '😢',
                        '🙏',
                        '🔥',
                        '👏',
                        '🎉',
                        '💯'
                      ].map((emoji) {
                        final hasReaction =
                            message.reactions.containsKey(emoji);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              if (hasReaction) {
                                _toggleReaction(message.id, emoji);
                              } else {
                                _addReaction(message.id, emoji);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: hasReaction
                                    ? AppTheme.accentOrange.withOpacity(0.15)
                                    : AppTheme.textSecondaryOnLight
                                        .withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: hasReaction
                                    ? Border.all(
                                        color: AppTheme.accentOrange,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 26),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                if (isSent) ...[
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: AppTheme.accentOrange,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Edit',
                      style: TextStyle(
                        color: AppTheme.textOnLight,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _startEditMessage(message);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Delete',
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmDialog(context, message.id);
                    },
                  ),
                ],
                if (!isSent) ...[
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.content_copy,
                        color: AppTheme.accentOrange,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Copy',
                      style: TextStyle(
                        color: AppTheme.textOnLight,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _copyMessage(message.content);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Delete',
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmDialog(context, message.id);
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addReaction(String messageId, String emoji) {
    HapticFeedback.selectionClick();
    setState(() {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final message = _messages[index];
        final updatedReactions = Map<String, int>.from(message.reactions);
        updatedReactions[emoji] = (updatedReactions[emoji] ?? 0) + 1;
        _messages[index] = message.copyWith(reactions: updatedReactions);
      }
    });
  }

  void _toggleReaction(String messageId, String emoji) {
    HapticFeedback.selectionClick();
    setState(() {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final message = _messages[index];
        final updatedReactions = Map<String, int>.from(message.reactions);
        if (updatedReactions.containsKey(emoji)) {
          if (updatedReactions[emoji]! > 1) {
            updatedReactions[emoji] = updatedReactions[emoji]! - 1;
          } else {
            updatedReactions.remove(emoji);
          }
        } else {
          updatedReactions[emoji] = 1;
        }
        _messages[index] = message.copyWith(reactions: updatedReactions);
      }
    });
  }

  void _removeReaction(String messageId, String emoji) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final message = _messages[index];
        final updatedReactions = Map<String, int>.from(message.reactions);
        if (updatedReactions.containsKey(emoji)) {
          if (updatedReactions[emoji]! > 1) {
            updatedReactions[emoji] = updatedReactions[emoji]! - 1;
          } else {
            updatedReactions.remove(emoji);
          }
          _messages[index] = message.copyWith(reactions: updatedReactions);
        }
      }
    });
  }

  void _copyMessage(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message copied to clipboard'),
          backgroundColor: AppTheme.accentOrange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _startEditMessage(Message message) {
    setState(() {
      _editingMessageId = message.id;
      _messageController.text = message.content;
    });
    // Scroll to bottom and focus on the input field
    _scrollToBottom();
    // Focus on the text field after a short delay to ensure the UI is updated
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _messageFocusNode.requestFocus();
        // Move cursor to end of text
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
      }
    });
  }

  void _showEditDialog(BuildContext context, Message message) {
    _editController.text = message.content;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Message',
            style: TextStyle(
              color: AppTheme.textOnLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: _editController,
            autofocus: true,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.3),
                ),
              ),
              filled: true,
              fillColor: AppTheme.textSecondaryOnLight.withOpacity(0.1),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textSecondaryOnLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newContent = _editController.text.trim();
                if (newContent.isNotEmpty) {
                  _editMessage(message.id, newContent);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppTheme.accentOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editMessage(String messageId, String newContent) {
    setState(() {
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(
          content: newContent,
          isEdited: true,
          editedAt: DateTime.now(),
        );
      }
    });
  }

  void _showDeleteConfirmDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Message',
            style: TextStyle(
              color: AppTheme.textOnLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this message?',
            style: TextStyle(
              color: AppTheme.textSecondaryOnLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textSecondaryOnLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(messageId);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(String messageId) {
    setState(() {
      _messages.removeWhere((m) => m.id == messageId);
    });
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
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
                  child: Image.file(
                    File(imagePath),
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

  String _getRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;
    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];
    final difference =
        currentMessage.timestamp.difference(previousMessage.timestamp);
    return difference.inMinutes > 5;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _editController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.surfaceColor,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: GestureDetector(
          onTap: () {
            final otherUserId = widget.conversation.participantIds
                .firstWhere((id) => id != _currentUserId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileViewScreen(
                  userId: otherUserId,
                  userName: widget.conversation.otherUserName,
                  userAvatar: widget.conversation.otherUserAvatar,
                  isOnline: widget.conversation.isOnline,
                  conversationId: widget.conversation.id,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.surfaceColor.withOpacity(0.2),
                    child: Text(
                      widget.conversation.otherUserName?[0].toUpperCase() ??
                          'U',
                      style: const TextStyle(
                        color: AppTheme.surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.conversation.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.accentOrange,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.conversation.otherUserName ?? 'User',
                      style: const TextStyle(
                        color: AppTheme.surfaceColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.conversation.isOnline)
                      const Text(
                        'Online',
                        style: TextStyle(
                          color: AppTheme.surfaceColor,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.videocam,
              color: AppTheme.surfaceColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
                    userName: widget.conversation.otherUserName ?? 'User',
                    userAvatar: widget.conversation.otherUserAvatar,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.phone,
              color: AppTheme.surfaceColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    userName: widget.conversation.otherUserName ?? 'User',
                    userAvatar: widget.conversation.otherUserAvatar,
                    isVideoCall: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBackground,
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        color: AppTheme.textSecondaryOnLight,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isSent = message.senderId == _currentUserId;
                      final showTimestamp = _shouldShowTimestamp(index);
                      final messageKey = GlobalKey<State<StatefulWidget>>();

                      final children = <Widget>[
                        if (showTimestamp)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _getRelativeTime(message.timestamp),
                              style: const TextStyle(
                                color: AppTheme.textSecondaryOnLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: isSent
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: GestureDetector(
                                onLongPress: () => _showMessageOptions(
                                    context, message, index),
                                child: Container(
                                  key: messageKey,
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.75,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    crossAxisAlignment: isSent
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      message.imageUrl != null
                                          ? GestureDetector(
                                              onTap: () => _showFullScreenImage(
                                                  context, message.imageUrl!),
                                              onLongPress: () =>
                                                  _showMessageOptions(
                                                      context, message, index),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                child: Image.file(
                                                  File(message.imageUrl!),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 200,
                                                      height: 200,
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .textSecondaryOnLight
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(18),
                                                      ),
                                                      child: const Icon(
                                                        Icons.image_outlined,
                                                        color: AppTheme
                                                            .accentOrange,
                                                        size: 48,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSent
                                                    ? AppTheme.accentOrange
                                                    : AppTheme
                                                        .textSecondaryOnLight
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: isSent
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    message.content,
                                                    style: TextStyle(
                                                      color: isSent
                                                          ? AppTheme
                                                              .surfaceColor
                                                          : AppTheme
                                                              .textOnLight,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  if (message.isEdited)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.edit,
                                                            size: 10,
                                                            color: isSent
                                                                ? AppTheme
                                                                    .surfaceColor
                                                                    .withOpacity(
                                                                        0.7)
                                                                : AppTheme
                                                                    .textSecondaryOnLight,
                                                          ),
                                                          const SizedBox(
                                                              width: 2),
                                                          Text(
                                                            'edited',
                                                            style: TextStyle(
                                                              color: isSent
                                                                  ? AppTheme
                                                                      .surfaceColor
                                                                      .withOpacity(
                                                                          0.7)
                                                                  : AppTheme
                                                                      .textSecondaryOnLight,
                                                              fontSize: 11,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ];

                      // Add reactions if they exist
                      if (message.reactions.isNotEmpty) {
                        children.add(
                          Align(
                            alignment: isSent
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                right: isSent ? 8 : 0,
                                left: isSent ? 0 : 8,
                              ),
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children:
                                    message.reactions.entries.map((entry) {
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutBack,
                                    builder: (context, animValue, child) {
                                      return Transform.scale(
                                        scale: animValue,
                                        child: GestureDetector(
                                          onTap: () {
                                            HapticFeedback.lightImpact();
                                            _toggleReaction(
                                                message.id, entry.key);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 4,
                                              right: 4,
                                              bottom: 0,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  entry.key,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (entry.value > 1)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 3),
                                                    child: Text(
                                                      '${entry.value}',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: isSent
                                                            ? AppTheme
                                                                .accentOrange
                                                            : AppTheme
                                                                .textOnLight,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: children,
                      );
                    },
                  ),
          ),
          // Input field
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show edit indicator when editing
                    if (_editingMessageId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange.withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: AppTheme.accentOrange.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: AppTheme.accentOrange,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Editing message',
                                style: TextStyle(
                                  color: AppTheme.accentOrange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _cancelEdit,
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: AppTheme.accentOrange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.accentOrange,
                          onPressed: _editingMessageId != null
                              ? null
                              : _showImageSourceBottomSheet,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            decoration: InputDecoration(
                              hintText: _editingMessageId != null
                                  ? 'Edit your message...'
                                  : 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor:
                                  AppTheme.textSecondaryOnLight.withOpacity(0.1),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              _editingMessageId != null
                                  ? Icons.check
                                  : Icons.send,
                            ),
                            color: AppTheme.surfaceColor,
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
