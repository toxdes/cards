import 'package:cards/config/colors.dart';
import 'package:cards/config/fonts.dart';
import 'package:cards/core/step/step.dart';
import 'package:flutter/material.dart' hide Step;

class StepHeader extends StatelessWidget {
  const StepHeader(
      {super.key,
      required this.status,
      required this.stepId,
      required this.title,
      this.actionCallback});

  final int stepId;
  final String title;
  final StepStatus status;
  final void Function(StepAction action, int stepId)? actionCallback;

  IconData _getIconForStatus() {
    if (status == StepStatus.pending) return Icons.pending_actions_outlined;
    if (status == StepStatus.active) return Icons.flag_circle;
    if (status == StepStatus.completed) return Icons.check_circle;
    if (status == StepStatus.error) return Icons.close;
    return Icons.circle;
  }

  Color _getIconColorForStatus() {
    if (status == StepStatus.pending) return ThemeColors.white2;
    if (status == StepStatus.active) return ThemeColors.yellow;
    if (status == StepStatus.error) return ThemeColors.red;
    if (status == StepStatus.completed) return ThemeColors.green;
    return ThemeColors.white2;
  }

  @override
  Widget build(BuildContext context) {
    bool isActive =
        status == StepStatus.active || status == StepStatus.completed;
    return GestureDetector(
      onTap: () {
        if (actionCallback != null) {
          actionCallback!(StepAction.expand, stepId);
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          color: ThemeColors.white3.withOpacity(!isActive ? 0.4 : 1),
          width: 2,
        ))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(stepId.toString(),
                style: TextStyle(
                    fontFamily: Fonts.rubik,
                    fontSize: 36,
                    decoration: TextDecoration.none,
                    color: ThemeColors.blue.withOpacity(!isActive ? 0.4 : 1),
                    fontWeight: FontWeight.w600)),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Text(title,
                  style: TextStyle(
                      fontFamily: Fonts.rubik,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                      color:
                          ThemeColors.white1.withOpacity(!isActive ? 0.4 : 1),
                      fontWeight: FontWeight.w400)),
            ),
            const Spacer(),
            Icon(
              _getIconForStatus(),
              size: 28,
              color: _getIconColorForStatus().withOpacity(!isActive ? 0.4 : 1),
            )
          ],
        ),
      ),
    );
  }
}
