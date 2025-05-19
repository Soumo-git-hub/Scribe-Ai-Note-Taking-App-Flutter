import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_note_taking_app/providers/auth_provider.dart';
import 'package:ai_note_taking_app/services/api_service.dart';
import 'package:ai_note_taking_app/models/note.dart';
import 'package:ai_note_taking_app/widgets/ai_feature_button.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ai_note_taking_app/providers/note_provider.dart';
import 'package:ai_note_taking_app/widgets/mindmap_widget.dart';
import 'package:ai_note_taking_app/theme/app_theme.dart';
import 'package:ai_note_taking_app/theme/app_animations.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;
  String? _error;
  String? _summary;
  String? _quiz;
  Map<String, dynamic>? _mindmap;
  String? _audioUrl;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, dynamic>? _quizData;
  Map<String, String> _userAnswers = {};
  bool _showAnswers = false;
  bool _isMarkdown = false;
  bool _isPreview = false;
  bool _isSaving = false;
  bool _isGeneratingSummary = false;
  bool _isGeneratingQuiz = false;
  bool _isGeneratingMindmap = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _summary = widget.note?.summary;
    _quiz = widget.note?.quiz;
    _isMarkdown = widget.note?.isMarkdown ?? false;

    // Initialize quiz data if available
    if (_quiz != null && _quiz!.isNotEmpty) {
      try {
        _quizData = json.decode(_quiz!);
        // Ensure quiz data has the required structure
        if (_quizData != null) {
          _quizData = {
            'mcq': _quizData!['mcq'] ?? [],
            'true_false': _quizData!['true_false'] ?? [],
            'fill_blank': _quizData!['fill_blank'] ?? [],
          };
        }
      } catch (e) {
        print('Error parsing quiz data: $e');
        _quizData = {
          'mcq': [],
          'true_false': [],
          'fill_blank': [],
        };
      }
    } else {
      _quizData = {
        'mcq': [],
        'true_false': [],
        'fill_blank': [],
      };
    }

    // Initialize audio player state listener
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    try {
      setState(() => _isSaving = true);

      // Convert mindmap to string if it exists
      String? mindmapString;
      if (_mindmap != null) {
        try {
          mindmapString = jsonEncode(_mindmap);
          print('Encoded mindmap: $mindmapString');
        } catch (e) {
          print('Error encoding mindmap: $e');
        }
      }

      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      if (widget.note == null) {
        // Creating a new note
        final createdNote = await noteProvider.createNote(
          _titleController.text,
          _contentController.text,
          summary: _summary ?? '',
          quiz: _quiz ?? '',
          mindmap: _mindmap,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note created successfully')),
          );
          Navigator.pop(context, createdNote);
        }
      } else {
        // Updating existing note
        final note = Note(
          id: widget.note?.id,
          title: _titleController.text,
          content: _contentController.text,
          summary: _summary ?? '',
          quiz: _quiz ?? '',
          mindmap: _mindmap,
          isMarkdown: _isMarkdown,
          createdAt: widget.note?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await noteProvider.updateNote(note);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note updated successfully')),
          );
          Navigator.pop(context, note);
        }
      }
    } catch (e) {
      print('Error saving note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _loadNote() async {
    if (widget.note == null) return;

    try {
      setState(() => _isLoading = true);
      final note = await ApiService.getNote(widget.note!.id!);
      
      if (mounted) {
        setState(() {
          _titleController.text = note.title;
          _contentController.text = note.content;
          _summary = note.summary;
          _quiz = note.quiz;
          _mindmap = note.mindmap;
          _isMarkdown = note.isMarkdown;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading note: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateSummary() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingSummary = true;
      _error = null;
    });

    try {
      final summary = await ApiService.generateSummary(_contentController.text);
      if (mounted) {
        setState(() {
          _summary = summary;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating summary: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
      }
    }
  }

  Future<void> _generateQuiz() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingQuiz = true;
      _error = null;
      _quizData = {
        'mcq': [],
        'true_false': [],
        'fill_blank': [],
      };
      _userAnswers.clear();
      _showAnswers = false;
    });

    try {
      final quizData = await ApiService.generateQuiz(_contentController.text);

      if (mounted) {
        setState(() {
          _quizData = quizData;
          _quiz = json.encode(_quizData);
        });
      }
    } catch (e) {
      print('Error generating quiz: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _quizData = {
            'mcq': [],
            'true_false': [],
            'fill_blank': [],
          };
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating quiz: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingQuiz = false;
        });
      }
    }
  }

  Future<void> _generateMindmap() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some content first')),
      );
      return;
    }

    setState(() {
      _isGeneratingMindmap = true;
    });

    try {
      final mindmapData = await ApiService.generateMindmap(_contentController.text);
      if (mounted) {
        setState(() {
          _mindmap = mindmapData;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate mind map: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingMindmap = false;
        });
      }
    }
  }

  Future<void> _textToSpeech() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final Map<String, dynamic>? response = await ApiService.textToSpeech(_contentController.text);
      
      if (response != null && response['audio_url'] != null) {
        setState(() {
          _audioUrl = '/api/audio/tts_output.wav';
          _isPlaying = false; // Reset playing state
        });
      } else {
        throw Exception('Failed to generate audio');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating audio: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_audioUrl != null) {
          // Configure audio session
          final session = await AudioSession.instance;
          await session.configure(const AudioSessionConfiguration.speech());

          // Stop any existing playback
          await _audioPlayer.stop();

          // Set up the audio source with the correct URL
          final audioSource = AudioSource.uri(
            Uri.parse('http://127.0.0.1:8000$_audioUrl'),
            headers: {
              'Cache-Control': 'no-cache',
              'Pragma': 'no-cache',
            },
          );

          // Set the audio source and play
          await _audioPlayer.setAudioSource(audioSource);
          await _audioPlayer.play();
        } else {
          await _textToSpeech();
        }
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
      setState(() {
        _error = e.toString();
        _isPlaying = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void _checkAnswers() {
    // Get all questions
    final mcqList = _quizData?['mcq'] as List? ?? [];
    final tfList = _quizData?['true_false'] as List? ?? [];
    final fbList = _quizData?['fill_blank'] as List? ?? [];

    // Check if all questions are answered
    bool allAnswered = true;
    String unansweredQuestion = '';

    // Check MCQ questions
    for (var q in mcqList) {
      if (q != null && q is Map<String, dynamic>) {
        final questionId = q['question']?.toString() ?? '';
        if (_userAnswers[questionId] == null || _userAnswers[questionId]!.isEmpty) {
          allAnswered = false;
          unansweredQuestion = q['question']?.toString() ?? 'a multiple choice question';
          break;
        }
      }
    }

    // Check True/False questions
    if (allAnswered) {
      for (var q in tfList) {
        if (q != null && q is Map<String, dynamic>) {
          final questionId = q['question']?.toString() ?? '';
          if (_userAnswers[questionId] == null || _userAnswers[questionId]!.isEmpty) {
            allAnswered = false;
            unansweredQuestion = q['question']?.toString() ?? 'a true/false question';
            break;
          }
        }
      }
    }

    // Check Fill in the Blank questions
    if (allAnswered) {
      for (var q in fbList) {
        if (q != null && q is Map<String, dynamic>) {
          final questionId = q['question']?.toString() ?? '';
          if (_userAnswers[questionId] == null || _userAnswers[questionId]!.isEmpty) {
            allAnswered = false;
            unansweredQuestion = q['question']?.toString() ?? 'a fill in the blank question';
            break;
          }
        }
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please answer all questions first. You missed: $unansweredQuestion'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _showAnswers = true;
    });
  }

  void _resetQuiz() {
    setState(() {
      _userAnswers.clear();
      _showAnswers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Editor'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? AppTheme.darkAppBarGradient : AppTheme.lightAppBarGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMarkdown ? Icons.code : Icons.text_fields,
              color: _isMarkdown ? AppTheme.primaryColor : theme.iconTheme.color,
            ),
            onPressed: () {
              setState(() {
                _isMarkdown = !_isMarkdown;
                _isPreview = _isMarkdown;
              });
            },
            tooltip: _isMarkdown ? 'Switch to Plain Text' : 'Switch to Markdown',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Delete Note',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to delete this note?',
                      style: theme.textTheme.bodyLarge,
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
                            color: AppTheme.primaryColor,
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

                if (confirmed == true && mounted) {
                  try {
                    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
                    await noteProvider.deleteNote(widget.note!.id!);
                    if (mounted) {
                      Navigator.pop(context);
                    }
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
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : AppAnimations.fadeIn(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Add a beautiful header section
                        AppAnimations.slideIn(
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark ? AppTheme.darkPrimaryGradient : AppTheme.primaryGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowColor,
                                  blurRadius: AppTheme.mediumElevation,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppTheme.smallSpacing),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                      ),
                                      child: Icon(
                                        Icons.edit_note,
                                        color: Colors.white,
                                        size: AppTheme.largeIcon,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.mediumSpacing),
                                    Text(
                                      'Create Your Note',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: AppTheme.boldWeight,
                                        letterSpacing: AppTheme.tightSpacing,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppTheme.mediumSpacing),
                                Text(
                                  'Express your thoughts and ideas with our AI-powered note editor',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    height: AppTheme.normalHeight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.largeSpacing),
                        AppAnimations.slideIn(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              prefixIcon: Icon(
                                Icons.title,
                                color: AppTheme.primaryColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                                borderSide: BorderSide(
                                  color: AppTheme.borderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: AppTheme.semiBoldWeight,
                              ),
                            ),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: AppTheme.boldWeight,
                              letterSpacing: AppTheme.tightSpacing,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: AppTheme.mediumSpacing),
                        AppAnimations.slideIn(
                          offset: const Offset(0, 20),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.5,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                              border: Border.all(
                                color: AppTheme.borderColor,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowColor,
                                  blurRadius: AppTheme.mediumElevation,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _isMarkdown && _isPreview
                                ? Markdown(
                                    data: _contentController.text,
                                    selectable: true,
                                    styleSheet: MarkdownStyleSheet(
                                      h1: theme.textTheme.headlineLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: AppTheme.boldWeight,
                                      ),
                                      h2: theme.textTheme.headlineMedium?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: AppTheme.boldWeight,
                                      ),
                                      h3: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: AppTheme.boldWeight,
                                      ),
                                      p: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        height: AppTheme.normalHeight,
                                      ),
                                      code: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: AppTheme.largeFont,
                                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      codeblockDecoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                      ),
                                    ),
                                  )
                                : TextField(
                                    controller: _contentController,
                                    decoration: InputDecoration(
                                      labelText: _isMarkdown ? 'Markdown Content' : 'Content',
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.all(AppTheme.mediumSpacing),
                                      hintText: _isMarkdown
                                          ? '# Heading\n## Subheading\n- List item\n1. Numbered item\n```code```'
                                          : 'Enter your note content here...',
                                      hintStyle: TextStyle(
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                      floatingLabelStyle: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: AppTheme.semiBoldWeight,
                                      ),
                                    ),
                                    maxLines: null,
                                    expands: true,
                                    keyboardType: TextInputType.multiline,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                      height: AppTheme.normalHeight,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.largeSpacing),
                        AppAnimations.slideIn(
                          offset: const Offset(0, 40),
                          child: Container(
                            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                              border: Border.all(
                                color: AppTheme.borderColor,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowColor,
                                  blurRadius: AppTheme.smallElevation,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppTheme.smallSpacing),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                      ),
                                      child: Icon(
                                        Icons.auto_awesome,
                                        color: AppTheme.primaryColor,
                                        size: AppTheme.mediumIcon,
                                      ),
                                    ),
                                    const SizedBox(width: AppTheme.mediumSpacing),
                                    Text(
                                      'AI Features',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: AppTheme.semiBoldWeight,
                                        letterSpacing: AppTheme.tightSpacing,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppTheme.mediumSpacing),
                                Wrap(
                                  spacing: AppTheme.mediumSpacing,
                                  runSpacing: AppTheme.mediumSpacing,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    AIFeatureButton(
                                      text: 'Generate Summary',
                                      icon: Icons.summarize,
                                      onPressed: _isGeneratingSummary ? null : () async { await _generateSummary(); },
                                      isLoading: _isGeneratingSummary,
                                    ),
                                    AIFeatureButton(
                                      text: 'Generate Quiz',
                                      icon: Icons.quiz,
                                      onPressed: _isGeneratingQuiz ? null : () async { await _generateQuiz(); },
                                      isLoading: _isGeneratingQuiz,
                                    ),
                                    AIFeatureButton(
                                      text: 'Generate Mindmap',
                                      icon: Icons.account_tree,
                                      onPressed: _isGeneratingMindmap ? null : () async { await _generateMindmap(); },
                                      isLoading: _isGeneratingMindmap,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_summary != null) ...[
                          const SizedBox(height: AppTheme.largeSpacing),
                          AppAnimations.slideIn(
                            offset: const Offset(0, 60),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark ? AppTheme.darkCardGradient : AppTheme.lightCardGradient,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(AppTheme.smallSpacing),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                            ),
                                            child: Icon(
                                              Icons.summarize,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: AppTheme.mediumSpacing),
                                          Text(
                                            'Summary',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: AppTheme.boldWeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppTheme.mediumSpacing),
                                      Container(
                                        padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                          border: Border.all(
                                            color: AppTheme.borderColor,
                                          ),
                                        ),
                                        child: Text(
                                          _summary!,
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            height: AppTheme.normalHeight,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (_quiz != null) ...[
                          const SizedBox(height: AppTheme.largeSpacing),
                          AppAnimations.slideIn(
                            offset: const Offset(0, 80),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark ? AppTheme.darkCardGradient : AppTheme.lightCardGradient,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(AppTheme.smallSpacing),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                            ),
                                            child: Icon(
                                              Icons.quiz,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: AppTheme.mediumSpacing),
                                          Text(
                                            'Quiz',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: AppTheme.boldWeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppTheme.mediumSpacing),
                                      _buildQuizSection(_quizData!),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (_mindmap != null) ...[
                          const SizedBox(height: AppTheme.largeSpacing),
                          AppAnimations.slideIn(
                            offset: const Offset(0, 100),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: isDark ? AppTheme.darkCardGradient : AppTheme.lightCardGradient,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(AppTheme.smallSpacing),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                            ),
                                            child: Icon(
                                              Icons.account_tree,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: AppTheme.mediumSpacing),
                                          Text(
                                            'Mind Map',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: AppTheme.boldWeight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppTheme.mediumSpacing),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                          border: Border.all(
                                            color: AppTheme.borderColor,
                                          ),
                                        ),
                                        child: _isGeneratingMindmap
                                            ? const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(AppTheme.mediumSpacing),
                                                  child: CircularProgressIndicator(),
                                                ),
                                              )
                                            : MindMapWidget(mindMapData: _mindmap),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: AppTheme.mediumSpacing),
                          AppAnimations.fadeIn(
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                                border: Border.all(
                                  color: AppTheme.errorColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppTheme.errorColor,
                                  ),
                                  const SizedBox(width: AppTheme.mediumSpacing),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildQuizSection(Map<String, dynamic> quizData) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (quizData == null || quizData.isEmpty) {
      return const Center(child: Text('No quiz available'));
    }

    // Ensure all required sections exist
    final mcqList = quizData['mcq'] as List? ?? [];
    final tfList = quizData['true_false'] as List? ?? [];
    final fbList = quizData['fill_blank'] as List? ?? [];

    // Calculate total questions and score only if answers are checked
    int totalQuestions = 0;
    int correctAnswers = 0;
    double scorePercentage = 0;

    if (_showAnswers) {
      // Count total questions and correct answers with null checks
      totalQuestions += mcqList.where((q) => q != null && q is Map<String, dynamic>).length;
      correctAnswers += mcqList.where((q) {
        if (q == null || q is! Map<String, dynamic>) return false;
        final questionId = q['question']?.toString() ?? '';
        final userAnswer = _userAnswers[questionId];
        final correctAnswer = q['answer']?.toString();
        return userAnswer != null && correctAnswer != null && userAnswer == correctAnswer;
      }).length;

      totalQuestions += tfList.where((q) => q != null && q is Map<String, dynamic>).length;
      correctAnswers += tfList.where((q) {
        if (q == null || q is! Map<String, dynamic>) return false;
        final questionId = q['question']?.toString() ?? '';
        final userAnswer = _userAnswers[questionId];
        final correctAnswer = q['answer']?.toString();
        return userAnswer != null && correctAnswer != null && 
               userAnswer.toLowerCase() == correctAnswer.toLowerCase();
      }).length;

      totalQuestions += fbList.where((q) => q != null && q is Map<String, dynamic>).length;
      correctAnswers += fbList.where((q) {
        if (q == null || q is! Map<String, dynamic>) return false;
        final questionId = q['question']?.toString() ?? '';
        final userAnswer = _userAnswers[questionId];
        final correctAnswer = q['answer']?.toString();
        return userAnswer != null && correctAnswer != null && 
               userAnswer.toLowerCase().trim() == correctAnswer.toLowerCase().trim();
      }).length;

      // Calculate percentage
      scorePercentage = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppAnimations.animatedButton(
              child: ElevatedButton.icon(
                onPressed: _showAnswers ? null : _checkAnswers,
                icon: const Icon(Icons.check_circle),
                label: const Text('Check Answers'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumSpacing, vertical: AppTheme.smallSpacing),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                ),
              ),
            ),
            AppAnimations.animatedButton(
              child: ElevatedButton.icon(
                onPressed: _resetQuiz,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumSpacing, vertical: AppTheme.smallSpacing),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.mediumSpacing),
        // Score display (only shown after checking answers)
        if (_showAnswers) ...[
          Container(
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            margin: const EdgeInsets.only(bottom: AppTheme.mediumSpacing),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.smallRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: AppTheme.smallElevation,
                  offset: const Offset(0, AppTheme.smallSpacing),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiz Score',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: AppTheme.boldWeight,
                      ),
                    ),
                    const SizedBox(height: AppTheme.smallSpacing),
                    Text(
                      '$correctAnswers out of $totalQuestions correct',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumSpacing, vertical: AppTheme.smallSpacing),
                  decoration: BoxDecoration(
                    color: _getScoreColor(scorePercentage),
                    borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                  ),
                  child: Text(
                    '${scorePercentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTheme.boldWeight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Quiz sections
        if (mcqList.isNotEmpty) ...[
          Text(
            'Multiple Choice Questions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: AppTheme.boldWeight,
            ),
          ),
          const SizedBox(height: AppTheme.mediumSpacing),
          ...mcqList
              .where((q) => q != null && q is Map<String, dynamic>)
              .map((q) => _buildMCQQuestion(q as Map<String, dynamic>))
              .toList(),
        ],
        if (tfList.isNotEmpty) ...[
          const SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'True/False Questions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: AppTheme.boldWeight,
            ),
          ),
          const SizedBox(height: AppTheme.mediumSpacing),
          ...tfList
              .where((q) => q != null && q is Map<String, dynamic>)
              .map((q) => _buildTrueFalseQuestion(q as Map<String, dynamic>))
              .toList(),
        ],
        if (fbList.isNotEmpty) ...[
          const SizedBox(height: AppTheme.mediumSpacing),
          Text(
            'Fill in the Blank Questions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: AppTheme.boldWeight,
            ),
          ),
          const SizedBox(height: AppTheme.mediumSpacing),
          ...fbList
              .where((q) => q != null && q is Map<String, dynamic>)
              .map((q) => _buildFillBlankQuestion(q as Map<String, dynamic>))
              .toList(),
        ],
      ],
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMCQQuestion(Map<String, dynamic> question) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (question == null) return const SizedBox.shrink();
    
    final questionId = question['question']?.toString() ?? '';
    final userAnswer = _userAnswers[questionId] ?? '';
    final isCorrect = _showAnswers && userAnswer == question['answer']?.toString();
    final options = question['options'] as List? ?? [];

    return AppAnimations.scaleIn(
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.mediumSpacing),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeRadius),
          side: BorderSide(
            color: _showAnswers
                ? (isCorrect ? Colors.green : Colors.red)
                : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? AppTheme.darkCardGradient : AppTheme.lightCardGradient,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['question']?.toString() ?? 'Question',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.mediumSpacing),
                ...options.where((o) => o != null).map((option) => RadioListTile<String>(
                  title: Text(
                    option.toString(),
                    style: theme.textTheme.bodyLarge,
                  ),
                  value: option.toString(),
                  groupValue: userAnswer,
                  onChanged: _showAnswers ? null : (value) {
                    if (value != null) {
                      setState(() {
                        _userAnswers[questionId] = value;
                      });
                    }
                  },
                  activeColor: _showAnswers 
                    ? (isCorrect ? Colors.green : Colors.red)
                    : AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumSpacing),
                )),
                if (_showAnswers && question['answer'] != null) ...[
                  const SizedBox(height: AppTheme.mediumSpacing),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: AppTheme.mediumSpacing),
                        Text(
                          'Correct Answer: ${question['answer']}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: AppTheme.boldWeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrueFalseQuestion(Map<String, dynamic> question) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final questionId = question['question'].toString();
    final userAnswer = _userAnswers[questionId] ?? '';
    final isCorrect = _showAnswers && userAnswer == question['answer'].toString();

    return AppAnimations.scaleIn(
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.mediumSpacing),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeRadius),
          side: BorderSide(
            color: _showAnswers
                ? (isCorrect ? Colors.green : Colors.red)
                : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? AppTheme.darkCardGradient : AppTheme.lightCardGradient,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['question'] ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.mediumSpacing),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('True'),
                        value: 'true',
                        groupValue: userAnswer.isEmpty ? null : userAnswer,
                        onChanged: _showAnswers ? null : (value) {
                          setState(() {
                            _userAnswers[questionId] = value!;
                          });
                        },
                        activeColor: _showAnswers 
                          ? (isCorrect ? Colors.green : Colors.red)
                          : AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('False'),
                        value: 'false',
                        groupValue: userAnswer.isEmpty ? null : userAnswer,
                        onChanged: _showAnswers ? null : (value) {
                          setState(() {
                            _userAnswers[questionId] = value!;
                          });
                        },
                        activeColor: _showAnswers 
                          ? (isCorrect ? Colors.green : Colors.red)
                          : AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showAnswers) ...[
                  const SizedBox(height: AppTheme.mediumSpacing),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: AppTheme.mediumSpacing),
                        Text(
                          'Correct Answer: ${question['answer']}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: AppTheme.boldWeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFillBlankQuestion(Map<String, dynamic> question) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final questionId = question['question'].toString();
    final userAnswer = _userAnswers[questionId] ?? '';
    final isCorrect = _showAnswers && 
      userAnswer.toLowerCase().trim() == question['answer'].toString().toLowerCase().trim();

    return AppAnimations.scaleIn(
      child: Card(
        margin: const EdgeInsets.only(bottom: AppTheme.mediumSpacing),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.largeRadius),
          side: BorderSide(
            color: _showAnswers
                ? (isCorrect ? Colors.green : Colors.red)
                : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? AppTheme.darkCardGradient : AppTheme.lightCardGradient,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.mediumSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question['question'] ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: AppTheme.mediumSpacing),
                TextField(
                  enabled: !_showAnswers,
                  decoration: InputDecoration(
                    hintText: 'Enter your answer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                    ),
                    filled: _showAnswers,
                    fillColor: _showAnswers 
                      ? (isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
                      : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.mediumSpacing, vertical: AppTheme.smallSpacing),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _userAnswers[questionId] = value;
                    });
                  },
                ),
                if (_showAnswers) ...[
                  const SizedBox(height: AppTheme.mediumSpacing),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.mediumSpacing),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.smallRadius),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: AppTheme.mediumSpacing),
                        Text(
                          'Correct Answer: ${question['answer']}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.green,
                            fontWeight: AppTheme.boldWeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
} 