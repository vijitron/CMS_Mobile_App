import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vector_store.dart';

class EnhancedGroqHandler {
  final VectorStore vectorStore;
  final String? flaskApiUrl;
  final String? apiKey;

  EnhancedGroqHandler({
    required this.vectorStore,
    this.flaskApiUrl,
    this.apiKey,
  });

  Future<String> getResponse(String userQuery) async {
    print('🤖 Processing: "$userQuery"');

    // FIRST: Try fuzzy match from your JSON data
    final exactMatch = vectorStore.findBestMatch(
      userQuery,
      threshold: 0.3,
    ); // Lower threshold

    if (exactMatch != null) {
      print('✅ Found exact match in JSON');
      return exactMatch['answer'];
    }

    // DEBUG: See what similar questions were found
    final similar = vectorStore.findSimilarQuestions(userQuery);
    print('🔍 Similar questions found:');
    for (var item in similar) {
      print(
        '   - "${item['question']}" (score: ${item['score'].toStringAsFixed(2)})',
      );
    }

    // SECOND: Use Flask for general questions
    if (flaskApiUrl != null) {
      try {
        print('🔄 Trying Flask API...');
        final response = await http
            .post(
              Uri.parse(flaskApiUrl!),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'user_id': 'user_${DateTime.now().millisecondsSinceEpoch}',
                'message': userQuery,
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            print('✅ Flask response successful');
            return data['reply'];
          }
        }
      } catch (e) {
        print('❌ Flask API error: $e');
      }
    }

    // FINAL FALLBACK
    return "🌟 MAXIM Assistant\n\nI specialize in CraneIQ operations! Try asking about:\n• Load monitoring\n• Vibration analysis\n• Temperature tracking\n• Brake systems\n• Energy monitoring\n\nOr be more specific with your question!";
  }
}
