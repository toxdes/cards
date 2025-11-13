abstract class Flavor {
  final String name;
  const Flavor({required this.name});
  String getLabel();
}

class DevFlavor extends Flavor {
  const DevFlavor() : super(name: "Development");
  @override
  String toString() {
    return 'DevFlavor<$name>';
  }

  @override
  String getLabel() {
    return "DEV BUILD";
  }
}

class ProdFlavor extends Flavor {
  const ProdFlavor() : super(name: "Production");
  @override
  String toString() {
    return '';
  }

  @override
  String getLabel() {
    return "";
  }
}

class FlavorService {
  static Flavor getFlavor() {
    String flavorString = const String.fromEnvironment('FLUTTER_APP_FLAVOR');
    return flavorString == 'dev' ? const DevFlavor() : const ProdFlavor();
  }
}
