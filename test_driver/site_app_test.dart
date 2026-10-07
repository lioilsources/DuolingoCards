import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

/// Host side of `make site-screenshots`: walks the app through the six scenes
/// the olin.now page shows and captures each with `simctl`, status bar and all,
/// into `$SHOTS_DIR/<name>.png`.
Future<void> main() async {
  final dir = Platform.environment['SHOTS_DIR'] ?? 'build/site_screenshots';
  final device = Platform.environment['SHOTS_DEVICE'] ?? 'booted';
  await Directory(dir).create(recursive: true);

  final driver = await FlutterDriver.connect();
  const pause = Duration(seconds: 2);

  // `make site-screenshots-macos`: the same walk against the desktop build,
  // captured as the app's window (title bar included).
  final desktop = Platform.environment['SHOTS_MODE'] == 'desktop';
  final process = Platform.environment['SHOTS_PROCESS'] ?? 'Lexify';
  final size = Platform.environment['SHOTS_SIZE'] ?? '760, 1000';

  Future<String> window(String script) async {
    final r = await Process.run('osascript', [
      '-e',
      'tell application "System Events" to tell process "$process" to $script'
    ]);
    if (r.exitCode != 0) throw StateError('osascript: ${r.stderr}');
    return (r.stdout as String).trim();
  }

  String? id;
  Future<String> windowId() async {
    if (id != null) return id!;
    final r = await Process.run(
        'swift', ['test_driver/window_id.swift', process]);
    if (r.exitCode != 0) throw StateError('no $process window on screen');
    return id = (r.stdout as String).trim();
  }

  Future<void> shot(String name) async {
    await Future<void>.delayed(pause);
    final ProcessResult r;
    if (desktop) {
      await window('set frontmost to true');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      // By window id, not by rectangle: no shadow, and nothing of whatever
      // sits behind the rounded corners.
      r = await Process.run(
          'screencapture', ['-x', '-o', '-l${await windowId()}', '$dir/$name.png']);
    } else {
      r = await Process.run(
          'xcrun', ['simctl', 'io', device, 'screenshot', '$dir/$name.png']);
    }
    if (r.exitCode != 0) throw StateError('capture: ${r.stderr}');
    stdout.writeln('shot $name');
  }

  try {
    await driver.waitFor(find.byType('DeckCoverTile'),
        timeout: const Duration(minutes: 3));
    if (desktop) {
      await window('set position of window 1 to {40, 40}');
      await window('set size of window 1 to {$size}');
    }
    final s = jsonDecode(await driver.requestData('strings')) as Map;
    String t(String k) => s[k] as String;

    Future<void> openFromStore(String title) async {
      await driver.scrollUntilVisible(find.byType('ListView'), find.text(title),
          dyScroll: -250);
      await driver.tap(find.text(title));
    }

    // Not find.pageBack(): that looks for the English tooltip.
    final back = find.byType('BackButton');

    await shot('home');

    await driver.tap(find.byTooltip(t('store')));
    await driver.waitFor(find.byType('DeckCoverStrip'));
    await shot('shop');

    // Language pair: the "learning" menu open over a free deck's detail.
    await openFromStore(t('pets'));
    await driver.tap(find.text(t('l2')));
    await shot('shop_languages');
    await driver.tap(find.text(t('l2pick')));
    await driver.tap(back);

    // Style picker: a paid deck in its illustrated look.
    await openFromStore(t('weather'));
    await driver.tap(find.text(t('watercolor')));
    await shot('akvarel_style');
    await driver.tap(back);
    await driver.tap(back);

    // Study: a card at rest, then mid-swipe with the heart showing.
    await driver.scrollUntilVisible(
        find.byType('ReorderableListView'), find.text(t('pets')),
        dyScroll: -250);
    await driver.tap(find.text(t('pets')));
    await driver.waitFor(find.byType('LanguageDeckStudyScreen'));
    await shot('card');
    await driver.requestData('drag');
    await shot('card_like');
    await driver.requestData('release');
  } finally {
    await driver.close();
  }
}
