class ApiConfig {
  // For web, we need to use the full URL including http://
  static const String baseUrl = 'http://192.168.1.2:8000';  // Using computer's IP address
  
  // API endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String notesEndpoint = '/api/notes';
  static const String summarizeEndpoint = '/api/summarize';
  static const String quizEndpoint = '/api/generate-quiz';
  static const String mindmapEndpoint = '/api/mindmap';
  static const String textToSpeechEndpoint = '/api/text-to-speech';
  static const String uploadPdfEndpoint = '/api/upload-pdf';
  static const String handwritingEndpoint = '/api/handwriting';

  // File size limits
  static const int maxPdfSize = 20 * 1024 * 1024; // 20MB
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB

  // Allowed file types
  static const List<String> allowedImageTypes = ['.png', '.jpg', '.jpeg'];
  static const List<String> allowedPdfTypes = ['.pdf'];

  // API timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  static void printConfig() {
    print('API Configuration:');
    print('Base URL: $baseUrl');
    print('Login Endpoint: $loginEndpoint');
    print('Register Endpoint: $registerEndpoint');
    print('Full Login URL: $baseUrl$loginEndpoint');
    print('Full Register URL: $baseUrl$registerEndpoint');
  }
} 