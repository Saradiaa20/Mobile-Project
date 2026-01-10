import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

/// PROVIDER
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, OrdersState>(
  (ref) => OrdersNotifier(),
);

/// STATE
class OrdersState {
  final List<OrderModel> orders;
  final bool isLoading;

  OrdersState({
    required this.orders,
    required this.isLoading,
  });

  factory OrdersState.initial() {
    return OrdersState(
      orders: [],
      isLoading: false,
    );
  }

  OrdersState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// NOTIFIER
class OrdersNotifier extends StateNotifier<OrdersState> {
  OrdersNotifier() : super(OrdersState.initial());

  final OrderService _service = OrderService();

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true);

    final data = await _service.getMyOrders();
    final orders =
        data.map((e) => OrderModel.fromMap(e)).toList();

    state = state.copyWith(
      orders: orders,
      isLoading: false,
    );
  }
}
