import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_content.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return AssetContentRepository(rootBundle);
});

abstract class ContentRepository {
  Future<ShiftContent> loadShift(int shiftNumber);
}

class AssetContentRepository implements ContentRepository {
  const AssetContentRepository(this.assetBundle);

  final AssetBundle assetBundle;

  @override
  Future<ShiftContent> loadShift(int shiftNumber) async {
    final paddedShift = shiftNumber.toString();
    final rawJson = await assetBundle.loadString(
      'assets/content/shifts/shift_$paddedShift.json',
    );
    return ShiftContent.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
  }
}
