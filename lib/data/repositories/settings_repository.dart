import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_first/core/constants/app_constants.dart';
import 'package:local_first/core/utils/version_utils.dart';
import 'package:local_first/data/models/app_settings_model.dart';
import 'package:local_first/data/models/app_update_status.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsRepository {
  SettingsRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<AppUpdateStatus?> checkForAppUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version.trim();

      final snapshot = await _firestore
          .doc(AppConstants.appConfigDocumentPath)
          .get();
      final settings = snapshot.exists
          ? AppSettingsModel.fromJson(snapshot.data())
          : AppSettingsModel.defaults();

      final latestVersion = settings.latestVersion.trim();
      if (latestVersion.isEmpty) {
        return AppUpdateStatus(
          updateAvailable: false,
          forceUpdate: false,
          currentVersion: currentVersion,
          latestVersion: currentVersion,
          releaseNotes: settings.releaseNotes,
          storeUrl: settings.storeUrl,
        );
      }

      final comparison = VersionUtils.compareSemanticVersions(
        currentVersion,
        latestVersion,
      );
      final updateAvailable = comparison < 0;

      return AppUpdateStatus(
        updateAvailable: updateAvailable,
        forceUpdate: updateAvailable && settings.forceUpdate,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        releaseNotes: settings.releaseNotes,
        storeUrl: settings.storeUrl.isNotEmpty
            ? settings.storeUrl
            : AppConstants.defaultStoreUrl,
      );
    } catch (_) {
      return null;
    }
  }
}
