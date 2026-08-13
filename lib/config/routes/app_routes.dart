import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:montajat_customer_app/config/routes/routes.dart';
import 'package:montajat_customer_app/core/services/cache_helper.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/utils/constant_keys.dart';
import 'package:montajat_customer_app/features/categories/logic/categories_cubit.dart';
import 'package:montajat_customer_app/features/categories/data/repositories/categories_repository.dart';
import 'package:montajat_customer_app/features/categories/ui/categories_screen.dart';
import 'package:montajat_customer_app/features/language_selection/data/repositories/language_repository.dart';
import 'package:montajat_customer_app/features/language_selection/logic/language_selection_cubit.dart';
import 'package:montajat_customer_app/features/language_selection/ui/language_selection_screen.dart';
import 'package:montajat_customer_app/features/home/logic/home_cubit.dart';
import 'package:montajat_customer_app/features/home/data/repositories/home_repository.dart';
import 'package:montajat_customer_app/features/home/ui/home_screen.dart';
import 'package:montajat_customer_app/features/home/ui/brands_screen.dart';
import 'package:montajat_customer_app/features/home/ui/offer_products_screen.dart';
import 'package:montajat_customer_app/features/home/ui/offers_screen.dart';
import 'package:montajat_customer_app/features/login/logic/login_cubit.dart';
import 'package:montajat_customer_app/features/login/data/repositories/auth_repository.dart';
import 'package:montajat_customer_app/features/login/ui/login_screen.dart';
import 'package:montajat_customer_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:montajat_customer_app/features/onboarding/logic/onboarding_cubit.dart';
import 'package:montajat_customer_app/features/onboarding/ui/onboarding_screen.dart';
import 'package:montajat_customer_app/features/products/data/models/products_screen_arguments.dart';
import 'package:montajat_customer_app/features/products/data/models/product_details_arguments.dart';
import 'package:montajat_customer_app/features/products/data/repositories/product_details_repository.dart';
import 'package:montajat_customer_app/features/products/logic/product_details_cubit.dart';
import 'package:montajat_customer_app/features/products/logic/products_cubit.dart';
import 'package:montajat_customer_app/features/products/ui/product_details_screen.dart';
import 'package:montajat_customer_app/features/products/data/repositories/products_repository.dart';
import 'package:montajat_customer_app/features/products/ui/products_screen.dart';
import 'package:montajat_customer_app/features/profile/ui/profile_screen.dart';
import 'package:montajat_customer_app/features/profile/ui/profile_details_screen.dart';
import 'package:montajat_customer_app/features/profile/data/repositories/profile_repository.dart';
import 'package:montajat_customer_app/features/profile/data/models/profile_model.dart';
import 'package:montajat_customer_app/features/profile/logic/profile_cubit.dart';
import 'package:montajat_customer_app/features/addresses/data/repositories/addresses_repository.dart';
import 'package:montajat_customer_app/features/addresses/logic/addresses_cubit.dart';
import 'package:montajat_customer_app/features/addresses/logic/address_details_cubit.dart';
import 'package:montajat_customer_app/features/addresses/ui/addresses_screen.dart';
import 'package:montajat_customer_app/features/addresses/ui/address_details_screen.dart';
import 'package:montajat_customer_app/features/splash/logic/splash_cubit.dart';
import 'package:montajat_customer_app/features/splash/ui/splash_screen.dart';
import 'package:montajat_customer_app/features/verification/logic/verification_cubit.dart';
import 'package:montajat_customer_app/features/verification/ui/verification_screen.dart';
import 'package:montajat_customer_app/features/cart/data/repositories/cart_repository.dart';
import 'package:montajat_customer_app/features/cart/logic/cart_cubit.dart';
import 'package:montajat_customer_app/features/cart/ui/cart_screen.dart';
import 'package:montajat_customer_app/features/orders/data/repositories/orders_repository.dart';
import 'package:montajat_customer_app/features/orders/logic/order_details_cubit.dart';
import 'package:montajat_customer_app/features/orders/logic/orders_cubit.dart';
import 'package:montajat_customer_app/features/orders/ui/order_details_screen.dart';
import 'package:montajat_customer_app/features/orders/ui/orders_screen.dart';
import 'package:montajat_customer_app/features/finance/data/repositories/finance_repository.dart';
import 'package:montajat_customer_app/features/finance/logic/finance_cubit.dart';
import 'package:montajat_customer_app/features/finance/ui/finance_screen.dart';
import 'package:montajat_customer_app/features/finance/ui/finance_invoice_details_screen.dart';

abstract final class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => _createSplashCubit()..start(),
            child: const SplashScreen(),
          ),
        );
      case Routes.languageSelection:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => LanguageSelectionCubit(const LanguageRepository()),
            child: const LanguageSelectionScreen(),
          ),
        );
      case Routes.onboarding:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => OnboardingCubit(const OnboardingRepository()),
            child: const OnboardingScreen(),
          ),
        );
      case Routes.login:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => LoginCubit(getIt<AuthRepository>()),
            child: const LoginScreen(),
          ),
        );
      case Routes.verification:
        final phoneNumber = settings.arguments as String? ?? '';
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                VerificationCubit(getIt<AuthRepository>())..startTimer(),
            child: VerificationScreen(phoneNumber: phoneNumber),
          ),
        );
      case Routes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => HomeCubit(getIt<HomeRepository>())..loadHome(),
            child: const HomeScreen(),
          ),
        );
      case Routes.categories:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                CategoriesCubit(getIt<CategoriesRepository>())
                  ..loadCategories(),
            child: CategoriesScreen(standalone: settings.arguments == true),
          ),
        );
      case Routes.offerProducts:
        final arguments = settings.arguments as OfferProductsArguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => OfferProductsScreen(arguments: arguments),
        );
      case Routes.offers:
        final arguments = settings.arguments as OffersScreenArguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => OffersScreen(arguments: arguments),
        );
      case Routes.brands:
        final arguments = settings.arguments as BrandsScreenArguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BrandsScreen(arguments: arguments),
        );
      case Routes.products:
        final arguments = settings.arguments as ProductsScreenArguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                ProductsCubit(getIt<ProductsRepository>(), arguments)
                  ..loadProducts(),
            child: ProductsScreen(arguments: arguments),
          ),
        );
      case Routes.productDetails:
        final arguments = settings.arguments as ProductDetailsArguments;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => ProductDetailsCubit(
              getIt<ProductDetailsRepository>(),
              getIt<ProductsRepository>(),
              arguments.itemCode,
            )..loadDetails(),
            child: ProductDetailsScreen(arguments: arguments),
          ),
        );
      case Routes.profile:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => ProfileCubit(
              getIt<ProfileRepository>(),
              getIt<AuthRepository>(),
            )..loadProfile(),
            child: const ProfileScreen(),
          ),
        );
      case Routes.profileDetails:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              ProfileDetailsScreen(profile: settings.arguments as ProfileModel),
        );
      case Routes.creditDetails:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => CreditDetailsScreen(
            credit: (settings.arguments as ProfileModel).credit,
          ),
        );
      case Routes.finance:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => FinanceCubit(getIt<FinanceRepository>())..load(),
            child: const FinanceScreen(),
          ),
        );
      case Routes.financeInvoiceDetails:
        final docNum = settings.arguments as String;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                InvoiceDetailsCubit(getIt<FinanceRepository>(), docNum)..load(),
            child: FinanceInvoiceDetailsScreen(docNum: docNum),
          ),
        );
      case Routes.addresses:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                AddressesCubit(getIt<AddressesRepository>())..loadAddresses(),
            child: const AddressesScreen(),
          ),
        );
      case Routes.addressDetails:
        final addressId = settings.arguments as int;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                AddressDetailsCubit(getIt<AddressesRepository>(), addressId)
                  ..load(),
            child: const AddressDetailsScreen(),
          ),
        );
      case Routes.cart:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                CartCubit(getIt<CartRepository>(), getIt<OrdersRepository>())
                  ..loadCart(),
            child: const CartScreen(),
          ),
        );
      case Routes.orders:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => OrdersCubit(getIt<OrdersRepository>())..loadOrders(),
            child: const OrdersScreen(),
          ),
        );
      case Routes.orderDetails:
        final orderNumber = settings.arguments as String;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) =>
                OrderDetailsCubit(getIt<OrdersRepository>(), orderNumber)
                  ..loadOrder(),
            child: OrderDetailsScreen(orderNumber: orderNumber),
          ),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => _createSplashCubit()..start(),
            child: const SplashScreen(),
          ),
        );
    }
  }

  static SplashCubit _createSplashCubit() {
    final hasSelectedLanguage =
        CacheHelper.getString(ConstantKeys.selectedLanguageCode) != null;
    final hasCompletedOnboarding = const OnboardingRepository().isCompleted;

    return SplashCubit(
      shouldOpenLanguageSelection: !hasSelectedLanguage,
      shouldOpenOnboarding: hasSelectedLanguage && !hasCompletedOnboarding,
      shouldOpenLogin: hasSelectedLanguage && hasCompletedOnboarding,
      hasActiveSession: getIt<AuthRepository>().hasActiveSession,
    );
  }
}
