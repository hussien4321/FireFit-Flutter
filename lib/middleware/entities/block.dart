class Block {

  int blockId;
  String blockingUserId;
  String blockedUserId;
  DateTime blockCreatedAt;

  Block({
    this.blockId,
    this.blockedUserId,
    this.blockingUserId,
    this.blockCreatedAt,
  });

  Map<String, dynamic> toJson() => {
    'block_id': blockId,
    'blocking_user_id' : blockingUserId,
    'blocked_user_id': blockedUserId,
    'block_created_at': blockCreatedAt?.toIso8601String(),
  };
}