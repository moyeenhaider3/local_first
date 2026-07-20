import 'package:equatable/equatable.dart';

class AppUpdateStatus extends Equatable {
  const AppUpdateStatus({
    required this.updateAvailable,
    required this.forceUpdate,
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseNotes,
    required this.storeUrl,
  });

  final bool updateAvailable;
  final bool forceUpdate;
  final String currentVersion;
  final String latestVersion;
  final String releaseNotes;
  final String storeUrl;

  @override
  List<Object?> get props => <Object?>[
    updateAvailable,
    forceUpdate,
    currentVersion,
    latestVersion,
    releaseNotes,
    storeUrl,
  ];
}
