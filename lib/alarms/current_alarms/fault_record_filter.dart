bool isClosedFaultRecord(List<String> parts) {
  for (final part in parts.skip(5)) {
    final normalized = part.trim().toUpperCase();
    if (normalized == 'CLOSE' || normalized == 'CLOSED') {
      return true;
    }

    final labelValueMatch = RegExp(
      r'\bFAULTS?_STATUS\b\s*[:=]\s*(CLOSE|CLOSED)\b',
    ).hasMatch(normalized);
    if (labelValueMatch) {
      return true;
    }
  }

  return false;
}
