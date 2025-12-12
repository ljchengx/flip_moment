import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/countdown_phrases.dart';
import '../../data/ritual_theme_config.dart';

/// Wisdom quote widget with timer-based rotation
class WisdomQuoteWidget extends StatefulWidget {
  final RitualThemeConfig config;

  static const Duration rotationInterval = Duration(seconds: 18);
  static const Duration fadeTransitionDuration = Duration(milliseconds: 600);

  const WisdomQuoteWidget({
    super.key,
    required this.config,
  });

  @override
  State<WisdomQuoteWidget> createState() => _WisdomQuoteWidgetState();
}

class _WisdomQuoteWidgetState extends State<WisdomQuoteWidget> {
  int _currentQuoteIndex = 0;
  Timer? _rotationTimer;
  late List<String> _quotes;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    _quotes = CountdownPhrases.getWisdomQuotes(loc);
  }

  void _startRotation() {
    _rotationTimer = Timer.periodic(WisdomQuoteWidget.rotationInterval, (_) {
      if (mounted) {
        setState(() {
          _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: AnimatedSwitcher(
        duration: WisdomQuoteWidget.fadeTransitionDuration,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Text(
          _quotes[_currentQuoteIndex],
          key: ValueKey(_currentQuoteIndex),
          style: widget.config.quoteTextStyle,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
