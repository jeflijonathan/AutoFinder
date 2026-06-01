import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FullScreenMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String title;

  const FullScreenMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
  });

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final htmlContent = '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
          body { margin: 0; padding: 0; }
          iframe { border: 0; width: 100%; height: 100vh; }
        </style>
      </head>
      <body>
        <iframe src="https://maps.google.com/maps?q=${widget.latitude},${widget.longitude}&hl=en&z=15&output=embed" allowfullscreen></iframe>
      </body>
    </html>
    ''';
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
