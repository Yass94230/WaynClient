class CallSession {
  final String channelName;
  final int uid;
  final bool isJoined;
  final int? remoteUid; // Ajout du remoteUid

  CallSession({
    required this.channelName,
    required this.uid,
    required this.isJoined,
    this.remoteUid,
  });

  CallSession copyWith({
    String? channelName,
    int? uid,
    bool? isJoined,
    int? remoteUid,
  }) {
    return CallSession(
      channelName: channelName ?? this.channelName,
      uid: uid ?? this.uid,
      isJoined: isJoined ?? this.isJoined,
      remoteUid: remoteUid ?? this.remoteUid,
    );
  }
}
