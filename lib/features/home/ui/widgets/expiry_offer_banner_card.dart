import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/utils/assets_manager.dart';
import 'package:montajat_customer_app/features/home/data/models/home_response_model.dart';
import 'package:montajat_customer_app/features/home/ui/offer_products_screen.dart';

class ExpiryOfferBannerCard extends StatelessWidget {
  const ExpiryOfferBannerCard({
    required this.offer,
    required this.index,
    this.keyPrefix = 'expiry-offer',
    super.key,
  });

  final HomeExpiryOfferModel offer;
  final int index;
  final String keyPrefix;

  static const _fallbackAssets = [
    ImageAsset.homeCatFoodOffer,
    ImageAsset.homePetServicesOffer,
    ImageAsset.homeFineCareOffer,
  ];

  @override
  Widget build(BuildContext context) {
    final fallbackAsset = _fallbackAssets[index % _fallbackAssets.length];
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('$keyPrefix-${offer.offerId}'),
        onTap: () => Navigator.of(context).pushNamed(
          Routes.offerProducts,
          arguments: OfferProductsArguments(
            offer: offer,
            imageAsset: fallbackAsset,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 380 / 102,
          child: offer.imageUrl == null
              ? Image.asset(fallbackAsset, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: offer.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) =>
                      const ColoredBox(color: Color(0xFFF3F3F3)),
                  errorWidget: (_, _, _) =>
                      Image.asset(fallbackAsset, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}
