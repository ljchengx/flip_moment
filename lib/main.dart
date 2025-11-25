import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flip Moment',
      // 这里不需要 ThemeData 了，因为我们完全由 SkinEngine 接管
      home: DecisionScreen(),
    );
  }
}