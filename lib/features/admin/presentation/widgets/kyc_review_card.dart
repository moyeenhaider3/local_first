import 'package:flutter/material.dart';
import 'package:local_first/core/theme/app_theme.dart';
import 'package:local_first/features/auth/domain/entities/user_entity.dart';

class KycReviewCard extends StatelessWidget {
  final UserEntity user;
  final Function(String uid, String? remarks) onApprove;
  final Function(String uid, String? remarks) onReject;

  const KycReviewCard({
    super.key,
    required this.user,
    required this.onApprove,
    required this.onReject,
  });

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: Center(
                child: user.kycDocumentUrl != null
                    ? Image.network(
                        user.kycDocumentUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Failed to load KYC image',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      )
                    : const Icon(Icons.broken_image, size: 80, color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, {required bool isApproval}) {
    final theme = Theme.of(context);
    final spacing = context.spacing;
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApproval ? 'Approve KYC' : 'Reject KYC'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApproval
                  ? 'Are you sure you want to approve KYC for ${user.displayName ?? 'User'}?'
                  : 'Are you sure you want to reject KYC for ${user.displayName ?? 'User'}?',
              style: theme.textTheme.bodyLarge,
            ),
            SizedBox(height: spacing.space16),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                hintText: 'Add a note...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? Colors.green : theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              final remarks = textController.text.trim().isEmpty ? null : textController.text.trim();
              if (isApproval) {
                onApprove(user.userId, remarks);
              } else {
                onReject(user.userId, remarks);
              }
            },
            child: Text(isApproval ? 'APPROVE' : 'REJECT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = context.spacing;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: spacing.edgeMargin,
        vertical: spacing.space8,
      ),
      color: theme.colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    (user.displayName ?? 'U').substring(0, 1).toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: spacing.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'Unknown Name',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.phone,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.verificationStatus.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.space16),

            // Document Thumbnail
            if (user.kycDocumentUrl != null) ...[
              Text(
                'Submitted KYC Document (Tap to view)',
                style: theme.textTheme.labelSmall,
              ),
              SizedBox(height: spacing.space8),
              GestureDetector(
                onTap: () => _showImageDialog(context),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      user.kycDocumentUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ] else
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('No document uploaded'),
                ),
              ),

            SizedBox(height: spacing.space16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showActionDialog(context, isApproval: false),
                    child: const Text('REJECT'),
                  ),
                ),
                SizedBox(width: spacing.space16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showActionDialog(context, isApproval: true),
                    child: const Text('APPROVE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
