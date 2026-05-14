import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';

enum BugReport {
  beatMusic('Lỗi beat nhạc'),
  app('Lỗi ứng dụng'),
  security('Lỗi bảo mật'),
  other('Khác');

  final String label;
  const BugReport(this.label);
}

class ReportErrorScreen extends StatelessWidget {
  const ReportErrorScreen({super.key});

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
          'Báo cáo lỗi',
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
        child: _MultiSelect(),
      ),
    );
  }
}

class _MultiSelect extends StatefulWidget {
  const _MultiSelect();

  @override
  State<_MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<_MultiSelect> {
  BugReport? _selected;
  String? _errorMessage;
  final TextEditingController _controller = TextEditingController();
  final int _maxLength = 200;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    setState(() {
      _errorMessage = message;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  void _submit() {
    if (_selected == null) {
      _showMessage('Vui lòng chọn loại lỗi');
      return;
    }

    if (_selected == BugReport.other && _controller.text.trim().isEmpty) {
      _showMessage('Vui lòng nhập mô tả');
      return;
    }

    _showMessage('Gửi thành công');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.of(context).padding.top,
        12,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioGroup<BugReport>(
            groupValue: _selected,
            onChanged: (val) => setState(() => _selected = val),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: BugReport.values
                  .map(
                    (type) => RadioListTile<BugReport>(
                      value: type,
                      title: Text(
                        type.label,
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppColors.whiteBackground),
                      ),
                      activeColor: Colors.blue,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Mô tả chi tiết',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, value, _) {
                  return TextField(
                    controller: _controller,
                    maxLength: _maxLength,
                    maxLines: 5,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung...',
                      hintStyle: TextStyle(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.whiteBackground.withValues(
                        alpha: 0.2,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 15,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 13,
                bottom: 12,
                child: ValueListenableBuilder(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    return Text(
                      '${value.text.length}/$_maxLength',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonInsideLesson,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Gửi',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Roboto'
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
