import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_background.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

enum _ProfileAction { privacy, licenses, about, clearCache }

class _ProfilePageState extends State<ProfilePage> {
  String _nickname = '匿名用户';

  void _toast(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _editNickname() async {
    final controller = TextEditingController(text: _nickname);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('修改昵称'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 12,
            decoration: const InputDecoration(
              hintText: '请输入昵称（最多 12 字）',
              counterText: '',
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (v) => Navigator.pop(context, v.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted) return;

    final next = (result ?? '').trim();
    if (next.isEmpty || next == _nickname) return;

    setState(() => _nickname = next);
    _toast('已更新昵称');
  }

  Future<void> _confirmClearCache() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清理缓存'),
          content: const Text('将清理本地缓存数据（当前版本仅做演示，不会影响功能）。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Text('清理'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (ok != true) return;

    _toast('已清理');
  }

  void _showPrivacySheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('隐私说明', style: textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(
                  '本 App 会通过网络请求获取句子内容（示例接口：Hitokoto）。\n'
                  '我们不会主动收集你的个人身份信息；昵称仅在本地展示。\n'
                  '若你在公司/校园网络下使用，请遵循相应网络策略。',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('知道了'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: '毒鸡汤',
      applicationVersion: '1.0.0+1',
      applicationIcon: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.profile.withValues(alpha: 0.18),
        child: const Icon(Icons.spa_rounded, color: AppColors.textPrimary),
      ),
      children: const [
        SizedBox(height: 12),
        Text('一个简洁的深色短句 App，包含：毒鸡汤 / 漫画句 / 网络句子。'),
      ],
    );
  }

  void _handleAction(_ProfileAction action) {
    switch (action) {
      case _ProfileAction.privacy:
        _showPrivacySheet();
        return;
      case _ProfileAction.licenses:
        showLicensePage(
          context: context,
          applicationName: '毒鸡汤',
          applicationVersion: '1.0.0+1',
        );
        return;
      case _ProfileAction.about:
        _showAbout();
        return;
      case _ProfileAction.clearCache:
        _confirmClearCache();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GradientBackground(
      accent: AppColors.profile,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('我的', style: textTheme.headlineLarge),
                            const SizedBox(height: 6),
                            Text(
                              '把清醒留在身边',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.92,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<_ProfileAction>(
                        tooltip: '更多',
                        position: PopupMenuPosition.under,
                        onSelected: _handleAction,
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: _ProfileAction.privacy,
                            child: Text('隐私说明'),
                          ),
                          PopupMenuItem(
                            value: _ProfileAction.licenses,
                            child: Text('开源许可'),
                          ),
                          PopupMenuItem(
                            value: _ProfileAction.clearCache,
                            child: Text('清理缓存'),
                          ),
                          PopupMenuDivider(),
                          PopupMenuItem(
                            value: _ProfileAction.about,
                            child: Text('关于'),
                          ),
                        ],
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.9),
                            ),
                          ),
                          child: const Icon(Icons.more_horiz_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _GlassCard(
                    child: Stack(
                      children: [
                        Positioned(
                          right: -26,
                          top: -34,
                          child: _DecorCircle(
                            size: 120,
                            color: AppColors.profile.withValues(alpha: 0.18),
                          ),
                        ),
                        Positioned(
                          right: 30,
                          bottom: -34,
                          child: _DecorCircle(
                            size: 90,
                            color: AppColors.profile.withValues(alpha: 0.12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.profile.withValues(
                                        alpha: 0.18,
                                      ),
                                      border: Border.all(
                                        color: AppColors.profile.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _nickname,
                                          style: textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '游客模式 · 登录后可同步收藏',
                                          style: textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  FilledButton.tonal(
                                    onPressed: () => _toast('登录功能待接入'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      minimumSize: const Size(0, 38),
                                      shape: const StadiumBorder(),
                                      backgroundColor: AppColors.surfaceElevated,
                                      foregroundColor: AppColors.textPrimary,
                                      side:
                                          const BorderSide(color: AppColors.border),
                                    ),
                                    child: const Text('去登录'),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    tooltip: '修改昵称',
                                    onPressed: _editNickname,
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 1,
                                color: AppColors.border.withValues(alpha: 0.75),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: const [
                                  Expanded(
                                    child: _StatMini(
                                      icon: Icons.favorite_border,
                                      value: '0',
                                      label: '收藏',
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _StatMini(
                                      icon: Icons.auto_stories_outlined,
                                      value: '3',
                                      label: '已读',
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _StatMini(
                                      icon: Icons.local_fire_department_outlined,
                                      value: '1',
                                      label: '连续',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text('快捷功能', style: textTheme.titleLarge),
                              const Spacer(),
                              Text(
                                '自定义',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.95,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.favorite_outline_rounded,
                                  label: '收藏',
                                  onTap: () => _toast('收藏功能还在路上'),
                                ),
                              ),
                              const _VSeparator(),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.history_rounded,
                                  label: '历史',
                                  onTap: () => _toast('历史记录待实现'),
                                ),
                              ),
                              const _VSeparator(),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.palette_outlined,
                                  label: '外观',
                                  onTap: () => _toast('主题切换待实现'),
                                ),
                              ),
                              const _VSeparator(),
                              Expanded(
                                child: _QuickAction(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: '反馈',
                                  onTap: () => _toast('反馈入口待实现'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionHeader(title: '内容'),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.favorite_outline_rounded,
                          title: '我的收藏',
                          subtitle: '把喜欢的句子留住',
                          onTap: () => _toast('收藏功能还在路上'),
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: Icons.bookmark_border_rounded,
                          title: '阅读历史',
                          subtitle: '最近浏览记录',
                          onTap: () => _toast('历史记录待实现'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(title: '通用'),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.share_outlined,
                          title: '分享 App',
                          subtitle: '把快乐（或清醒）分享出去',
                          onTap: () => _toast('分享功能后续补上'),
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: Icons.cleaning_services_outlined,
                          title: '清理缓存',
                          subtitle: '释放空间，保持顺滑',
                          onTap: _confirmClearCache,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(title: '关于与协议'),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: '隐私说明',
                          subtitle: '你关心的，我们都写清楚',
                          onTap: _showPrivacySheet,
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: Icons.article_outlined,
                          title: '开源许可',
                          subtitle: '第三方依赖与许可信息',
                          onTap: () {
                            showLicensePage(
                              context: context,
                              applicationName: '毒鸡汤',
                              applicationVersion: '1.0.0+1',
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _SettingsTile(
                          icon: Icons.info_outline_rounded,
                          title: '关于',
                          subtitle: '版本、作者与说明',
                          onTap: _showAbout,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '提示：当前页为本地演示版本，后续可接入登录、收藏与同步。',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 10),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _VSeparator extends StatelessWidget {
  const _VSeparator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 1,
        height: 52,
        color: AppColors.border.withValues(alpha: 0.75),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.profile.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.profile.withValues(alpha: 0.28),
                  ),
                ),
                child: Icon(icon, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.profile.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.profile.withValues(alpha: 0.28),
              ),
            ),
            child: Icon(icon, size: 16, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(label, style: textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.profile.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        ),
        child: Icon(icon, color: AppColors.textPrimary),
      ),
      title: Text(title, style: textTheme.bodyLarge),
      subtitle: Text(subtitle, style: textTheme.bodyMedium),
      trailing: const Icon(Icons.chevron_right_rounded),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }
}
