import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_note_taking_app/providers/auth_provider.dart';
import 'package:ai_note_taking_app/providers/theme_provider.dart';
import 'package:ai_note_taking_app/screens/note_editor_screen.dart';
import 'package:ai_note_taking_app/widgets/note_card.dart';
import 'package:ai_note_taking_app/models/note.dart';
import 'package:ai_note_taking_app/providers/note_provider.dart';
import 'package:ai_note_taking_app/theme/app_theme.dart';
import 'package:ai_note_taking_app/theme/app_animations.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Load notes when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
    });
    // Set up auto-refresh timer (every 30 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        Provider.of<NoteProvider>(context, listen: false).loadNotes();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _deleteNote(BuildContext context, int id) async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    try {
      await noteProvider.deleteNote(id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete note: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openNoteEditor(BuildContext context, Note? note) async {
    final updatedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
    
    if (updatedNote != null && mounted) {
      // Refresh notes after editing
      Provider.of<NoteProvider>(context, listen: false).loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          AppAnimations.animatedButton(
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: themeProvider.isDarkMode ? Colors.amber : AppTheme.primaryColor,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
              tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            ),
          ),
          AppAnimations.animatedButton(
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          ),
        ],
      ),
      body: Consumer<NoteProvider>(
        builder: (context, noteProvider, child) {
          if (noteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (noteProvider.error != null) {
            return AppAnimations.fadeIn(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${noteProvider.error}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.errorColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    AppAnimations.animatedButton(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          noteProvider.clearError();
                          noteProvider.loadNotes();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (noteProvider.notes.isEmpty) {
            return AppAnimations.fadeIn(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.note_add,
                      size: 64,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notes yet. Create your first note!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return AppAnimations.fadeIn(
            child: RefreshIndicator(
              onRefresh: () => noteProvider.loadNotes(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: noteProvider.notes.length,
                itemBuilder: (context, index) {
                  final note = noteProvider.notes[index];
                  return NoteCard(
                    note: note,
                    index: index,
                    onTap: () => _openNoteEditor(context, note),
                    onDelete: () => _deleteNote(context, note.id!),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: AppAnimations.scaleIn(
        child: FloatingActionButton(
          onPressed: () => _openNoteEditor(context, null),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
} 