// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/github_service.dart';
import '../services/gemini_service.dart';
import 'chat/chat_main_screen.dart';

class ChatScreen extends StatelessWidget {
  final GeminiService geminiService;
  final GitHubService githubService;

  const ChatScreen({
    super.key,
    required this.geminiService,
    required this.githubService,
  });

  @override
  Widget build(BuildContext context) {
    final Project project = ModalRoute.of(context)!.settings.arguments as Project;
    
    return ChatMainScreen(
      geminiService: geminiService,
      githubService: githubService,
      project: project,
    );
  }
}
