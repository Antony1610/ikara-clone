import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyDetailScreen extends StatefulWidget {
  final String title;
  final String url;
  const PolicyDetailScreen({super.key, required this.title, required this.url});

  @override
  State<PolicyDetailScreen> createState() => _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends State<PolicyDetailScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back_ios)),
        title: Text(widget.title, style: TextStyle(fontSize: 14, fontFamily: 'Roboto'),),
        backgroundColor: AppColors.whiteBackground,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.buttonInsideLesson,),
            )
        ],
      ),
    );
  }
}
