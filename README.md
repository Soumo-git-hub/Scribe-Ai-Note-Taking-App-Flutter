# AI Note Taking App

A Flutter application that combines note-taking with AI-powered features to enhance productivity and learning.

## Features

- 📝 Create, edit, and delete notes
- 🤖 AI-powered features:
  - Text summarization
  - Quiz generation
  - Mind map creation
  - Text-to-speech conversion
- 🌓 Light and dark theme support
- 🔐 User authentication
- 📱 Responsive design for web and mobile

## Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Node.js and npm (for backend)
- Python 3.8+ (for AI features)

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ai-note-taking-app.git
   cd ai-note-taking-app
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Set up the backend:
   ```bash
   cd backend
   npm install
   ```

4. Create a `.env` file in the root directory:
   ```
   API_URL=http://localhost:8000
   ```

5. Start the backend server:
   ```bash
   cd backend
   npm start
   ```

6. Run the Flutter app:
   ```bash
   flutter run -d chrome  # For web
   # or
   flutter run  # For mobile
   ```

## Project Structure

```
lib/
├── config/         # Configuration files
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # API services
├── theme/          # Theme configuration
└── widgets/        # Reusable widgets
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- OpenAI for providing the AI capabilities
- All contributors who have helped shape this project 