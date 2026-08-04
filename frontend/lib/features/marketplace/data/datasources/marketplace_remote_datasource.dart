import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';
import '../models/seller_model.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<ProductModel>> getProducts({String? category, String? searchQuery});
  Future<ProductModel> getProductById(String id);
  Future<OrderModel> placeOrder(OrderModel order);
  Future<List<OrderModel>> getMyOrders(String buyerId);
  Future<List<OrderModel>> getIncomingOrders(String sellerId);
  Future<OrderModel> updateOrderStatus({required String orderId, required String status});
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final ApiClient _api;

  MarketplaceRemoteDataSourceImpl({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final params = <String, String>{
        if (category != null && category.isNotEmpty) 'category': category,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
      };
      final data = await _api.get(
        ApiConstants.marketplaceProducts,
        queryParams: params.isNotEmpty ? params : null,
      );
      // Backend returns paginated: { items: [...], ... }
      final List<dynamic> items = data is Map ? (data['items'] ?? data) : data;
      return items
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch products: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final data = await _api.get(ApiConstants.productById(id));
      return ProductModel.fromJson(data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch product: $e');
    }
  }

  @override
  Future<OrderModel> placeOrder(OrderModel order) async {
    try {
      final body = {
        'productId': order.productId,
        'quantity':  order.quantity,
        if (order.notes != null && order.notes!.isNotEmpty) 'notes': order.notes,
        if (order.location.isNotEmpty) 'location': order.location,
      };
      final data = await _api.post(ApiConstants.placeOrder, body);
      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to place order: $e');
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders(String buyerId) async {
    try {
      final data = await _api.get(ApiConstants.myOrders) as List<dynamic>;
      return data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch orders: $e');
    }
  }

  @override
  Future<List<OrderModel>> getIncomingOrders(String sellerId) async {
    try {
      final data = await _api.get(ApiConstants.incomingOrders) as List<dynamic>;
      return data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch incoming orders: $e');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final data = await _api.put(
        ApiConstants.orderStatus(orderId),
        {'status': status},
      );
      return OrderModel.fromJson(data as Map<String, dynamic>);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update order status: $e');
    }
  }
}
