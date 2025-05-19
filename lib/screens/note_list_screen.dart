import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ai_note_taking_app/providers/note_provider.dart';
import 'package:ai_note_taking_app/screens/note_editor_screen.dart';
import 'package:ai_note_taking_app/theme/app_theme.dart';
import 'package:ai_note_taking_app/theme/app_animations.dart';

class NoteListScreen extends StatelessWidget {
  const NoteListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          AppAnimations.animatedButton(
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NoteEditorScreen(),
                  ),
                );
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
                  return AppAnimations.staggeredListItem(
                    index: index,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteEditorScreen(note: note),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: theme.brightness == Brightness.dark 
                              ? [
                                  Colors.grey[900]!,
                                  Colors.grey[850]!,
                                ]
                              : AppTheme.lightCardGradient,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      note.title,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.brightness == Brightness.dark
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: AppTheme.errorColor,
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                            'Delete Note',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          content: Text(
                                            'Are you sure you want to delete this note?',
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: Text(
                                                'Cancel',
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  color: theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: Text(
                                                'Delete',
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  color: AppTheme.errorColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed == true) {
                                        await noteProvider.deleteNote(note.id!);
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note.content,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.brightness == Brightness.dark
                                    ? Colors.grey[300]
                                    : theme.colorScheme.onSurface.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Created: ${_formatDate(note.createdAt)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.brightness == Brightness.dark
                                        ? Colors.grey[400]
                                        : theme.colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  if (note.isMarkdown)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.brightness == Brightness.dark
                                          ? AppTheme.primaryColor.withOpacity(0.2)
                                          : AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.code,
                                            size: 16,
                                            color: theme.brightness == Brightness.dark
                                              ? Colors.white
                                              : AppTheme.primaryColor,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Markdown',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.brightness == Brightness.dark
                                                ? Colors.white
                                                : AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: AppAnimations.scaleIn(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoteEditorScreen(),
              ),
            );
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 