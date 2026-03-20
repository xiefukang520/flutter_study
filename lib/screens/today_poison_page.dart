import 'package:flutter/material.dart';

import '../models/hitokoto_quote.dart';
import '../services/hitokoto_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';

class TodayPoisonPage extends StatefulWidget {
  const TodayPoisonPage({super.key});

  @override
  State<TodayPoisonPage> createState() => _TodayPoisonPageState();
}

class _TodayPoisonPageState extends State<TodayPoisonPage> {
  final HitokotoService _service = HitokotoService();
  Future<HitokotoQuote>? _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchRandomFromAll();
  }

  Future<HitokotoQuote> get _safeFuture =>
      _future ??= _service.fetchRandomFromAll();

  void _reload() {
    setState(() {
      _future = _service.fetchRandomFromAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GradientBackground(
      accent: AppColors.poison,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今日毒鸡汤',
                style: textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _todayLabel(),
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.poison.withValues(alpha: 0.85),
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 5,
                child: FutureBuilder<HitokotoQuote>(
                  future: _safeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return _ErrorCard(onRetry: _reload);
                    }
                    return _TodayQuoteCard(data: snapshot.data!);
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: _reload,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.surfaceElevated,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: const Text('再来一句'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _todayLabel() {
    final n = DateTime.now();
    final w = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${n.year} · ${n.month.toString().padLeft(2, '0')} · ${n.day.toString().padLeft(2, '0')}  ${w[n.weekday - 1]}';
  }
}

class _TodayQuoteCard extends StatelessWidget {
  const _TodayQuoteCard({required this.data});

  final HitokotoQuote data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final created = data.createdDateTime;
    final createdText = created == null
        ? '未知时间'
        : '${created.year}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')}';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.format_quote_rounded,
                  size: 36,
                  color: AppColors.poison.withValues(alpha: 0.55),
                ),
                const SizedBox(height: 14),
                Text(
                  data.hitokoto,
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: 19,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _MetaChip(label: data.typeLabel),
                    _MetaChip(label: '字数 ${data.length}'),
                    _MetaChip(label: createdText),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  '出自：${data.from}${data.fromWho == null || data.fromWho!.isEmpty ? '' : ' · ${data.fromWho}'}',
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.poison.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.poison.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              const Text('加载失败，请检查网络后重试'),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ),
        ),
      ),
    );
  }
}
