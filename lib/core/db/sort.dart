abstract class Sort<T> implements Comparable<T> {
  late String label;
  int compare(T a, T b);

  @override
  bool operator ==(Object other) {
    if (other is! Sort) return false;
    return label == other.label;
  }

  @override
  int get hashCode => label.hashCode;

  @override
  int compareTo(T other) {
    if (other is! Sort) return 0;
    return label.compareTo(other.label);
  }
}
