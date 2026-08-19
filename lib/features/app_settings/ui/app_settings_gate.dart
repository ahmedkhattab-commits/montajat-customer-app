import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:montajat_customer_app/config/themes/app_white_theme.dart';
import 'package:montajat_customer_app/core/services/services_locator.dart';
import 'package:montajat_customer_app/core/utils/app_colors_white_theme.dart';
import 'package:montajat_customer_app/features/app_settings/data/models/app_settings_model.dart';
import 'package:montajat_customer_app/features/app_settings/data/repositories/app_settings_repository.dart';

class AppSettingsGate extends StatefulWidget {
  const AppSettingsGate({required this.child, super.key});

  final Widget child;

  @override
  State<AppSettingsGate> createState() => _AppSettingsGateState();
}

class _AppSettingsGateState extends State<AppSettingsGate> {
  late Future<AppSettingsModel> _settings;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _settings = getIt<AppSettingsRepository>().getSettings();
  }

  void _retry() => setState(_load);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSettingsModel>(
      future: _settings,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _shell(const Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return _shell(_StartupError(onRetry: _retry));
        }
        final settings = snapshot.requireData;
        if (settings.blocksApp) {
          return _shell(_BlockingScreen(settings: settings));
        }
        return widget.child;
      },
    );
  }

  Widget _shell(Widget home) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appWhiteTheme(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: home,
    );
  }
}

class _BlockingScreen extends StatelessWidget {
  const _BlockingScreen({required this.settings});

  final AppSettingsModel settings;

  @override
  Widget build(BuildContext context) {
    final imageUrl = settings.imageUrl;
    final isEnglish = context.locale.languageCode == 'en';
    final message = isEnglish
        ? settings.messageEn ?? settings.message
        : settings.message ?? settings.messageEn;
    return Scaffold(
      backgroundColor: Colors.white,
      body: imageUrl != null
          ? SizedBox.expand(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) => _BlockingMessage(message: message),
              ),
            )
          : _BlockingMessage(message: message),
    );
  }
}

class _BlockingMessage extends StatelessWidget {
  const _BlockingMessage({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? context.tr('app_settings.unavailable'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 52),
              const SizedBox(height: 16),
              Text(
                context.tr('app_settings.load_failed'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onRetry,
                child: Text(context.tr('app_settings.retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
