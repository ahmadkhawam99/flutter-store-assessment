import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../bloc/product_details_bloc/product_details_bloc.dart';
import '../views/product_details_view.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({required this.productId, super.key});

  final int productId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ProductDetailsBloc>()..add(LoadProductDetailsEvent(productId)),
      child: const ProductDetailsView(),
    );
  }
}
