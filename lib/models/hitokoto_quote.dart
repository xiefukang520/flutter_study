class HitokotoQuote {
  const HitokotoQuote({
    required this.id,
    required this.uuid,
    required this.hitokoto,
    required this.type,
    required this.from,
    required this.fromWho,
    required this.creator,
    required this.creatorUid,
    required this.reviewer,
    required this.commitFrom,
    required this.createdAt,
    required this.length,
  });

  final int id;
  final String uuid;
  final String hitokoto;
  final String type;
  final String from;
  final String? fromWho;
  final String creator;
  final int creatorUid;
  final int reviewer;
  final String commitFrom;
  final String createdAt;
  final int length;

  factory HitokotoQuote.fromJson(Map<String, dynamic> json) {
    return HitokotoQuote(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      hitokoto: json['hitokoto'] as String? ?? '',
      type: json['type'] as String? ?? '',
      from: json['from'] as String? ?? '未知来源',
      fromWho: json['from_who'] as String?,
      creator: json['creator'] as String? ?? '匿名',
      creatorUid: json['creator_uid'] as int? ?? 0,
      reviewer: json['reviewer'] as int? ?? 0,
      commitFrom: json['commit_from'] as String? ?? 'unknown',
      createdAt: json['created_at'] as String? ?? '0',
      length: json['length'] as int? ?? 0,
    );
  }

  DateTime? get createdDateTime {
    final sec = int.tryParse(createdAt);
    if (sec == null || sec <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(sec * 1000);
  }

  String get typeLabel {
    switch (type) {
      case 'a':
        return '动画';
      case 'b':
        return '漫画';
      case 'c':
        return '游戏';
      case 'd':
        return '文学';
      case 'e':
        return '原创';
      case 'f':
        return '网络';
      case 'g':
        return '其他';
      case 'h':
        return '影视';
      case 'i':
        return '诗词';
      case 'j':
        return '网易云';
      case 'k':
        return '哲学';
      case 'l':
        return '抖机灵';
      default:
        return '未分类';
    }
  }
}
