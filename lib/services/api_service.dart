import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_note_taking_app/config/api_config.dart';
import 'package:ai_note_taking_app/models/note.dart';
import 'package:ai_note_taking_app/providers/auth_provider.dart';

class ApiService {
  static final _client = http.Client();
  static final String baseUrl = ApiConfig.baseUrl;
  static final AuthProvider _authProvider = AuthProvider();

  static void _printApiInfo(String endpoint) {
    print('\n=== API Call Information ===');
    print('Full URL: $baseUrl$endpoint');
    print('Base URL: $baseUrl');
    print('Endpoint: $endpoint');
    print('===========================\n');
  }

  static Future<String?> _getValidToken() async {
    try {
      final token = await _authProvider.getValidToken();
      if (token == null) {
        print('No valid token available');
        return null;
      }
      return token;
    } catch (e) {
      print('Error getting valid token: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Token expired or invalid
      await _authProvider.logout();
      throw Exception('Session expired. Please login again.');
    }
    
    try {
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['detail'] ?? 'An error occurred');
      }
    } catch (e) {
      print('Error handling response: $e');
      throw Exception('Failed to process server response');
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String password) async {
    _printApiInfo(ApiConfig.loginEndpoint);
    print('Making login API call to: $baseUrl${ApiConfig.loginEndpoint}');
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      print('Login API response status: ${response.statusCode}');
      print('Login API response body: ${response.body}');
      
      return await _handleResponse(response);
    } catch (e) {
      print('Login API error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(String username, String password, String email) async {
    _printApiInfo(ApiConfig.registerEndpoint);
    print('Making register API call to: $baseUrl${ApiConfig.registerEndpoint}');
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl${ApiConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );
      print('Register API response status: ${response.statusCode}');
      print('Register API response body: ${response.body}');
      
      return await _handleResponse(response);
    } catch (e) {
      print('Register API error: $e');
      rethrow;
    }
  }

  // Note endpoints
  static Future<List<Note>> getNotes() async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      print('\n=== Getting Notes ===');
      print('Using token: ${token.substring(0, 20)}...');
      
      final response = await _client.get(
        Uri.parse('$baseUrl${ApiConfig.notesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // First try to parse the response as a Map
          final Map<String, dynamic> data = json.decode(response.body);
          print('Parsed data: $data');
          
          // Check if the response has the expected structure
          if (data.containsKey('notes') && data['notes'] is List) {
            final List<dynamic> notesList = data['notes'];
            print('Found ${notesList.length} notes');
            
            final notes = notesList.map((json) {
              try {
                print('Processing note: $json');
                return Note.fromJson(json);
              } catch (e) {
                print('Error processing note: $e');
                return null;
              }
            }).where((note) => note != null).cast<Note>().toList();
            
            print('Successfully processed ${notes.length} notes');
            return notes;
          } else {
            print('Invalid response structure. Expected "notes" key with List value');
            print('Actual data: $data');
            return [];
          }
        } catch (e) {
          print('Error parsing notes response as Map: $e');
          // If parsing fails, try to parse as a direct list
          try {
            final List<dynamic> notesList = json.decode(response.body);
            print('Parsed as direct list with ${notesList.length} items');
            
            final notes = notesList.map((json) {
              try {
                print('Processing note: $json');
                return Note.fromJson(json);
              } catch (e) {
                print('Error processing note: $e');
                return null;
              }
            }).where((note) => note != null).cast<Note>().toList();
            
            print('Successfully processed ${notes.length} notes');
            return notes;
          } catch (e2) {
            print('Error parsing notes as list: $e2');
            return [];
          }
        }
      } else {
        print('Failed to get notes. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error in getNotes: $e');
      return [];
    }
  }

  static Future<Note> getNote(int id) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl${ApiConfig.notesEndpoint}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = await _handleResponse(response);
      return Note.fromJson(data);
    } catch (e) {
      print('Error getting note: $e');
      rethrow;
    }
  }

  static Future<Note> createNote(
    String title,
    String content,
    String summary,
    String quiz,
    Map<String, dynamic>? mindmap,
  ) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      print('Creating note with title: $title');
      print('Mindmap data: $mindmap');
      
      final response = await _client.post(
        Uri.parse('$baseUrl${ApiConfig.notesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'content': content,
          'summary': summary,
          'quiz': quiz,
          'mindmap': mindmap != null ? jsonEncode(mindmap) : null,
          'is_markdown': false,
        }),
      );

      print('Create note response status: ${response.statusCode}');
      print('Create note response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = await _handleResponse(response);
        // Create a complete note object with default values for missing fields
        return Note(
          id: data['id'],
          title: title,
          content: content,
          summary: summary,
          quiz: quiz,
          mindmap: mindmap,
          isMarkdown: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      throw Exception('Failed to create note: ${response.statusCode}');
    } catch (e) {
      print('Create note error: $e');
      rethrow;
    }
  }

  static Future<Note> updateNote(Note note) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      print('Updating note with ID: ${note.id}');
      print('Mindmap data: ${note.mindmap}');
      
      final response = await _client.put(
        Uri.parse('$baseUrl${ApiConfig.notesEndpoint}/${note.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': note.title,
          'content': note.content,
          'summary': note.summary,
          'quiz': note.quiz,
          'mindmap': note.mindmap != null ? jsonEncode(note.mindmap) : null,
          'is_markdown': note.isMarkdown,
        }),
      );

      print('Update note response status: ${response.statusCode}');
      print('Update note response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = await _handleResponse(response);
        return Note.fromJson(data);
      }
      throw Exception('Failed to update note: ${response.statusCode}');
    } catch (e) {
      print('Update note error: $e');
      rethrow;
    }
  }

  static Future<void> deleteNote(int id) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      print('Attempting to delete note with ID: $id');
      final response = await _client.delete(
        Uri.parse('$baseUrl${ApiConfig.notesEndpoint}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete note response status: ${response.statusCode}');
      print('Delete note response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        final data = await _handleResponse(response);
        throw Exception(data['detail'] ?? 'Failed to delete note');
      }
    } catch (e) {
      print('Delete note error: $e');
      rethrow;
    }
  }

  // AI feature endpoints
  static Future<String> generateSummary(String content) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse('$baseUrl/api/summarize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['summary'];
    } else {
      throw Exception('Failed to generate summary');
    }
  }

  static Future<Map<String, dynamic>> generateQuiz(String content) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/generate-quiz'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': content}),
      );

      print('Quiz API Response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final responseData = await _handleResponse(response);
        print('Parsed Quiz Data: $responseData'); // Debug print

        // Create default quiz structure
        Map<String, dynamic> quizData = {
          'mcq': [],
          'true_false': [],
          'fill_blank': []
        };

        // If the response contains quiz data, use it
        if (responseData.containsKey('quiz')) {
          final apiQuiz = responseData['quiz'];
          if (apiQuiz is Map<String, dynamic>) {
            // Format the quiz data properly
            if (apiQuiz.containsKey('mcq')) {
              quizData['mcq'] = (apiQuiz['mcq'] as List).map((q) {
                if (q is Map<String, dynamic>) {
                  // Format MCQ question properly
                  String question = q['question']?.toString() ?? 'Question';
                  List<String> options = [];
                  
                  // Handle options in different formats
                  if (q['options'] is List) {
                    options = (q['options'] as List).map((o) => o.toString()).toList();
                  } else if (q['options'] is String) {
                    // If options is a string, try to parse it
                    try {
                      final parsedOptions = json.decode(q['options'] as String);
                      if (parsedOptions is List) {
                        options = parsedOptions.map((o) => o.toString()).toList();
                      }
                    } catch (e) {
                      print('Error parsing options string: $e');
                    }
                  }

                  // Ensure we have exactly 4 options
                  while (options.length < 4) {
                    options.add('Option ${options.length + 1}');
                  }
                  if (options.length > 4) {
                    options = options.sublist(0, 4);
                  }

                  return {
                    'question': question,
                    'options': options,
                    'answer': q['answer']?.toString() ?? options[0]
                  };
                }
                return {
                  'question': 'Question',
                  'options': ['Option A', 'Option B', 'Option C', 'Option D'],
                  'answer': 'Option A'
                };
              }).toList();
            }
            
            if (apiQuiz.containsKey('true_false')) {
              quizData['true_false'] = (apiQuiz['true_false'] as List).map((q) {
                if (q is Map<String, dynamic>) {
                  return {
                    'question': q['question'] ?? 'Question',
                    'answer': q['answer']?.toString().toLowerCase() ?? 'true'
                  };
                }
                return {
                  'question': 'Question',
                  'answer': 'true'
                };
              }).toList();
            }
            
            if (apiQuiz.containsKey('fill_blank')) {
              quizData['fill_blank'] = (apiQuiz['fill_blank'] as List).map((q) {
                if (q is Map<String, dynamic>) {
                  return {
                    'question': q['question'] ?? 'Question',
                    'answer': q['answer'] ?? 'Answer'
                  };
                }
                return {
                  'question': 'Question',
                  'answer': 'Answer'
                };
              }).toList();
            }
          } else if (apiQuiz is String) {
            try {
              final parsedQuiz = json.decode(apiQuiz);
              if (parsedQuiz is Map<String, dynamic>) {
                quizData = parsedQuiz;
              }
            } catch (e) {
              print('Error parsing quiz string: $e');
            }
          }
        }

        // Only add default questions if the API didn't provide any
        if ((quizData['mcq'] as List).isEmpty) {
          quizData['mcq'] = List.generate(3, (index) => {
            'question': 'Multiple Choice Question ${index + 1}',
            'options': ['Option A', 'Option B', 'Option C', 'Option D'],
            'answer': 'Option A'
          });
        }
        if ((quizData['true_false'] as List).isEmpty) {
          quizData['true_false'] = List.generate(3, (index) => {
            'question': 'True/False Question ${index + 1}',
            'answer': 'true'
          });
        }
        if ((quizData['fill_blank'] as List).isEmpty) {
          quizData['fill_blank'] = List.generate(3, (index) => {
            'question': 'Fill in the blank Question ${index + 1}',
            'answer': 'Sample Answer'
          });
        }

        print('Final Quiz Data: $quizData'); // Debug print
        return quizData;
      }
      throw Exception('Failed to generate quiz: ${response.statusCode}');
    } catch (e) {
      print('Error generating quiz: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> generateMindmap(String content) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/mindmap'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': content}),
      );

      print('Mindmap API response status: ${response.statusCode}');
      print('Mindmap API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = await _handleResponse(response);
        final mindmapData = data['mindmap'];
        
        // Create a properly structured mindmap
        final Map<String, dynamic> structuredMindmap = {
          'central_topic': mindmapData['central'] ?? mindmapData['central_topic'] ?? 'Main Topic',
          'branches': (mindmapData['branches'] as List? ?? []).map((branch) {
            if (branch is Map<String, dynamic>) {
              return {
                'topic': branch['topic'] ?? 'Branch',
                'subtopics': (branch['subtopics'] as List? ?? []).map((subtopic) {
                  if (subtopic is String) {
                    return {'text': subtopic, 'details': []};
                  } else if (subtopic is Map<String, dynamic>) {
                    return {
                      'text': subtopic['text'] ?? 'Subtopic',
                      'details': subtopic['details'] ?? [],
                    };
                  }
                  return {'text': 'Subtopic', 'details': []};
                }).toList(),
              };
            }
            return {
              'topic': 'Branch',
              'subtopics': [],
            };
          }).toList(),
        };
        
        print('Structured mindmap: $structuredMindmap');
        return structuredMindmap;
      }
      throw Exception('Failed to generate mindmap: ${response.statusCode}');
    } catch (e) {
      print('Error generating mindmap: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> textToSpeech(String content) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse('$baseUrl/api/text-to-speech'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to convert text to speech');
    }
  }

  // File upload endpoints
  static Future<Map<String, dynamic>> uploadPdf(List<int> fileBytes, String fileName) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/upload-pdf'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception('Failed to upload PDF');
    }
  }

  static Future<Map<String, dynamic>> processHandwriting(List<int> fileBytes, String fileName) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/handwriting'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception('Failed to process handwriting');
    }
  }

  static Future<Note> saveNote(Note note) async {
    final token = await _getValidToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl${ApiConfig.notesEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': note.title,
        'content': note.content,
        'summary': note.summary,
        'quiz': note.quiz,
        'mindmap': note.mindmap != null ? jsonEncode(note.mindmap) : null,
        'is_markdown': note.isMarkdown,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Create a complete note object with default values for missing fields
      return Note(
        id: data['id'],
        title: note.title,
        content: note.content,
        summary: note.summary,
        quiz: note.quiz,
        mindmap: note.mindmap,
        isMarkdown: note.isMarkdown,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      throw Exception('Failed to save note: ${response.body}');
    }
  }
} 