import 'package:flutter/material.dart';

import '../services/hitokoto_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';

class TrendingQuotesPage extends StatefulWidget {
  const TrendingQuotesPage({super.key});

  @override
  State<TrendingQuotesPage> createState() => _TrendingQuotesPageState();
}

class _TrendingQuotesPageState extends State<TrendingQuotesPage> {
  final HitokotoService _service = HitokotoService();
  Future<String>? _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchNetworkText();
  }

  Future<String> get _safeFuture => _future ??= _service.fetchNetworkText();

  void _reload() {
    setState(() {
      _future = _service.fetchNetworkText();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GradientBackground(
      accent: AppColors.net,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('热门网络句子', style: textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                _dateLabel(),
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.net.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<String>(
                  future: _safeFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return _ErrorCard(onRetry: _reload);
                    }
                    return _TrendingCard(text: snapshot.data!);
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

  String _dateLabel() {
    final n = DateTime.now();
    final w = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${n.year} · ${n.month.toString().padLeft(2, '0')} · ${n.day.toString().padLeft(2, '0')}  ${w[n.weekday - 1]}';
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final hhmm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
                  Icons.whatshot_rounded,
                  size: 34,
                  color: AppColors.net.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 14),
                Text(
                  text,
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
                    const _NetChip(label: '网络'),
                    _NetChip(label: '字数 ${text.runes.length}'),
                    _NetChip(label: '刷新 $hhmm'),
                  ],
                ),
                const SizedBox(height: 14),
                Text('实时短句 · 纯文本模式', style: textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NetChip extends StatelessWidget {
  const _NetChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.net.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.net.withValues(alpha: 0.35)),
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
              const Text('网络句子加载失败'),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('重试')),
            ],
          ),
        ),
      ),
    );
  }
}
