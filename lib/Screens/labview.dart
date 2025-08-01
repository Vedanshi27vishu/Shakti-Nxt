import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LoanWebViewScreen extends StatelessWidget {
  final String url;
  final String title;

  const LoanWebViewScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    final WebViewController controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            if (request.url.startsWith('http') ||
                request.url.startsWith('https')) {
              return NavigationDecision.navigate;
            } else {
              // Show dialog to open in browser
              final shouldLaunch = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Open in Browser'),
                  content:
                      Text('This link cannot be opened here:\n${request.url}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Open'),
                    ),
                  ],
                ),
              );

              if (shouldLaunch == true) {
                if (await canLaunchUrl(Uri.parse(request.url))) {
                  await launchUrl(Uri.parse(request.url),
                      mode: LaunchMode.externalApplication);
                }
              }
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
