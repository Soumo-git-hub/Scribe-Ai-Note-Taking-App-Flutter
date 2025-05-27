import 'dart:convert';

class Note {
  final int? id;
  final String title;
  final String content;
  final String summary;
  final String quiz;
  final Map<String, dynamic>? mindmap;
  final bool isMarkdown;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.summary = '',
    this.quiz = '',
    this.mindmap,
    this.isMarkdown = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    // Handle mindmap data which could be a string or a map
    Map<String, dynamic>? mindmapData;
    if (json['mindmap'] != null) {
      if (json['mindmap'] is String) {
        try {
          final mindmapStr = json['mindmap'] as String;
          if (mindmapStr.isNotEmpty) {
            mindmapData = jsonDecode(mindmapStr);
          } else {
            mindmapData = {
              'central_topic': 'Main Topic',
              'branches': [],
            };
          }
        } catch (e) {
          print('Error parsing mindmap string: $e');
          mindmapData = {
            'central_topic': 'Main Topic',
            'branches': [],
          };
        }
      } else if (json['mindmap'] is Map) {
        mindmapData = Map<String, dynamic>.from(json['mindmap']);
      }
    }

    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      summary: json['summary'] ?? '',
      quiz: json['quiz'] ?? '',
      mindmap: mindmapData,
      isMarkdown: json['is_markdown'] == 1 || json['is_markdown'] == true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'summary': summary,
      'quiz': quiz,
      'mindmap': mindmap != null ? jsonEncode(mindmap) : null,
      'is_markdown': isMarkdown,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Note copyWith({
    int? id,
    String? title,
    String? content,
    String? summary,
    String? quiz,
    Map<String, dynamic>? mindmap,
    bool? isMarkdown,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      quiz: quiz ?? this.quiz,
      mindmap: mindmap ?? this.mindmap,
      isMarkdown: isMarkdown ?? this.isMarkdown,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 