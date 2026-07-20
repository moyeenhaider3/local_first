import 'package:local_first/core/constants/app_constants.dart';

class AppSettingsModel {
  const AppSettingsModel({
    required this.latestVersion,
    required this.forceUpdate,
    required this.releaseNotes,
    required this.storeUrl,
  });

  final String latestVersion;
  final bool forceUpdate;
  final String releaseNotes;
  final String storeUrl;

  factory AppSettingsModel.defaults() {
    return const AppSettingsModel(
      latestVersion: '',
      forceUpdate: false,
      releaseNotes: '',
      storeUrl: AppConstants.defaultStoreUrl,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic>? json) {
    final data = json ?? const <String, dynamic>{};
    final rawStoreUrl = (data['storeUrl'] as String?)?.trim() ?? '';

    return AppSettingsModel(
      latestVersion: (data['latestVersion'] as String?)?.trim() ?? '',
      forceUpdate: data['forceUpdate'] as bool? ?? false,
      releaseNotes: (data['releaseNotes'] as String?)?.trim() ?? '',
      storeUrl: rawStoreUrl.isNotEmpty
          ? rawStoreUrl
          : AppConstants.defaultStoreUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latestVersion': latestVersion,
      'forceUpdate': forceUpdate,
      'releaseNotes': releaseNotes,
      'storeUrl': storeUrl,
    };
  }
}
