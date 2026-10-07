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

  Future<void> shot(String name) async {
    await Future<void>.delayed(pause);
    final r = await Process.run(
        'xcrun', ['simctl', 'io', device, 'screenshot', '$dir/$name.png']);
    if (r.exitCode != 0) throw StateError('simctl: ${r.stderr}');
    stdout.writeln('shot $name');
  }

  try {
    await driver.waitFor(find.byType('DeckCoverTile'),
        timeout: const Duration(minutes: 3));
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
