abstract class PrioritizableCard {
  String get priorityId;
  int get priority;
  set priority(int value);
  DateTime? get lastSeen;
  set lastSeen(DateTime? value);
  void increasePriority();
  void decreasePriority();
}
