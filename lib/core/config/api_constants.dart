abstract final class ApiConstants {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://fakestoreapi.com',
  );
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);

  static const productsPath = '/products';
  static const productCategoriesPath = '/products/categories';

  static String productDetailsPath(int productId) => '/products/$productId';

  static String productsByCategoryPath(String category) =>
      Uri(pathSegments: ['', 'products', 'category', category]).toString();
}
