27/1/2026
- more deck kinds
- kind: duolingo with two languages, translation audio and imgage shared for both card sides
- kind: quiz with two card size, one is the question like "What is the capital city of" second is the image with flag, caption with capital name + population of the city
- kind: learning with topic on one page and number of captions or images you can scroll through to learn like movements for chi-kung and the name of the movement in deck by exercise
- generator: duolingo = manual json with hook to grab image and translation by LLM
- generator: quiz = fetch from wikipedia
- generator: learnings = fully manual with different card layout like more than two card size only)

26/1/2026
- more kind of cards (duolingo, quiz, learn)
- instagram like cards scrolling
- ai query for image and translation content
- deck creation and assets scripts
- release on iOS: `flutter clean && flutter pub get && flutter run -d 00008101-001175D90AA0001E --release`

23/1/2026
- tweak gestures to take dominant move
- stats on deck lists

20/1/2026
- iOS app is crashing on mobile device if not attached to XCode: `$flutter  run --release`
- stuck on `$flutter run` to build iOS: `$flutter build ios --no-codesign`

18/1/2026
- 10 japanese cards in deck with japanese runes
- duo sided cards
- up to decrease priority (I already know that world); down do increase priority (save for future, I don't know)
- left right to keep the order
- priority rnd algoritm
- attaching issues with initial VM Flutter image on iOS resolved by `$flutter run --device-vmservice-port 61616 --host-vmservice-port 61616 -v`

17/1/2026
- Interview Happy Coder to find right language to support both mobile platforms
- UX requirements
- simplify storrage requirements
- defer image and audio requirements
