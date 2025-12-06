import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';

import 'features/decision/presentation/decision_screen.dart';
import 'features/decision/data/decision_model.dart';
import 'features/settings/data/user_model.dart';
import 'features/splash/presentation/splash_screen.dart';

import 'package:umeng_common_sdk/umeng_common_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🚀 [画质优先] 内存扩容 Plus
  // 900px * 900px * 4 bytes ≈ 3MB 一张图
  // 80 张图 ≈ 240MB。
  // 我们给 400MB 缓存空间，确保绝不发生"边播边清理"导致的卡顿。
  PaintingBinding.instance.imageCache.maximumSize = 200; 
  PaintingBinding.instance.imageCache.maximumSizeBytes = 400 * 1024 * 1024; // 400MB
  
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

  // 🔥 预加载 Google Fonts（复古主题及其他主题使用的常用字体）
  // 消除首次渲染时的文字闪烁（FOUT）
  await Future.wait([
    GoogleFonts.pendingFonts([
      GoogleFonts.playfairDisplay(),  // Vintage 显示字体
      GoogleFonts.lato(),             // Vintage 正文字体
      GoogleFonts.courierPrime(),     // Vintage 等宽字体
      GoogleFonts.oswald(),           // Vintage 标签字体
      GoogleFonts.blackOpsOne(),      // Vintage 印章字体
      GoogleFonts.maShanZheng(),      // Healing 中文手写体
      GoogleFonts.zcoolKuaiLe(),      // Healing 快乐体
      GoogleFonts.fredoka(),          // Healing 圆体
    ]),
  ]);

  WidgetsFlutterBinding.ensureInitialized();

  // 禁用详细日志
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null &&
        !message.contains('Adreno') &&
        !message.contains('AttachmentInPersistentGmem')) {
      print(message);
    }
  };

  UmengCommonSdk.initCommon('692822638560e34872f53c3d', '', 'Umeng');
  UmengCommonSdk.setPageCollectionModeManual();

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