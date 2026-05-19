import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/base/blocs/auth/auth_bloc.dart';
import 'package:ikara_clone/constants/constants.dart';

class CancelAccountScreen extends StatefulWidget {
  const CancelAccountScreen({super.key});

  @override
  State<CancelAccountScreen> createState() => _CancelAccountScreenState();
}

class _CancelAccountScreenState extends State<CancelAccountScreen> {
  final List<bool> _checked = [false, false, false, false, false];
  bool get _allChecked => _checked.every((c) => c);
  bool _showConfirmStep = false;
  final List<String> _title = [
    'Từ bỏ quyền, lợi ích và tài sản',
    'Từ bỏ các tác phẩm và danh tính',
    'Tách tài khoản khỏi các ứng dụng, trang web khác',
    'Trong thời hạn 30 ngày kể từ ngày hủy, nếu bạn đăng nhập bằng tài khoản này, việc hủy tài khoản sẽ tự động vô hiệu hóa',
    'Bạn là người chịu hoàn toàn trách nhiệm về những hậu quả xảy ra từ việc hủy tài khoản',
  ];

  final List<String> _subTitle = [
    'Bạn đã sử dụng các quyền, lợi ích và tài sản liên quan đến tài khoản (iCoin, quà tặng, Cup v.v...). Khi bạn yêu cầu hủy tài khoản, tất cả những quyền, lợi ích và tài sản trong tài khoản đó được coi là bị từ bỏ.',
    'Hủy tài khoản nghĩa là bạn xác nhận từ bỏ danh tính và nội dung bạn tạo ra bằng tài khoản này bao gồm bài thu, bai thu riêng tư, bài thu nhập, các lượt bình luận, tương tác, VV...',
    'Tài khoản này sẽ bị hủy cấp phép đăng nhập hoặc hủy liên kết với các ứng dụng, trang web có liên quan khác.',
    '',
    '',
  ];

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String displayName = '';
    String? avatarUrl;
    if (authState is AuthAuthenticated) {
      displayName = authState.user.name;
      avatarUrl = authState.user.image;
    }
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryText),
          ),
          title: Text(
            'Hủy tài khoản của tôi',
            style: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: AppColors.insideSetting),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.avatarColor,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? Icon(
                          Icons.person_outline_sharp,
                          size: 40,
                          color: AppColors.hintText,
                        )
                      : null,
                ),
                Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _showConfirmStep
                        ? _ConfirmStep(key: ValueKey('confirm'), onConfirm: () => context.read<AuthBloc>().add(DeleteAccountRequested()),)
                        : _CheckListStep(
                            key: ValueKey('checklists'),
                            title: _title,
                            subtitle: _subTitle,
                            checked: _checked,
                            allChecked: _allChecked,
                            onToggle: (i) => setState(() {
                              _checked[i] = !_checked[i];
                            }),
                      onNext: () => setState(() {
                        _showConfirmStep = true;
                      }),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckListStep extends StatelessWidget {
  final List<String> title;
  final List<String> subtitle;
  final List<bool> checked;
  final bool allChecked;
  final void Function(int) onToggle;
  final VoidCallback onNext;

  const _CheckListStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.allChecked,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Để thực hiện Hủy tài khoản, bạn phải chấp nhận và từ bỏ các nội dung sau:',
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12, fontFamily: 'Roboto', color: AppColors.blackText),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(title.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: _CheckItem(
                        title: title[i],
                        subtitle: i < subtitle.length ? subtitle[i] : '',
                        checked: checked[i],
                        onTap: () => onToggle(i),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: allChecked ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allChecked
                      ? AppColors.buttonInsideLesson
                      : AppColors.unFinishButton,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text('Tiếp theo',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.primaryText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  final VoidCallback onConfirm;
  const _ConfirmStep({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lời nhắc quan trọng',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Trong thời hạn 30 ngày kể từ ngày hủy, nếu bạn đăng nhập bằng tài khoản này, việc hủy tài khoản sẽ tự động vô hiệu hóa.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '*Lưu ý',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Việc hủy tài khoản là hành động không thể hoàn tác, bạn phải tự mình sao lưu thông tin và dữ liệu liên quan đến tài khoản này. Bên cạnh đó, bạn sẽ chịu trách nhiệm cho những hậu quả sau:',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  Text(
                    '- Tất cả thông tin cá nhân và lịch sử trong tài khoản bị hủy là không thể truy xuất được.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  Text(
                    '- Những người liên hệ với bạn sẽ không thể liên lạc với bạn qua tài khoản này.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  Text(
                    '- Mọi quyền, lợi ích và tài sản còn lại chưa được sử dụng hết trong tài khoản này đều sẽ bị vô hiệu hóa và không được hoàn trả tương ứng.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  Text(
                    '- Mọi cấp bậc, điểm, v.v... mà bạn đã tích lũy đều bị vô hiệu hóa và không truy xuất được.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  Text(
                    '- Mọi thông tin tương tác, bài thu, v.v... mà bạn đã tạo ra và tích lũy được trước đó đều bị vô hiệu hóa và không truy xuất được.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  Text(
                    '- Mọi phần thưởng Cup, quà tặng, iCoin, v.v... đều bị vô hiệu hóa',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  Text(
                    '- Mọi thẻ ngân hàng hoặc dịch vụ thanh toán/rút tiền được liên kết với ứng dụng sẽ không sẽ không áp dụng thanh toán/rút tiền đối với tài khoản này.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                  Text(
                    '- Đối với bất kỳ dịch vụ của bên thứ ba khác mà bạn sử dụng cho phép đăng nhập hoặc sử dụng sau khi liên kết tài khoản Yokara Yokara, bạn sẽ không thể đăng nhập, sử dụng lại thông qua tài khoản này, hoặc tiếp tục sử dụng dịch vụ từ các bên thứ ba đó, và mọi bản ghi sẽ không truy xuất được.',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      color: AppColors.blackText,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonInsideLesson,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text('Xác nhận',
                  style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.primaryText),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool checked;
  final VoidCallback onTap;

  const _CheckItem({
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checked
                  ? AppColors.buttonInsideLesson
                  : Colors.transparent,
              border: Border.all(
                color: checked
                    ? AppColors.buttonInsideLesson
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: checked
                ? Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackText,
                    fontFamily: 'Roboto',
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.hintText,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
