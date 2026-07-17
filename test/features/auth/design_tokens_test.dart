import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_first/core/theme/design_tokens.dart';

void main() {
  test('ColorPrimary matches design.md #0D9488', () {
    expect(DesignTokens.colorPrimary, const Color(0xFF0D9488));
  });

  test('kTouchMin is 48.0', () {
    expect(DesignTokens.kTouchMin, 48.0);
  });

  test('spacing tokens follow 8dp grid', () {
    expect(DesignTokens.kSpace8, 8.0);
    expect(DesignTokens.kSpace16, 16.0);
    expect(DesignTokens.kSpace24, 24.0);
    expect(DesignTokens.kSpace48, 48.0);
  });
}
