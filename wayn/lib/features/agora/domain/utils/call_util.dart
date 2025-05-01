class CallUtils {
  static String generateChannelName(String userId1, String userId2) {
    // Trier les IDs pour avoir toujours le même ordre
    final sortedIds = [userId1, userId2]..sort();
    return 'call_${sortedIds[0]}_${sortedIds[1]}';
  }
}
