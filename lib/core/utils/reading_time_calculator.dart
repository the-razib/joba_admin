import 'dart:math' as math;

/// Standard Reading Time Calculator
///
/// Research-backed Words-Per-Minute (WPM) benchmarks:
/// - **English:** 200 WPM (standard non-fiction / health article silent reading speed)
/// - **Bengali:** 160 WPM (standard Bengali reading speed factoring script density & conjuncts)
class ReadingTimeCalculator {
  static const int englishWpm = 200;
  static const int bengaliWpm = 160;

  /// Calculate reading time in minutes based on Bengali and English text content.
  ///
  /// Returns 0 if both texts are empty.
  /// If content is present, returns at least 1 minute (rounded up).
  static int calculate({
    String? contentBn,
    String? contentEn,
  }) {
    final bnWords = countWords(contentBn);
    final enWords = countWords(contentEn);

    if (bnWords == 0 && enWords == 0) return 0;

    final bnMinutes = bnWords > 0 ? (bnWords / bengaliWpm) : 0.0;
    final enMinutes = enWords > 0 ? (enWords / englishWpm) : 0.0;

    // Use the longer reading duration between the two languages
    final maxMinutes = math.max(bnMinutes, enMinutes);

    // Ceil to next full minute, minimum 1 minute
    final result = maxMinutes.ceil();
    return result < 1 ? 1 : result;
  }

  /// Accurate word count accounting for whitespace, newlines, and markdown formatting.
  static int countWords(String? text) {
    if (text == null || text.trim().isEmpty) return 0;

    // Strip markdown formatting symbols (headers, bold, italic, links, blockquotes)
    final clean = text
        .replaceAll(RegExp(r'#+\s*'), ' ')
        .replaceAll(RegExp(r'[\*\_\~`>]'), ' ')
        .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1')
        .trim();

    if (clean.isEmpty) return 0;

    // Split on whitespace sequences
    final words = clean.split(RegExp(r'\s+')).where((w) => w.trim().isNotEmpty);
    return words.length;
  }

  /// Formats a descriptive summary of word counts and calculated minutes.
  static String getBreakdown({String? contentBn, String? contentEn}) {
    final bnWords = countWords(contentBn);
    final enWords = countWords(contentEn);
    final minutes = calculate(contentBn: contentBn, contentEn: contentEn);

    if (bnWords == 0 && enWords == 0) {
      return 'No text written yet';
    }

    final parts = <String>[];
    if (bnWords > 0) parts.add('$bnWords বাংলা শব্দ (~160 wpm)');
    if (enWords > 0) parts.add('$enWords English words (~200 wpm)');

    return '${parts.join(" • ")} ➔ $minutes min read';
  }
}
