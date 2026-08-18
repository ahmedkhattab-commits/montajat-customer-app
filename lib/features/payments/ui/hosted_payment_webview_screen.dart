import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HostedPaymentWebViewScreen extends StatefulWidget {
  const HostedPaymentWebViewScreen({required this.paymentUrl, super.key});

  final String paymentUrl;

  @override
  State<HostedPaymentWebViewScreen> createState() =>
      _HostedPaymentWebViewScreenState();
}

class _HostedPaymentWebViewScreenState
    extends State<HostedPaymentWebViewScreen> {
  late final WebViewController _controller;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: _handleNavigation,
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return NavigationDecision.navigate;
    }
    if ((uri.scheme == 'montajat' || uri.scheme == 'muntajat') &&
        uri.host == 'payments' &&
        uri.pathSegments.isNotEmpty) {
      Navigator.of(context).pop(uri.pathSegments.last);
    }
    return NavigationDecision.prevent;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
    body: Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading) const Center(child: CircularProgressIndicator()),
      ],
    ),
  );
}
