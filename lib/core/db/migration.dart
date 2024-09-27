abstract class Migration<T> {
  final int id;
  final int fromSchemaId;
  final int toSchemaId;
  Migration(
      {required this.id, required this.fromSchemaId, required this.toSchemaId});
  Future<T> migrate(T sourceModel);
}
