import 'package:flutter/material.dart';
import 'package:linguess/pages/word_game_page.dart';
import '../models/level_model.dart';
import '../repositories/level_repository.dart';
import '../l10n/generated/app_localizations.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  final LevelRepository _levelRepository = LevelRepository();
  List<LevelModel> _levels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _levels = await _levelRepository.fetchLevels();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _levels.length,
              itemBuilder: (context, index) {
                final level = _levels[index];
                return ListTile(
                  title: Text(level.id),
                  subtitle: Text('Index: ${level.index}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WordGamePage(selectedValue: level.id, mode: 'level'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
