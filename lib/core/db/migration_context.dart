import 'package:cards/core/db/migration.dart';

abstract class MigrationContext<T> {
  final List<Migration<T>> migrations = <Migration<T>>[];

  Future<void> addMigration(Migration<T> migration);

  Future<T> runAllMigrations(T sourceModel);
}
