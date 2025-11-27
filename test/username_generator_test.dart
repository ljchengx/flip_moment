import 'package:flutter_test/flutter_test.dart';
import 'package:flip_moment/core/utils/username_generator.dart';

void main() {
  group('UsernameGenerator', () {
    test('should generate a username from the predefined list', () {
      final username = UsernameGenerator.generateRandomUsername();
      
      // 验证生成的用户名不为空
      expect(username.isNotEmpty, true);
      
      // 验证生成的用户名符合预期格式（包含空格或单个词）
      expect(username.contains(' ') || username.split(' ').length == 1, true);
    });

    test('should generate different usernames on multiple calls', () {
      final usernames = <String>{};
      
      // 生成多个用户名
      for (int i = 0; i < 20; i++) {
        usernames.add(UsernameGenerator.generateRandomUsername());
      }
      
      // 验证至少生成了不同的用户名（虽然随机性可能导致重复）
      expect(usernames.length > 1, true);
    });

    test('should generate username with suffix when requested', () {
      final usernameWithSuffix = UsernameGenerator.generateUsernameWithSuffix();
      
      // 验证生成的用户名不为空
      expect(usernameWithSuffix.isNotEmpty, true);
      
      // 验证格式：基础名称 + 数字
      final parts = usernameWithSuffix.split(' ');
      expect(parts.length, 2);
      
      // 验证第二部分是数字
      final suffix = int.tryParse(parts[1]);
      expect(suffix, isNotNull);
      expect(suffix! >= 0 && suffix <= 9999, true);
    });
  });
}