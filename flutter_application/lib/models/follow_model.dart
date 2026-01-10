class Follow {
  final String id;
  final String userId;
  final String brandId;
  final DateTime createdAt;

  Follow({
    required this.id,
    required this.userId,
    required this.brandId,
    required this.createdAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      brandId: json['brand_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'brand_id': brandId,
      };
}