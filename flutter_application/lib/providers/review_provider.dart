import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

/// PROVIDER
final reviewProvider =
    StateNotifierProvider<ReviewNotifier, ReviewState>(
  (ref) => ReviewNotifier(),
);

/// STATE
class ReviewState {
  final List<Review> reviews;
  final bool isLoading;

  ReviewState({
    required this.reviews,
    required this.isLoading,
  });

  factory ReviewState.initial() {
    return ReviewState(
      reviews: [],
      isLoading: false,
    );
  }

  ReviewState copyWith({
    List<Review>? reviews,
    bool? isLoading,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// NOTIFIER
class ReviewNotifier extends StateNotifier<ReviewState> {
  ReviewNotifier() : super(ReviewState.initial());

  final ReviewService _service = ReviewService();

  /// LOAD
  Future<void> loadReviews(String productId) async {
    state = state.copyWith(isLoading: true);

    try {
      final data = await _service.getReviews(productId);
      final reviews =
          data.map((e) => Review.fromJson(e)).toList();

      state = state.copyWith(
        reviews: reviews,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        reviews: [],
        isLoading: false,
      );
    }
  }

  /// ADD
  Future<void> addReview({
    required String productId,
    required String comment,
    File? imageFile,
  }) async {
    String? imageUrl;

    if (imageFile != null) {
      imageUrl = await _service.uploadReviewImage(
        productId: productId,
        imageFile: imageFile,
      );
    }

    await _service.addReview(
      productId: productId,
      comment: comment,
      imageUrl: imageUrl,
    );

    await loadReviews(productId);
  }
}
