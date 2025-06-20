// FlexDocs Widget for FlutterFlow
// Copy this entire file into your FlutterFlow custom code

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class FlexDocsWidget extends StatefulWidget {
  final String siteUrl;
  final String apiKey;
  
  const FlexDocsWidget({
    Key? key,
    this.siteUrl = 'https://your-flexdocs-site.netlify.app',
    this.apiKey = 'demo-key-123',
  }) : super(key: key);
  
  @override
  State<FlexDocsWidget> createState() => _FlexDocsWidgetState();
}

class _FlexDocsWidgetState extends State<FlexDocsWidget> {
  late final WebViewController controller;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0A0A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() => isLoading = false);
            }
          },
          onPageStarted: (String url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.siteUrl));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('FlexDocs - Context Manager'),
        backgroundColor: const Color(0xFF1A1A1A),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.reload(),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openInBrowser(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667EEA),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSyncDialog,
        label: const Text('Sync Files'),
        icon: const Icon(Icons.sync),
        backgroundColor: const Color(0xFF667EEA),
      ),
    );
  }
  
  void _openInBrowser() async {
    final uri = Uri.parse(widget.siteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  
  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Sync Instructions',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Download the sync script from the website',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              '2. Place it in your project root folder',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              '3. Double-click to pull files from cloud',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            const Text(
              '4. Run with "push" to upload changes',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                'API Key: ${widget.apiKey}',
                style: const TextStyle(
                  color: Color(0xFF667EEA),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// FlutterFlow Custom Action
Future<void> openFlexDocs(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FlexDocsWidget(
        siteUrl: 'https://your-flexdocs-site.netlify.app',
        apiKey: 'demo-key-123',
      ),
    ),
  );
}

// Alternative: Floating button overlay
class FlexDocsFloatingButton extends StatelessWidget {
  final Widget child;
  final String siteUrl;
  final String apiKey;
  
  const FlexDocsFloatingButton({
    Key? key,
    required this.child,
    this.siteUrl = 'https://your-flexdocs-site.netlify.app',
    this.apiKey = 'demo-key-123',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF667EEA),
            child: const Icon(Icons.description, size: 20),
            onPressed: () => openFlexDocs(context),
          ),
        ),
      ],
    );
  }
}