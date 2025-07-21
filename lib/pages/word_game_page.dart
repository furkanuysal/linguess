import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
import '../models/word_model.dart';
import '../repositories/word_repository.dart';

class WordGamePage extends StatefulWidget {
  final String category;

  const WordGamePage({super.key, required this.category});

  @override
  State<WordGamePage> createState() => _WordGamePageState();
}

class _WordGamePageState extends State<WordGamePage> {
  late Future<List<WordModel>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _wordsFuture = WordRepository().fetchWordsByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.categoryTitle(widget.category),
        ),
      ),
      body: FutureBuilder<List<WordModel>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No words found.'));
          }

          final words = snapshot.data!;

          final locale = Localizations.localeOf(context).languageCode;
          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              final wordText =
                  word.translations[locale] ??
                  word.translations['en'] ??
                  'Unknown';
              return ListTile(
                title: Text(wordText),
                subtitle: Text('Level: ${word.level}'),
              );
            },
          );
        },
      ),
    );
  }
}
