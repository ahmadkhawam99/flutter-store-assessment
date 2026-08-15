import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class CartFloatingButtonController {
  VoidCallback? _pulse;

  void pulse() => _pulse?.call();

  void _attach(VoidCallback pulse) => _pulse = pulse;

  void _detach(VoidCallback pulse) {
    if (_pulse == pulse) _pulse = null;
  }
}

class CartFloatingButton extends StatefulWidget {
  const CartFloatingButton({
    required this.totalQuantity,
    required this.onPressed,
    required this.targetKey,
    this.controller,
    super.key,
  });

  final int totalQuantity;
  final VoidCallback onPressed;
  final GlobalKey targetKey;
  final CartFloatingButtonController? controller;

  @override
  State<CartFloatingButton> createState() => _CartFloatingButtonState();
}

class _CartFloatingButtonState extends State<CartFloatingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 210),
    );
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 55,
      ),
    ]).animate(_pulseController);
    widget.controller?._attach(_pulse);
  }

  @override
  void didUpdateWidget(CartFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(_pulse);
      widget.controller?._attach(_pulse);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(_pulse);
    _pulseController.dispose();
    super.dispose();
  }

  void _pulse() {
    if (!mounted || widget.totalQuantity <= 0) return;
    _pulseController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      key: widget.targetKey,
      dimension: 68.r,
      child: IgnorePointer(
        ignoring: widget.totalQuantity <= 0,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.75, end: 1).animate(animation),
              child: child,
            ),
          ),
          child: widget.totalQuantity <= 0
              ? const SizedBox.shrink(key: ValueKey('cart-floating-hidden'))
              : ScaleTransition(
                  key: const ValueKey('cart-floating-visible'),
                  scale: _pulseAnimation,
                  child: _CartControl(
                    totalQuantity: widget.totalQuantity,
                    onPressed: widget.onPressed,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CartControl extends StatelessWidget {
  const _CartControl({required this.totalQuantity, required this.onPressed});

  final int totalQuantity;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = totalQuantity > 99 ? '99+' : '$totalQuantity';

    return Semantics(
      key: const ValueKey('cart-floating-control'),
      button: true,
      label: 'Open cart, $totalQuantity items',
      child: SizedBox.square(
        dimension: 68.r,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            PositionedDirectional(
              start: 3.r,
              bottom: 3.r,
              child: Material(
                color: AppColors.primary,
                elevation: 7,
                shadowColor: AppColors.primary.withValues(alpha: 0.34),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onPressed,
                  child: SizedBox.square(
                    dimension: 58.r,
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      key: const ValueKey('cart-floating-icon'),
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: IgnorePointer(
                child: Container(
                  key: const ValueKey('cart-floating-badge'),
                  width: 25.r,
                  height: 25.r,
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      badgeLabel,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
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
}
