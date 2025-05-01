class CallRequest {
  final String callId;
  final String callerId;
  final String receiverId;
  final String channelName;
  final String status; // 'pending', 'accepted', 'rejected', 'missed', 'ended'
  final DateTime createdAt;

  CallRequest({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.channelName,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'receiverId': receiverId,
      'channelName': channelName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
