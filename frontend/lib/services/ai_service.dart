import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AiService {
  /// Centralized API configuration for Nemotron 3 Ultra.
  /// - Exposes the base URL, API Key, and Model name.
  /// - Configured to use OpenRouter.
  static const String defaultBaseUrl = 'https://openrouter.ai/api/v1';
  static const String defaultModelName = 'nvidia/llama-3.1-nemotron-70b-instruct';
  static const String defaultApiKey = ''; // Insert your OpenRouter API Key here

  final String baseUrl;
  final String apiKey;
  final String modelName;
  final Duration timeoutDuration;

  AiService({
    this.baseUrl = defaultBaseUrl,
    this.apiKey = defaultApiKey,
    this.modelName = defaultModelName,
    this.timeoutDuration = const Duration(seconds: 30),
  });

  /// Sends a request to the OpenAI-compatible chat completion endpoint.
  /// Returns the parsed text response.
  Future<String> generateResponse(
    List<Map<String, String>> messages, {
    double temperature = 0.7,
    double topP = 0.95,
    int maxTokens = 4096,
  }) async {
    final uri = Uri.parse('$baseUrl/chat/completions');
    
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = {
      'model': modelName,
      'messages': messages,
      'temperature': temperature,
      'top_p': topP,
      'max_tokens': maxTokens,
    };

    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('choices')) {
          final choices = data['choices'] as List;
          if (choices.isNotEmpty) {
            final firstChoice = choices[0];
            if (firstChoice is Map && firstChoice.containsKey('message')) {
              final message = firstChoice['message'];
              if (message is Map && message.containsKey('content')) {
                return message['content'].toString();
              }
            }
          }
        }
        throw Exception('Invalid JSON response format: ${response.body}');
      } else {
        throw Exception('AI Request failed with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print("AiService generateResponse Error: $e");
      rethrow;
    }
  }

  /// Helper method for simple single-turn prompt generation.
  Future<String> generateSimplePrompt(String prompt) async {
    return await generateResponse([
      {'role': 'user', 'content': prompt}
    ]);
  }
}

/// Riverpod provider for AiService.
final aiServiceProvider = Provider<AiService>((ref) {
  // Retrieve custom configuration if needed or use defaults.
  return AiService();
});
