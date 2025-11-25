import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/providers/locale_provider.dart'; // 刚刚写的 Provider
import 'l10n/app_localizations.dart';


// 引入刚刚写的页面
import 'features/decision/presentation/decision_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(
    const ProviderScope(
      child: FlipMomentApp(),
    ),
  );
}

class FlipMomentApp extends ConsumerWidget {
  const FlipMomentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听语言变化
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flip Moment', // 这里只能写死，或者不写

      // --- 🌍 国际化配置核心 ---
      locale: locale, // 当前语言
      localizationsDelegates: const [
        AppLocalizations.delegate, // 我们生成的
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('zh'), // Chinese
      ],
      // -----------------------

      home: const DecisionScreen(),
    );
  }
}