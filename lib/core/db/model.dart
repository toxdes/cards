class Model {
  final int schemaVersion;
  const Model({required this.schemaVersion});

  bool shouldRunMigration(int otherSchemaVersion) {
    return otherSchemaVersion > schemaVersion;
  }
}
