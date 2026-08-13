import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/ui/offer_products_screen.dart';

class ExpiryOfferBannerCard extends StatelessWidget {
  const ExpiryOfferBannerCard({
    required this.offer,
    this.keyPrefix = 'expiry-offer',
    super.key,
  });

  final HomeExpiryOfferModel offer;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('$keyPrefix-${offer.offerId}'),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.offerProducts,
          arguments: OfferProductsArguments(offer: offer),
        ),
        child: AspectRatio(
          aspectRatio: 380 / 102,
          child: offer.imageUrl == null || offer.imageUrl!.trim().isEmpty
              ? const _OfferImagePlaceholder()
              : CachedNetworkImage(
                  imageUrl: offer.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: Color(0xFFF3F3F3)),
                  errorWidget: (_, _, _) => const _OfferImagePlaceholder(),
                ),
        ),
      ),
    );
  }
}

class _OfferImagePlaceholder extends StatelessWidget {
  const _OfferImagePlaceholder();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: Color(0xFFF3F3F3),
    child: Center(
      child: Icon(Icons.image_not_supported_outlined, color: Color(0xFFBDBDBD)),
    ),
  );
}
