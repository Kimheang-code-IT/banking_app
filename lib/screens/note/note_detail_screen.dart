import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/note.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({
    super.key,
    required this.note,
  });

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
        title: const Text(
          'Note Details',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppTheme.surfaceColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit note feature coming soon'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppTheme.surfaceColor,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delete note feature coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppTheme.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textOnLight,
              ),
            ),
            const SizedBox(height: 8),
            // Timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textSecondaryOnLight,
                ),
                const SizedBox(width: 4),
                Text(
                  'Created: ${note.getRelativeTime()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryOnLight,
                  ),
                ),
                if (note.updatedAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: AppTheme.textSecondaryOnLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated: ${note.getRelativeTime()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryOnLight,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textSecondaryOnLight.withOpacity(0.2),
                ),
              ),
              child: Text(
                note.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: AppTheme.textOnLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

