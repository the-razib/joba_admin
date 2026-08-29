import 'package:cloud_firestore/cloud_firestore.dart';

/// Standard page result encapsulating paginated query items and cursor metadata.
class PageResult<T> {
  final List<T> items;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;
  final int totalCount;

  const PageResult({
    required this.items,
    this.lastDoc,
    required this.hasMore,
    this.totalCount = 0,
  });

  const PageResult.empty()
      : items = const [],
        lastDoc = null,
        hasMore = false,
        totalCount = 0;
}

/// Helper function to perform cursor-based pagination against Firestore queries.
Future<PageResult<T>> queryPage<T>({
  required Query<Map<String, dynamic>> query,
  required T Function(Map<String, dynamic> data, String id) fromMap,
  DocumentSnapshot? startAfter,
  int limit = 25,
}) async {
  Query<Map<String, dynamic>> pagedQuery = query.limit(limit + 1);

  if (startAfter != null) {
    pagedQuery = pagedQuery.startAfterDocument(startAfter);
  }

  final snapshot = await pagedQuery.get();
  final docs = snapshot.docs;

  final hasMore = docs.length > limit;
  final resultDocs = hasMore ? docs.sublist(0, limit) : docs;

  final items = resultDocs.map((doc) => fromMap(doc.data(), doc.id)).toList();
  final lastDoc = resultDocs.isNotEmpty ? resultDocs.last : null;

  return PageResult<T>(
    items: items,
    lastDoc: lastDoc,
    hasMore: hasMore,
  );
}
