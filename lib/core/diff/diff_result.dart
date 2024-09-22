class DiffResult {
  final int added, removed;
  const DiffResult({required this.added, required this.removed});

  @override
  String toString() {
    return "DiffResult<added = $added, removed = $removed>";
  }
}
