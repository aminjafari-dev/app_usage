import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_usage/core/locator/locator.dart';
import 'package:app_usage/core/theme/app_theme.dart';
import 'package:app_usage/core/widgets/g_card.dart';
import 'package:app_usage/core/widgets/g_gap.dart';
import 'package:app_usage/core/widgets/g_scaffold.dart';
import 'package:app_usage/core/widgets/g_text.dart';
import 'package:app_usage/features/drive_sync/domain/drive_sync_service.dart';
import 'package:app_usage/l10n/app_localizations.dart';

/// Profile tab — identity card + Drive sync status.
///
/// How to use: hosted inside [MainShellPage] via [IndexedStack].
class ProfilePage extends StatefulWidget {
  /// Creates the profile tab.
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userId;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final id = await locator<DriveSyncService>().userId();
    if (!mounted) return;
    setState(() => _userId = id);
  }

  Future<void> _syncNow() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    final l10n = AppLocalizations.of(context);
    final ok = await locator<DriveSyncService>().syncNow();
    if (!mounted) return;
    setState(() => _syncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? l10n.profileSyncOk : l10n.profileSyncFail)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userId = _userId;

    return GScaffold(
      title: l10n.navProfile,
      centerTitle: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          GGap.m(),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppTheme.primarySoft,
              child: Icon(
                Icons.person_rounded,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
          ),
          GGap.m(),
          GText(
            l10n.profileName,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          GGap.s(),
          GText(
            l10n.profileSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            color: AppTheme.onSurfaceMuted,
            textAlign: TextAlign.center,
          ),
          GGap.l(),
          GCard(
            child: GSettingsTile(
              icon: Icons.favorite_rounded,
              iconColor: AppTheme.primary,
              title: l10n.appTitle,
              subtitle: 'v1.0.0',
            ),
          ),
          GGap.m(),
          GCard(
            child: Column(
              children: [
                GSettingsTile(
                  icon: Icons.cloud_upload_rounded,
                  iconColor: AppTheme.primary,
                  title: l10n.profileSyncTitle,
                  subtitle: userId == null
                      ? '…'
                      : l10n.profileSyncSubtitle(userId),
                  onTap: userId == null
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: userId));
                        },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _syncing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.sync_rounded, color: AppTheme.primary),
                  title: Text(l10n.profileSyncNow),
                  onTap: _syncing ? null : _syncNow,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
