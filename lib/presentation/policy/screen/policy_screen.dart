import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  static const _policies = [
    _PolicyItem(
      outsideTitle: 'Chính sách xử lý vi phạm',
      insideTitle: 'CHÍNH SÁCH XỬ LÝ VI PHẠM',
      url: 'https://www.ikara.co/news/chinh-sach-xu-ly-vi-pham/',
    ),
    _PolicyItem(
      outsideTitle: 'Chiết khấu iCoin',
      insideTitle: 'CHÍNH SÁCH ƯU ĐÃI KHI NẠP ICOIN',
      url: 'https://www.ikara.co/news/2753/',
    ),
    _PolicyItem(
      outsideTitle: 'Quy chế chuyển iCoin',
      insideTitle: 'QUY CHẾ CHUYỂN ICOIN',
      url: 'https://www.ikara.co/news/quy-che-chuyen-icoin/',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.whiteBackground),
        ),
        title: Text(
          'Chính sách',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.firstMainBackground,
              AppColors.secMainBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            itemBuilder: (context, index) {
              final policy = _policies[index];
              return ListTile(
                onTap: () => context.push('/policy-detail', extra: {
                  'insideTitle' : policy.insideTitle,
                  'url' : policy.url
                }),
                title: Text(
                  policy.outsideTitle,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => Divider(color: AppColors.whiteLine),
            itemCount: _policies.length,
          ),
        ),
      ),
    );
  }
}

class _PolicyItem {
  final String outsideTitle;
  final String insideTitle;
  final String url;
  const _PolicyItem({
    required this.outsideTitle,
    required this.insideTitle,
    required this.url,
  });
}
