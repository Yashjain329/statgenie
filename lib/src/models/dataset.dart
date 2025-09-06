class Dataset {
  final String id;
  final String userId;
  final String name;
  final String? fileUrl;
  final int? fileSize;
  final int? rowCount;
  final int? columnCount;
  final DateTime createdAt;
  final bool pendingSync;

  Dataset({
    required this.id,
    required this.userId,
    required this.name,
    this.fileUrl,
    this.fileSize,
    this.rowCount,
    this.columnCount,
    required this.createdAt,
    this.pendingSync = false,
  });

  factory Dataset.fromJson(Map<String, dynamic> json) => Dataset(
    id: json['id'],
    userId: json['user_id'],
    name: json['name'],
    fileUrl: json['file_url'],
    fileSize: json['file_size'],
    rowCount: json['row_count'],
    columnCount: json['column_count'],
    createdAt: DateTime.parse(json['created_at']),
    pendingSync: json['pending_sync'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'file_url': fileUrl,
    'file_size': fileSize,
    'row_count': rowCount,
    'column_count': columnCount,
    'created_at': createdAt.toIso8601String(),
    'pending_sync': pendingSync,
  };
}