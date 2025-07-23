import 'dart:math';
import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
import '../models/word_model.dart';
import '../repositories/word_repository.dart';

class WordGamePage extends StatefulWidget {
  final String mode; // 'category' or 'level'
  final String selectedValue; // category ID or level ID

  const WordGamePage({
    super.key,
    required this.selectedValue,
    required this.mode,
  });

  @override
  State<WordGamePage> createState() => _WordGamePageState();
}

class _WordGamePageState extends State<WordGamePage>
    with SingleTickerProviderStateMixin {
  late Future<List<WordModel>> _wordsFuture;
  List<WordModel> _words = [];
  // _currentWordIndex yerine doğrudan _currentWord'ü tutacağız.
  WordModel? _currentWord; // Rastgele seçilen kelimeyi tutacak değişken

  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  final List<int> _hintIndices = [];
  List<bool> _correctIndices = [];

  final GlobalKey _wrapKey = GlobalKey();

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  String _currentTarget = '';

  @override
  void initState() {
    super.initState();

    if (widget.mode == 'category') {
      _wordsFuture = WordRepository().fetchWordsByCategory(
        widget.selectedValue,
      );
    } else {
      _wordsFuture = WordRepository().fetchWordsByLevel(widget.selectedValue);
    }
    _wordsFuture.then((words) {
      setState(() {
        _words = words;
        _loadRandomWord(); // İlk kelimeyi rastgele yükle
      });
    });

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_wrapKey.currentContext != null) {
            Scrollable.ensureVisible(
              _wrapKey.currentContext!,
              duration: const Duration(milliseconds: 300),
              alignment: 0.5,
            );
          }
        });
      }
    });

    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  // Bu fonksiyon rastgele bir kelime seçip _currentWord'e atayacak
  Future<void> _loadRandomWord() async {
    if (_words.isNotEmpty) {
      _words.shuffle(); // Tüm listeyi karıştır
      setState(() {
        _currentWord = _words.first; // Karıştırılmış listeden ilk kelimeyi al
        _initializeWord(); // Yeni kelimeyi başlangıç için ayarla
      });
    }
  }

  void _initializeWord() {
    // _currentWord null değilse işlemi yap
    if (_currentWord != null) {
      _currentTarget = (_currentWord!.translations['en'] ?? '').toUpperCase();

      // Eski controller ve focusNode'ları dispose et
      for (var c in _controllers) {
        c.dispose();
      }
      for (var f in _focusNodes) {
        f.dispose();
      }

      _controllers = List.generate(
        _currentTarget.length,
        (_) => TextEditingController(),
      );
      _focusNodes = List.generate(_currentTarget.length, (_) => FocusNode());
      _hintIndices.clear();
      _correctIndices = List.generate(_currentTarget.length, (_) => false);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  void _showSuccessDialog() {
    final locale = Localizations.localeOf(context).languageCode;
    final correctAnswerFormatted = _capitalize(_currentTarget);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Doğru!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // _currentWord'ün anlamını göster
              '${AppLocalizations.of(context)!.yourWord}: ${_currentWord!.translations[locale] ?? '???'}',
            ),
            Text('Doğru Cevap: $correctAnswerFormatted'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Bir sonraki kelime için rastgele yükleme yap
              _loadRandomWord();
            },
            child: const Text('Devam'),
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    bool isAllCorrect = true;
    setState(() {
      for (int i = 0; i < _currentTarget.length; i++) {
        final input = _controllers[i].text.toUpperCase();
        if (input == _currentTarget[i]) {
          _correctIndices[i] = true;
        } else {
          _correctIndices[i] = false;
          isAllCorrect = false;
          _controllers[i].clear();
        }
      }
    });

    if (isAllCorrect) {
      _showSuccessDialog();
    } else {
      _shakeController.forward(from: 0);
      // İlk boş kutuya focus atla
      for (int i = 0; i < _controllers.length; i++) {
        if (_controllers[i].text.isEmpty && !_correctIndices[i]) {
          FocusScope.of(context).requestFocus(_focusNodes[i]);
          break;
        }
      }
    }
  }

  void _showHintLetter() {
    // Zaten tüm kutular ipucu ile doluysa veya doldurulacaksa bir şey yapma
    if (_hintIndices.length >= _currentTarget.length) return;

    final remainingIndices = List.generate(_currentTarget.length, (i) => i)
        .where((i) => !_hintIndices.contains(i) && !_correctIndices[i])
        .toList(); // Doğru tahmin edilenleri de dikkate al

    if (remainingIndices.isNotEmpty) {
      final rand = Random();
      final index = remainingIndices[rand.nextInt(remainingIndices.length)];
      setState(() {
        _controllers[index].text =
            _currentTarget[index]; // İpucu verilen harfi ata
        _hintIndices.add(index);
        _correctIndices[index] = true; // Bu harf doğru olarak işaretlendi
      });

      // İpucu verildikten sonra tüm kutuların dolup dolmadığını kontrol et
      final allFilled = List.generate(
        _currentTarget.length,
        (i) => _controllers[i].text.isNotEmpty || _correctIndices[i],
      ).every((filled) => filled);

      if (allFilled) {
        _checkAnswer(); // Tüm kutular dolduysa cevabı kontrol et
      }
    }
  }

  void _onTextChanged(int index, String value) {
    if (value.isNotEmpty) {
      final upper = value.toUpperCase();
      if (_controllers[index].text != upper) {
        _controllers[index].text = upper;
        _controllers[index].selection = TextSelection.fromPosition(
          TextPosition(offset: upper.length),
        );
      }

      // Sonraki boş kutuya focus atla
      for (int i = index + 1; i < _controllers.length; i++) {
        if (_controllers[i].text.isEmpty && !_correctIndices[i]) {
          FocusScope.of(context).requestFocus(_focusNodes[i]);
          break;
        }
      }
    }

    final allFilled = List.generate(
      _currentTarget.length,
      (i) => _controllers[i].text.isNotEmpty || _correctIndices[i],
    ).every((filled) => filled);

    if (allFilled) {
      _checkAnswer();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.categoryTitle(widget.selectedValue),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _hintIndices.length >= _currentTarget.length
                ? null
                : _showHintLetter,
            tooltip: AppLocalizations.of(context)!.letterHint,
          ),
        ],
      ),
      body: FutureBuilder<List<WordModel>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || _currentWord == null) {
            // Eğer veri henüz yüklenmediyse veya ilk kelime atanmadıysa yükleme göster
            return const Center(child: CircularProgressIndicator());
          }

          // _currentWord'ün hint'ini kullan
          final hint = _currentWord!.translations['tr'] ?? '???';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.yourWord}: $hint',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: AnimatedBuilder(
                      animation: _shakeController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _shakeAnimation.value *
                                sin(
                                  2 *
                                      pi *
                                      DateTime.now().millisecondsSinceEpoch /
                                      100,
                                ),
                            0,
                          ),
                          child: Wrap(
                            key: _wrapKey,
                            spacing: 8,
                            children: List.generate(_currentTarget.length, (
                              index,
                            ) {
                              return SizedBox(
                                width: 40,
                                child: TextField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  enabled: !_correctIndices[index],
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  onChanged: (val) =>
                                      _onTextChanged(index, val),
                                  decoration: const InputDecoration(
                                    counterText: '',
                                  ),
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: _correctIndices[index]
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
