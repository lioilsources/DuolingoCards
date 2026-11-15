import 'package:flutter_test/flutter_test.dart';
import 'package:duolingo_cards/services/set_ladder.dart';

// Same table in every Ol1n app that ships set_ladder.dart: keep it generic.
void main() {
  const steps = <SetLadderStep>[
    (threshold: 0, productId: 'all'),
    (threshold: 1, productId: 'all_s1'),
    (threshold: 2, productId: 'all_s2'),
    (threshold: 3, productId: 'all_s3'),
    (threshold: 4, productId: 'all_s4'),
  ];

  const table = <(int, String)>[
    (0, 'all'),
    (1, 'all_s1'),
    (2, 'all_s2'),
    (3, 'all_s3'),
    (4, 'all_s4'),
    (5, 'all_s4'),
    (7, 'all_s4'),
    (100, 'all_s4'),
  ];

  for (final (owned, expected) in table) {
    test('owning $owned offers $expected', () {
      expect(setLadderOffer(owned, steps), expected);
    });
  }

  test('an empty ladder offers nothing', () {
    expect(setLadderOffer(3, const []), isNull);
  });

  test('no step is met when the lowest threshold is above the count', () {
    expect(
      setLadderOffer(1, const [(threshold: 2, productId: 'x')]),
      isNull,
    );
  });

  test('a negative count is treated like nothing owned', () {
    expect(setLadderOffer(-1, steps), isNull);
  });

  test('step order does not change the result', () {
    final reversed = steps.reversed.toList();
    for (final (owned, expected) in table) {
      expect(setLadderOffer(owned, reversed), expected, reason: '$owned');
    }
  });

  test('a gap in thresholds falls back to the step below', () {
    const sparse = <SetLadderStep>[
      (threshold: 0, productId: 'full'),
      (threshold: 5, productId: 'deep'),
    ];
    expect(setLadderOffer(4, sparse), 'full');
    expect(setLadderOffer(5, sparse), 'deep');
  });
}
