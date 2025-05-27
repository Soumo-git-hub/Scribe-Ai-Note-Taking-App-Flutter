import 'package:flutter/material.dart';
import 'package:ai_note_taking_app/models/note.dart';
import 'package:ai_note_taking_app/services/api_service.dart';

class NoteProvider with ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final notes = await ApiService.getNotes();
      _notes = notes;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _notes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Note> createNote(
    String title,
    String content, {
    String summary = '',
    String quiz = '',
    Map<String, dynamic>? mindmap,
  }) async {
    try {
      final createdNote = await ApiService.createNote(
        title,
        content,
        summary,
        quiz,
        mindmap,
      );
      _notes.add(createdNote);
      notifyListeners();
      return createdNote;
    } catch (e) {
      print('Error creating note: $e');
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final updatedNote = await ApiService.updateNote(note);
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updatedNote;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting to delete note with ID: $id');
      await ApiService.deleteNote(id);
      print('Successfully deleted note with ID: $id');
      _notes.removeWhere((note) => note.id == id);
      _error = null;
    } catch (e) {
      print('Error deleting note: $e');
      _error = e.toString();
      // Only reload notes if there was an error
      print('Reloading notes after delete error');
      await loadNotes();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 