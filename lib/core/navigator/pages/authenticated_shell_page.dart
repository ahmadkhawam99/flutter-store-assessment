import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../features/cart/presentation/bloc/cart_bloc/cart_bloc.dart';
import '../../../features/cart/presentation/widgets/cart_add_feedback.dart';
import '../../../features/cart/presentation/widgets/cart_floating_button.dart';
import '../../di/dependency_injection.dart';
import '../../widgets/image/app_image.dart';
import '../routes.dart';

class AuthenticatedShellPage extends StatelessWidget {
  const AuthenticatedShellPage({
    required this.currentRouteName,
    required this.child,
    super.key,
  });

  final String? currentRouteName;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CartBloc>()..add(const LoadCartEvent()),
      child: _AuthenticatedShellContent(
        currentRouteName: currentRouteName,
        child: child,
      ),
    );
  }
}

class _AuthenticatedShellContent extends StatefulWidget {
  const _AuthenticatedShellContent({
    required this.currentRouteName,
    required this.child,
  });

  final String? currentRouteName;
  final Widget child;

  @override
  State<_AuthenticatedShellContent> createState() =>
      _AuthenticatedShellContentState();
}

class _AuthenticatedShellContentState
    extends State<_AuthenticatedShellContent> {
  final _feedbackController = CartAddFeedbackController();
  final _floatingController = CartFloatingButtonController();
  final _cartTargetKey = GlobalKey();
  final _activeEntries = <OverlayEntry>{};

  @override
  void dispose() {
    _feedbackController.clear();
    for (final entry in _activeEntries.toList(growable: false)) {
      if (entry.mounted) entry.remove();
    }
    _activeEntries.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hideFloatingCart =
        widget.currentRouteName == AppRoutes.homeName ||
        widget.currentRouteName == AppRoutes.cartName;
    final isProductDetails =
        widget.currentRouteName == AppRoutes.productDetailsName;
    final isProfile = widget.currentRouteName == AppRoutes.profileName;
    final detailsControlsAreStacked =
        MediaQuery.sizeOf(context).width < 556 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.25;
    final bottomMargin = isProductDetails
        ? (detailsControlsAreStacked ? 154.h : 108.h)
        : isProfile
        ? 32.h
        : 18.h;

    return CartAddFeedbackScope(
      controller: _feedbackController,
      child: BlocListener<CartBloc, CartState>(
        listenWhen: (previous, current) {
          if (current is CartFailure) return previous != current;
          final previousQuantity = _cartQuantity(previous);
          final currentQuantity = _cartQuantity(current);
          return previousQuantity != null &&
              currentQuantity != null &&
              currentQuantity > previousQuantity;
        },
        listener: _onCartStateChanged,
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            Positioned.fill(
              child: SafeArea(
                top: false,
                minimum: EdgeInsetsDirectional.only(
                  end: 18.w,
                  bottom: bottomMargin,
                ).resolve(Directionality.of(context)),
                child: Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: BlocSelector<CartBloc, CartState, int>(
                    selector: (state) => switch (state) {
                      CartLoaded() => state.totalQuantity,
                      CartFailure() => state.totalQuantity,
                      _ => 0,
                    },
                    builder: (context, totalQuantity) => CartFloatingButton(
                      totalQuantity: hideFloatingCart ? 0 : totalQuantity,
                      targetKey: _cartTargetKey,
                      controller: _floatingController,
                      onPressed: () => context.pushNamed(AppRoutes.cartName),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _cartQuantity(CartState state) => switch (state) {
    CartLoaded(:final totalQuantity) => totalQuantity,
    CartFailure(:final totalQuantity) => totalQuantity,
    _ => null,
  };

  void _onCartStateChanged(BuildContext context, CartState state) {
    if (state is CartFailure) {
      _feedbackController.clear();
      if (widget.currentRouteName != AppRoutes.cartName) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(state.message),
            ),
          );
      }
      return;
    }

    if (state is! CartLoaded) return;
    final request = _feedbackController.takeNextFlight();
    if (request == null) return;
    _scheduleFlight(request);
  }

  void _scheduleFlight(CartFlyRequest request, [int attempt = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final targetContext = _cartTargetKey.currentContext;
      final targetBox = targetContext?.findRenderObject();
      if (targetBox is! RenderBox ||
          !targetBox.attached ||
          !targetBox.hasSize) {
        if (attempt < 3) _scheduleFlight(request, attempt + 1);
        return;
      }

      final overlay = Overlay.of(context, rootOverlay: true);
      final overlayBox = overlay.context.findRenderObject();
      if (overlayBox is! RenderBox || !overlayBox.hasSize) return;

      final targetTopLeft = targetBox.localToGlobal(Offset.zero);
      final targetCenter = targetTopLeft + targetBox.size.center(Offset.zero);
      final start = overlayBox.globalToLocal(request.sourceRect.center);
      final end = overlayBox.globalToLocal(targetCenter);
      _insertFlight(
        overlay: overlay,
        start: start,
        end: end,
        imageUrl: request.imageUrl,
      );
    });
  }

  void _insertFlight({
    required OverlayState overlay,
    required Offset start,
    required Offset end,
    required String imageUrl,
  }) {
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CartFlyThumbnail(
        start: start,
        end: end,
        imageUrl: imageUrl,
        onCompleted: () {
          if (entry.mounted) entry.remove();
          _activeEntries.remove(entry);
          if (mounted) _floatingController.pulse();
        },
      ),
    );
    _activeEntries.add(entry);
    overlay.insert(entry);
  }
}

class _CartFlyThumbnail extends StatefulWidget {
  const _CartFlyThumbnail({
    required this.start,
    required this.end,
    required this.imageUrl,
    required this.onCompleted,
  });

  final Offset start;
  final Offset end;
  final String imageUrl;
  final VoidCallback onCompleted;

  @override
  State<_CartFlyThumbnail> createState() => _CartFlyThumbnailState();
}

class _CartFlyThumbnailState extends State<_CartFlyThumbnail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 520),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) widget.onCompleted();
        });
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _fade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.66, 1, curve: Curves.easeIn),
      ),
    );
    _scale = Tween<double>(begin: 1, end: 0.32).animate(_curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = 52.r;
    final path = MaterialPointArcTween(
      begin: widget.start - Offset(size / 2, size / 2),
      end: widget.end - Offset(size / 2, size / 2),
    );

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final position = path.evaluate(_curve);
                return Positioned(
                  left: position.dx,
                  top: position.dy,
                  width: size,
                  height: size,
                  child: Opacity(
                    opacity: _fade.value,
                    child: Transform.scale(scale: _scale.value, child: child),
                  ),
                );
              },
              child: DecoratedBox(
                key: const ValueKey('fly-to-cart-overlay'),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10.r,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(7.r),
                  child: AppImage(
                    networkUrl: widget.imageUrl,
                    fit: BoxFit.contain,
                    debugLabel: 'Cart animation product',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
