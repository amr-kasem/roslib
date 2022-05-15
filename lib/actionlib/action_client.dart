// Copyright (c) 2019 Conrad Heidebrecht.

import 'dart:async';
import 'dart:developer';
import 'package:roslib/actionlib/action_goal.dart';
import 'package:roslib/core/core.dart';

class ActionClient {
  Ros ros;

  String serverName;

  String actionName;
  String packageName;
  late Topic _feedback;

  late Topic _status;

  late Topic _result;

  late Topic _goal;

  late Topic _cancel;

  ActionGoal? _actionGoal;

  ActionClient(
      {required this.ros,
      required this.serverName,
      required this.actionName,
      required this.packageName}) {
    _feedback = Topic(
      ros: ros,
      name: '$serverName/feedback',
      type: '$packageName/${actionName}Feedback',
    );
    _status = Topic(
      ros: ros,
      name: '$serverName/status',
      type: 'actionlib_msgs/GoalStatusArray',
      reconnectOnClose: true,
      queueLength: 10,
      queueSize: 10,
    );
    _result = Topic(
      ros: ros,
      name: '$serverName/result',
      type: '$packageName/${actionName}Result',
      reconnectOnClose: true,
      queueLength: 10,
      queueSize: 10,
    );
    _goal = Topic(
      ros: ros,
      name: '$serverName/goal',
      type: '$packageName/${actionName}Goal',
    );
    _cancel = Topic(
      ros: ros,
      name: '$serverName/cancel',
      type: 'actionlib_msgs/GoalID',
    );
  }

  Future<bool> connect() async {
    await _feedback.subscribe();
    await _status.subscribe();
    await _result.subscribe();
    await _goal.advertise();
    await _cancel.advertise();
    return true;
  }

  void setGoal({required Map<String, dynamic> goal}) async {
    await _goal.advertise();
    _actionGoal = ActionGoal(goal);
    final msg = _actionGoal;
    await _goal.publish(msg);
  }

  Stream? get feedback => _feedback.subscription!.map(
        (event) => event['msg']['feedback'],
      );
  Stream get status => _status.subscription!.map(
        (event) {
          final statusList = (event['msg']['status_list'] as List);
          if (statusList.isEmpty || _actionGoal == null) {
            return ActionServerStatus.NOTSET;
          } else {
            _actionGoal!.status =
                ActionServerStatus.values[statusList.last['status']];
            return _actionGoal!.status;
          }
        },
      );

  void cancel() {
    if (_actionGoal != null) {
      _cancel.publish(_actionGoal!.goalId);
      // _actionGoal = null;
    }
  }

  void dispose() {
    _feedback.unsubscribe();
    _status.unsubscribe();
    _result.unsubscribe();
    _goal.unadvertise();
  }
}
