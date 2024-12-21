enum StepStatus { pending, active, error, completed }

enum StepAction { expand }

class Step {
  int id;
  StepStatus status;
  String title;
  bool expanded;
  Step(
      {required this.id,
      this.status = StepStatus.pending,
      this.expanded = false,
      required this.title});
}
