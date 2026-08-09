import 'package:intl/intl.dart';

/// 12400 -> "12.4K"
String compactNumber(num value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1).replaceAll('.0', '')}K';
  }
  return '$value';
}

String formatDate(DateTime d) => DateFormat('d MMM yyyy').format(d);

String formatDateTime(DateTime d) =>
    DateFormat('d MMM yyyy, hh:mm a').format(d);

String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).floor();
    return '$weeks week${weeks == 1 ? '' : 's'} ago';
  }
  return formatDate(d);
}

String fileSizeLabel(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '$bytes B';
}

/// Binary byte sizes up to TiB, for storage totals and network egress.
String dataSizeLabel(num bytes) {
  const kib = 1024;
  const mib = kib * 1024;
  const gib = mib * 1024;
  const tib = gib * 1024;
  if (bytes >= tib) return '${(bytes / tib).toStringAsFixed(2)} TB';
  if (bytes >= gib) return '${(bytes / gib).toStringAsFixed(2)} GB';
  if (bytes >= mib) return '${(bytes / mib).toStringAsFixed(1)} MB';
  if (bytes >= kib) return '${(bytes / kib).toStringAsFixed(0)} KB';
  return '${bytes.round()} B';
}

/// USD with cent precision below $10, whole dollars above, so KPI cards stay
/// readable at a glance.
String usd(double value) {
  if (value >= 1000) return '\$${NumberFormat('#,##0').format(value)}';
  if (value >= 10) return '\$${value.toStringAsFixed(2)}';
  return '\$${value.toStringAsFixed(3)}';
}

/// 12400 -> "12,400"
String groupedNumber(num value) => NumberFormat('#,##0').format(value);
