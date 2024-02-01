class Counter {
  int _value;
  Counter(this._value);
  void inc() {
    _value++;
  }

  void dec() {
    _value--;
  }

  int get() {
    return _value;
  }
}
