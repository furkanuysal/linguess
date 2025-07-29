import 'dart:math';
import 'package:flutter/material.dart';
import 'package:linguess/l10n/generated/app_localizations.dart';
import 'package:linguess/l10n/generated/app_localizations_extensions.dart';
import 'package:linguess/providers/economy_provider.dart';
import 'package:linguess/providers/user_data_provider.dart';
import '../models/word_model.dart';
import '../repositories/word_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WordGamePage extends ConsumerStatefulWidget {
  final String mode; // 'category' or 'level'
  final String selectedValue; // category ID or level ID

  const WordGamePage({
    super.key,
    required this.selectedValue,
    required this.mode,
  });

  @override
  ConsumerState<WordGamePage> createState() => _WordGamePageState();
}

class _WordGamePageState extends ConsumerState<WordGamePage>
    with SingleTickerProviderStateMixin {
  late Future<List<WordModel>> _wordsFuture;
  List<WordModel> _words = [];

  WordModel? _currentWord; // Var to hold the current word

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
        _loadRandomWord(); // Load the first word randomly
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

  // This function will select a random word and assign it to _currentWord
  Future<void> _loadRandomWord() async {
    if (_words.isNotEmpty) {
      _words.shuffle(); // Shuffle the list to randomize the order
      setState(() {
        _currentWord = _words.first; // Take the first word after shuffling
        _initializeWord(); // Use the new word for initialization
      });
    }
  }

  void _initializeWord() {
    if (_currentWord != null) {
      _currentTarget = (_currentWord!.translations['en'] ?? '').toUpperCase();

      for (var c in _controllers) {
        c.dispose();
      }
      for (var f in _focusNodes) {
        f.dispose();
      }

      // Remove spaces from the target word
      final filteredTarget = _currentTarget.replaceAll(' ', '');

      _controllers = List.generate(
        filteredTarget.length,
        (_) => TextEditingController(),
      );
      _focusNodes = List.generate(filteredTarget.length, (_) => FocusNode());
      _hintIndices.clear();
      _correctIndices = List.generate(filteredTarget.length, (_) => false);
    }
  }

  int _logicalIndexFromVisual(int visualIndex) {
    int count = 0;
    for (int i = 0; i <= visualIndex; i++) {
      if (_currentTarget[i] != ' ') count++;
    }
    return count - 1;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  void _showSuccessDialog() async {
    final economyService = ref.read(economyServiceProvider);
    await economyService.rewardGold(_hintIndices.length);

    final locale = Localizations.localeOf(context).languageCode;
    final correctAnswerFormatted = _capitalize(_currentTarget);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 ${AppLocalizations.of(context)!.correctText}!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppLocalizations.of(context)!.yourWord}: ${_currentWord!.translations[locale] ?? '???'}',
            ),
            Text(
              '${AppLocalizations.of(context)!.correctAnswer}: $correctAnswerFormatted',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadRandomWord();
            },
            child: Text(AppLocalizations.of(context)!.nextWord),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAnswer() async {
    bool isAllCorrect = true;
    int controllerIndex = 0;
    final userService = ref.read(userServiceProvider);

    setState(() {
      for (int i = 0; i < _currentTarget.length; i++) {
        final targetChar = _currentTarget[i];

        // if the character is a space, skip it
        if (targetChar == ' ') {
          _correctIndices[i] =
              true; // spaces are automatically considered correct
          continue;
        }

        // Now controllerIndex is only incremented for letters
        final input = _controllers[controllerIndex].text.toUpperCase();
        if (input == targetChar) {
          _correctIndices[controllerIndex] = true;
        } else {
          _correctIndices[controllerIndex] = false;
          isAllCorrect = false;
          _controllers[controllerIndex].clear();
        }

        controllerIndex++;
      }
    });

    if (isAllCorrect) {
      await userService.handleCorrectAnswer(_currentTarget);
      _showSuccessDialog();
    } else {
      _shakeController.forward(from: 0);

      controllerIndex = 0;
      for (int i = 0; i < _currentTarget.length; i++) {
        if (_currentTarget[i] == ' ') continue;
        if (_controllers[controllerIndex].text.isEmpty && !_correctIndices[i]) {
          FocusScope.of(context).requestFocus(_focusNodes[controllerIndex]);
          break;
        }
        controllerIndex++;
      }
    }
  }

  void _showHintLetter() async {
    if (_hintIndices.length >= _currentTarget.length) return;

    final economyService = ref.read(economyServiceProvider);

    final canUseHint = await economyService.tryUseHint();
    if (!canUseHint) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Yetersiz altın!")));
      }
      return;
    }

    final remainingIndices = List.generate(
      _currentTarget.length,
      (i) => i,
    ).where((i) => !_hintIndices.contains(i) && !_correctIndices[i]).toList();

    if (remainingIndices.isNotEmpty) {
      final rand = Random();
      final index = remainingIndices[rand.nextInt(remainingIndices.length)];
      setState(() {
        _controllers[index].text = _currentTarget[index];
        _hintIndices.add(index);
        _correctIndices[index] = true;
      });

      final allFilled = List.generate(
        _currentTarget.length,
        (i) => _controllers[i].text.isNotEmpty || _correctIndices[i],
      ).every((filled) => filled);

      if (allFilled) {
        _checkAnswer();
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
      _controllers.length,
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
          final screenWidth = MediaQuery.of(context).size.width;
          final boxSpacing = 8.0;
          final horizontalPadding = 32.0; // total (16 left + 16 right)
          final maxBoxWidth = 40.0;

          // Kutuların sığabileceği maksimum genişliği hesapla
          double totalSpacing = (_currentTarget.length - 1) * boxSpacing;
          double availableWidth =
              screenWidth - horizontalPadding - totalSpacing;

          // Kutuların genişliği, 40'tan küçükse küçült
          double boxWidth = availableWidth / _currentTarget.length;
          if (boxWidth > maxBoxWidth) boxWidth = maxBoxWidth;

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
                            spacing: boxSpacing,
                            children: List.generate(_currentTarget.length, (
                              index,
                            ) {
                              if (_currentTarget[index] == ' ') {
                                // Boşluk için sadece bir genişlik bırakıyoruz
                                return SizedBox(width: boxWidth / 2);
                              } else {
                                final logicalIndex = _logicalIndexFromVisual(
                                  index,
                                );
                                return SizedBox(
                                  width: boxWidth,
                                  child: TextField(
                                    controller: _controllers[logicalIndex],
                                    focusNode: _focusNodes[logicalIndex],
                                    enabled: !_correctIndices[logicalIndex],
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    onChanged: (val) =>
                                        _onTextChanged(logicalIndex, val),
                                    decoration: const InputDecoration(
                                      counterText: '',
                                    ),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: _correctIndices[logicalIndex]
                                          ? Colors.green
                                          : Colors.black,
                                    ),
                                  ),
                                );
                              }
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
