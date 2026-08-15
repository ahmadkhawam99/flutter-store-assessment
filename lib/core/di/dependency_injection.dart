import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/restore_session_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/login_bloc/login_bloc.dart';
import '../../features/auth/presentation/bloc/sign_up_bloc/sign_up_bloc.dart';
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/i_cart_repository.dart';
import '../../features/cart/domain/usecases/add_to_cart_usecase.dart';
import '../../features/cart/domain/usecases/get_cart_usecase.dart';
import '../../features/cart/domain/usecases/remove_from_cart_usecase.dart';
import '../../features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import '../../features/cart/presentation/bloc/cart_bloc/cart_bloc.dart';
import '../../features/products/data/datasources/products_remote_data_source.dart';
import '../../features/products/data/repositories/products_repository_impl.dart';
import '../../features/products/domain/repositories/i_products_repository.dart';
import '../../features/products/domain/usecases/get_product_categories_usecase.dart';
import '../../features/products/domain/usecases/get_product_details_usecase.dart';
import '../../features/products/domain/usecases/get_products_by_category_usecase.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/presentation/bloc/product_details_bloc/product_details_bloc.dart';
import '../../features/products/presentation/bloc/products_bloc/products_bloc.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(ApiClient.createDio);
  }
  if (!getIt.isRegistered<SharedPreferences>()) {
    final preferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(preferences);
  }
  getIt
    ..registerLazySingleton<IAuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<IAuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton(() => LoginUseCase(getIt()))
    ..registerLazySingleton(() => SignUpUseCase(getIt()))
    ..registerLazySingleton(() => RestoreSessionUseCase(getIt()))
    ..registerLazySingleton(() => LogoutUseCase(getIt()))
    ..registerFactory(() => LoginBloc(getIt()))
    ..registerFactory(() => SignUpBloc(getIt()))
    ..registerLazySingleton(() => AuthBloc(getIt(), getIt()))
    ..registerLazySingleton<IProductsRemoteDataSource>(
      () => ProductsRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<IProductsRepository>(
      () => ProductsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton(() => GetProductsUseCase(getIt()))
    ..registerLazySingleton(() => GetProductDetailsUseCase(getIt()))
    ..registerLazySingleton(() => GetProductCategoriesUseCase(getIt()))
    ..registerLazySingleton(() => GetProductsByCategoryUseCase(getIt()))
    ..registerFactory(() => ProductsBloc(getIt(), getIt(), getIt()))
    ..registerFactory(() => ProductDetailsBloc(getIt()));
  getIt
    ..registerLazySingleton<ICartLocalDataSource>(
      () => CartLocalDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ICartRepository>(() => CartRepositoryImpl(getIt()))
    ..registerLazySingleton(() => GetCartUseCase(getIt()))
    ..registerLazySingleton(() => AddToCartUseCase(getIt()))
    ..registerLazySingleton(() => UpdateCartQuantityUseCase(getIt()))
    ..registerLazySingleton(() => RemoveFromCartUseCase(getIt()))
    ..registerFactory(() => CartBloc(getIt(), getIt(), getIt(), getIt()));
}
