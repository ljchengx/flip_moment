import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

import 'features/decision/presentation/decision_screen.dart';
import 'features/decision/data/decision_model.dart';
import 'features/settings/data/user_model.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DecisionModelAdapter());
  
  try {
    await Hive.openBox<UserModel>('user_box');
  } catch (e) {
    // 如果 user_box 有问题，尝试删除并重新创建
    await Hive.deleteBoxFromDisk('user_box');
    await Hive.openBox<UserModel>('user_box');
  }
  
  try {
    await Hive.openBox<DecisionModel>('decisions_box');
  } catch (e) {
    // 如果 decisions_box 有问题，尝试删除并重新创建
    await Hive.deleteBoxFromDisk('decisions_box');
    await Hive.openBox<DecisionModel>('decisions_box');
  }
  
  try {
    await Hive.openBox('settings_box');
  } catch (e) {
    // 如果 settings_box 有问题，尝试删除并重新创建
    await Hive.deleteBoxFromDisk('settings_box');
    await Hive.openBox('settings_box');
  }

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

      home: const SplashScreen(),
    );
  }
}