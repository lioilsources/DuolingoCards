// Complete-the-set pricing ladder.
//
// The stores cannot price a product per customer, so an "everything" bundle is
// sold as several products ("steps") that unlock identical content at
// different fixed prices. Each step has a threshold: how many items the
// customer must already own to be offered it. The app offers the highest step
// whose threshold is met, so earlier purchases are credited.
//
// This file is deliberately dependency-free (no Flutter, no packages) so the
// same file and its table test can be copied verbatim into every Ol1n app.

/// One step of the ladder: offered once the customer owns at least
/// [threshold] items.
typedef SetLadderStep = ({int threshold, String productId});

/// The product id to offer to a customer who owns [owned] items, or null when
/// no step's threshold is met (including an empty ladder).
///
/// [steps] should be sorted by ascending threshold; the result does not depend
/// on it — the step with the highest threshold not above [owned] wins, and on
/// a tie the later step wins.
String? setLadderOffer(int owned, List<SetLadderStep> steps) {
  SetLadderStep? best;
  for (final step in steps) {
    if (step.threshold > owned) continue;
    if (best == null || step.threshold >= best.threshold) best = step;
  }
  return best?.productId;
}
