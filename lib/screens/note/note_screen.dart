import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/note.dart';
import '../../services/mock_data_service.dart';
import 'note_detail_screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final MockDataService _mockDataService = MockDataService();
  final TextEditingController _searchController = TextEditingController();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    setState(() {
      _notes = _mockDataService.getMockNotes();
      _filteredNotes = _notes;
    });
  }

  void _filterNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = _notes;
      } else {
        _filteredNotes = _notes
            .where((note) =>
                note.title.toLowerCase().contains(query.toLowerCase()) ||
                note.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.accentOrange,
        elevation: 0,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Icon(
            Icons.account_balance,
            color: AppTheme.surfaceColor,
            size: 28,
          ),
        ),
        title: const Text(
          'Notes',
          style: TextStyle(
            color: AppTheme.surfaceColor,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: AppTheme.surfaceColor,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _filteredNotes = _notes;
                  }
                });
              },
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.accentOrange,
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.lightBackground,
        ),
        child: Column(
          children: [
            // Search bar
            if (_isSearching)
              Container(
                color: AppTheme.lightBackground,
                padding: const EdgeInsets.all(8),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterNotes('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.textSecondaryOnLight.withOpacity(0.1),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _filterNotes,
                ),
              ),
            // Notes list
            Expanded(
              child: _filteredNotes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 64,
                            color: AppTheme.textSecondaryOnLight.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isSearching
                                ? 'No notes found'
                                : 'No notes yet',
                            style: TextStyle(
                              color: AppTheme.textSecondaryOnLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                        _loadNotes();
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _filteredNotes.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          indent: 80,
                          color: AppTheme.textSecondaryOnLight.withOpacity(0.1),
                        ),
                        itemBuilder: (context, index) {
                          final note = _filteredNotes[index];
                          return _buildNoteItem(note);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New note feature coming soon'),
            ),
          );
        },
        backgroundColor: AppTheme.accentOrange,
        child: const Icon(
          Icons.add,
          color: AppTheme.surfaceColor,
        ),
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailScreen(note: note),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Note icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.note,
                color: AppTheme.accentOrange,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Title, preview, and timestamp
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textOnLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        note.getRelativeTime(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryOnLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.getPreview(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryOnLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondaryOnLight,
            ),
          ],
        ),
      ),
    );
  }
}
