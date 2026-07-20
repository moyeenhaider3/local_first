import 'package:flutter/material.dart';
import 'package:local_first/data/models/app_update_status.dart';
import 'package:url_launcher/url_launcher.dart';

enum UpdateDialogAction { later }

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({
    required this.status,
    required this.forceUpdate,
    super.key,
  });

  final AppUpdateStatus status;
  final bool forceUpdate;

  static Future<UpdateDialogAction?> show(
    BuildContext context,
    AppUpdateStatus status,
  ) {
    return showDialog<UpdateDialogAction>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return UpdateDialog(status: status, forceUpdate: status.forceUpdate);
      },
    );
  }

  Future<void> _openStore() async {
    final uri = Uri.parse(status.storeUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = status.releaseNotes.trim();

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(forceUpdate ? 'Update required' : 'Update available'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Current version: ${status.currentVersion}'),
              const SizedBox(height: 4),
              Text('Latest version: ${status.latestVersion}'),
              if (notes.isNotEmpty) ...<Widget>[
                const SizedBox(height: 16),
                Text('What\'s new', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Text(notes),
              ],
            ],
          ),
        ),
        actions: <Widget>[
          if (!forceUpdate)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(UpdateDialogAction.later);
              },
              child: const Text('Later'),
            ),
          FilledButton(
            onPressed: () {
              _openStore();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
