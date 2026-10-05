import 'dart:async';

import 'package:cute_kid_fonts/cute_kid_fonts_testing.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real kid fonts so tests measure the glyphs the app ships instead
/// of the Ahem placeholder boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadKidFonts();
  await testMain();
}
