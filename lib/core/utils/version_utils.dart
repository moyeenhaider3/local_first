class VersionUtils {
  VersionUtils._();

  static int compareSemanticVersions(String leftVersion, String rightVersion) {
    final leftSegments = _parseVersionSegments(leftVersion);
    final rightSegments = _parseVersionSegments(rightVersion);
    final segmentCount = leftSegments.length > rightSegments.length
        ? leftSegments.length
        : rightSegments.length;

    for (var index = 0; index < segmentCount; index++) {
      final left = index < leftSegments.length ? leftSegments[index] : 0;
      final right = index < rightSegments.length ? rightSegments[index] : 0;

      if (left != right) {
        return left.compareTo(right);
      }
    }

    return 0;
  }

  static List<int> _parseVersionSegments(String version) {
    final normalized = version
        .trim()
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')
        .first;

    if (normalized.isEmpty) {
      return const <int>[0];
    }

    return normalized.split('.').map(_parseNumericSegment).toList();
  }

  static int _parseNumericSegment(String segment) {
    final parsed = int.tryParse(segment.trim());
    return parsed ?? 0;
  }
}
