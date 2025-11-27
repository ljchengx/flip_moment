import 'dart:math';

/// 用户名生成器
/// 为新用户生成符合四大主题风格的随机昵称
class UsernameGenerator {
  static const List<String> _kGuestNames = [
    // 复古风格
    "Time Traveler",      // 时间旅行者
    "Retro Soul",         // 复古灵魂
    "Vintage Dreamer",    // 复古梦想家
    "Clock Keeper",       // 守钟人
    "Memory Collector",   // 记忆收藏家
    "Old School",         // 老派玩家
    
    // 治愈风格
    "Zen Master",         // 禅意大师
    "Mochi Lover",        // 团子爱好者
    "Soul Healer",        // 灵魂治愈师
    "Peace Walker",       // 和平行者
    "Dream Weaver",       // 织梦者
    "Heart Keeper",       // 心灵守护者
    
    // 赛博风格
    "Cyber Drifter",      // 赛博漂流者
    "Void Walker",        // 虚空行者
    "Pixel Artist",       // 像素艺术家
    "Data Hunter",        // 数据猎人
    "Neon Rider",         // 霓虹骑士
    "Code Breaker",       // 代码破解者
    
    // 许愿风格
    "Lucky Star",         // 幸运星
    "Fate Weaver",        // 命运编织者
    "Wish Maker",         // 许愿者
    "Dream Catcher",      // 捕梦者
    "Star Gazer",         // 观星者
    "Hope Keeper",        // 希望守护者
    
    // 通用风格
    "Silent Observer",    // 沉默观察者
    "Night Owl",          // 夜猫子
    "Day Dreamer",        // 白日梦想家
    "Path Finder",        // 探路者
    "Story Teller",       // 故事讲述者
  ];
  
  static final Random _random = Random();
  
  /// 生成随机用户名
  static String generateRandomUsername() {
    return _kGuestNames[_random.nextInt(_kGuestNames.length)];
  }
  
  /// 生成带数字后缀的用户名（可选功能）
  static String generateUsernameWithSuffix() {
    final baseName = generateRandomUsername();
    final suffix = _random.nextInt(9999);
    return '$baseName $suffix';
  }
}