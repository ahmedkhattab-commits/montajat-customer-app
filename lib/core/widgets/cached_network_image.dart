import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CachedNetworkImageWidget extends StatelessWidget {
  final String imgUrl;
  final BorderRadius radius;
  final BoxFit? fit;

  const CachedNetworkImageWidget({
    required this.imgUrl,
    required this.radius,
    this.fit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        fit: fit ?? BoxFit.cover,
        imageUrl: imgUrl,
        placeholder: (context, url) => loadingWidget(),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      ),
    );
  }

  Widget loadingWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withValues(alpha: .8),
      highlightColor: Colors.grey.withValues(alpha: .4),
      period: const Duration(seconds: 1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .6),
          borderRadius: radius,
        ),
      ),
    );
  }
}
