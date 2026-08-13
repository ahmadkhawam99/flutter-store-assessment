import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/api_constants.dart';
import '../../theme/app_theme.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.networkUrl,
    this.assetPath,
    this.file,
    this.memoryBytes,
    this.color,

    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorIcon = Icons.broken_image,
    this.enableDownscale = true,
    this.debugLabel,
    this.semanticLabel,
  });

  const AppImage.logo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'Store App',
    this.color,
  }) : networkUrl = null,
       assetPath = logoAsset,
       file = null,
       memoryBytes = null,
       errorIcon = Icons.shopping_bag_outlined,
       enableDownscale = true,
       debugLabel = 'store-app-logo';

  static const logoAsset = 'assets/images/logo-with-text.png';

  final String? networkUrl;
  final String? assetPath;
  final File? file;
  final Uint8List? memoryBytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final IconData errorIcon;
  final bool enableDownscale;
  final String? debugLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheSize = _resolveCacheSize(context, constraints);

        if (file != null) {
          return Image.file(
            file!,
            width: width,
            height: height,
            fit: fit,
            semanticLabel: semanticLabel,
            cacheWidth: cacheSize.$1,
            cacheHeight: cacheSize.$2,
            errorBuilder: (_, error, __) => _fallback(error: error),
          );
        }

        if (memoryBytes != null) {
          return Image.memory(
            memoryBytes!,
            width: width,
            height: height,
            fit: fit,
            semanticLabel: semanticLabel,
            cacheWidth: cacheSize.$1,
            cacheHeight: cacheSize.$2,
            errorBuilder: (_, error, __) => _fallback(error: error),
          );
        }

        final asset = assetPath?.trim();
        if (asset != null && asset.isNotEmpty) {
          return Image.asset(
            asset,
            width: width,
            height: height,
            fit: fit,
            color: color,
            semanticLabel: semanticLabel,
            cacheWidth: cacheSize.$1,
            cacheHeight: cacheSize.$2,
            errorBuilder: (_, error, __) =>
                _fallback(error: error, logoAssetFailed: asset == logoAsset),
          );
        }

        final normalizedUrl = _normalizeNetworkUrl(networkUrl);
        if (normalizedUrl != null) {
          return CachedNetworkImage(
            imageUrl: normalizedUrl,
            width: width,
            height: height,
            fit: fit,
            memCacheWidth: cacheSize.$1,
            memCacheHeight: cacheSize.$2,
            maxWidthDiskCache: cacheSize.$1,
            maxHeightDiskCache: cacheSize.$2,
            imageBuilder: (context, provider) => Image(
              image: provider,
              width: width,
              height: height,
              fit: fit,
              semanticLabel: semanticLabel,
            ),
            placeholder: (_, __) => _loading(),
            errorWidget: (_, failedUrl, error) =>
                _fallback(error: error, failedUrl: failedUrl),
          );
        }

        return _fallback(failedUrl: networkUrl);
      },
    );
  }

  String? _normalizeNetworkUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    var normalized = value.trim();
    if (normalized.startsWith('//')) {
      normalized = 'https:$normalized';
    } else if (normalized.startsWith('/')) {
      final baseUri = Uri.parse(ApiConstants.baseUrl);
      normalized = baseUri.resolve(normalized).toString();
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return uri.toString();
  }

  (int?, int?) _resolveCacheSize(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (!enableDownscale) return (null, null);

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final logicalWidth =
        _validDimension(width) ??
        (constraints.hasBoundedWidth ? constraints.maxWidth : null);
    final logicalHeight =
        _validDimension(height) ??
        (constraints.hasBoundedHeight ? constraints.maxHeight : null);

    return (
      _pixelDimension(logicalWidth, pixelRatio),
      _pixelDimension(logicalHeight, pixelRatio),
    );
  }

  double? _validDimension(double? value) {
    if (value == null || !value.isFinite || value <= 0) return null;
    return value;
  }

  int? _pixelDimension(double? value, double pixelRatio) {
    if (value == null || !value.isFinite || value <= 0) return null;
    return (value * pixelRatio).round();
  }

  Widget _loading() {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: SizedBox.square(
          dimension: 24.r,
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _fallback({
    Object? error,
    String? failedUrl,
    bool logoAssetFailed = false,
  }) {
    if (kDebugMode && (error != null || failedUrl != null)) {
      debugPrint(
        '[AppImage] load failed | label=${debugLabel ?? '-'} '
        '| source=${failedUrl ?? assetPath ?? '-'} | error=${error ?? '-'}',
      );
    }

    if (logoAssetFailed) return _fallbackIcon();

    return Image.asset(
      logoAsset,
      width: width,
      height: height,
      fit: BoxFit.contain,
      semanticLabel: 'Store App',
      errorBuilder: (_, __, ___) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Icon(errorIcon, size: 32.r, color: AppColors.primary),
      ),
    );
  }
}
