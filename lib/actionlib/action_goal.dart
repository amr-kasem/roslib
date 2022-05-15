enum ActionServerStatus {
  PENDING,
  ACTIVE,
  PREEMPTED,
  SUCCEEDED,
  ABORTED,
  REJECTED,
  PREEMPTING,
  RECALLING,
  RECALLED,
  LOST,
  READY,
  NOTSET,
}

class ActionGoal {
  ActionServerStatus status = ActionServerStatus.READY;
  final _x = DateTime.now().millisecondsSinceEpoch;
  late final Map<String, dynamic> _header, _goalId;
  Map<String, dynamic> goal;
  ActionGoal(this.goal) {
    _header = {'seq': _x.toInt(), 'stamp': _x, 'frame_id': 'map'};
    _goalId = {'stamp': _x, 'id': '$_x'};
  }

  Map<String, dynamic> toJson() {
    return {
      'header': _header,
      'goal_id': _goalId,
      'goal': goal,
    };
  }

  Map<String, dynamic> get goalId => _goalId;

  @override
  String toString() {
    return '\n{$_goalId["id"] : $status}';
  }
}
