import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agremate_admin/modules/auth/controller/auth_controller.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';

TextStyle _p(double size, {FontWeight w = FontWeight.w400, Color? color, double? height}) =>
    GoogleFonts.poppins(fontSize: size, fontWeight: w, color: color, height: height);

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController auth = Get.find<AuthController>();
  final _phoneController = TextEditingController();

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpNodes;
  Worker? _otpSentWorker;

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _otpControllers =
        List.generate(AuthController.otpLength, (_) => TextEditingController());
    _otpNodes = List.generate(AuthController.otpLength, (_) => FocusNode());

    _otpSentWorker = ever<bool>(auth.isOtpSent, (sent) {
      if (sent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _otpNodes.first.requestFocus();
        });
      }
    });
  }

  @override
  void dispose() {
    _otpSentWorker?.dispose();
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _clearOtpBoxes() {
    for (final c in _otpControllers) {
      c.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlue,
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 900;
          if (wide) {
            return SizedBox(
              width: c.maxWidth,
              height: c.maxHeight,
              child: Row(
                children: [
                  const Expanded(flex: 105, child: _BrandPanelWide()),
                  Expanded(flex: 100, child: _formsPanel(wide: true)),
                ],
              ),
            );
          }
          return _buildMobileView(context);
        },
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF6EAFFF),
            Color(0xFFA5CFFF),
            Color(0xFFD6EAFF),
            Color(0xFFEFF5FF),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMobileHeader(),
              _buildMobileTitles(),
              _buildMobileFeatures(),
              const _MobileHouseScene(),
              _buildMobileFormCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.royalBlue.withValues(alpha: 0.14),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/login_bg_v2.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agremate',
                style: _p(24, w: FontWeight.w700, color: AppColors.navy, height: 1.1),
              ),
              const SizedBox(height: 4),
              Text(
                'Rent • Manage • Grow',
                style: _p(12.5, w: FontWeight.w500, color: AppColors.navy),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTitles() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smarter Property\nManagement',
            style: _p(28, w: FontWeight.w700, color: AppColors.navy, height: 1.16),
          ),
          const SizedBox(height: 10),
          Text(
            'Find, Rent and Manage Properties\nwith Ease',
            style: _p(
              15,
              w: FontWeight.w400,
              color: AppColors.navy.withValues(alpha: 0.9),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFeatures() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MobileFeatureItem(
            icon: Icons.home_rounded,
            label: 'Manage\nProperties',
          ),
          _MobileFeatureItem(
            icon: Icons.groups_rounded,
            label: 'Connect\nTenants',
          ),
          _MobileFeatureItem(
            icon: Icons.trending_up_rounded,
            label: 'Grow Your\nBusiness',
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFormCard() {
    return Transform.translate(
      offset: const Offset(0, -32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          final isOtpSent = auth.isOtpSent.value;
          final loading = auth.isLoading.value;
          final errMsg = auth.errorMessage.value;
          final phoneErr =
              auth.phoneError.value.isNotEmpty ? auth.phoneError.value : null;
          final otpErr =
              auth.otpError.value.isNotEmpty ? auth.otpError.value : null;
          final secondsRemaining = auth.secondsRemaining.value;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E50AA).withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      const Expanded(
                        child:
                            Divider(color: Color(0xFFD6E4FA), thickness: 1.2),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFD6E4FA),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.royalBlue.withValues(alpha: 0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isOtpSent
                              ? Icons.verified_user_rounded
                              : Icons.home_outlined,
                          size: 26,
                          color: AppColors.royalBlue,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child:
                            Divider(color: Color(0xFFD6E4FA), thickness: 1.2),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 18),
                  child: isOtpSent
                      ? _buildMobileVerifyContent(
                          loading: loading,
                          otpErr: otpErr,
                          secondsRemaining: secondsRemaining,
                          errMsg: errMsg,
                        )
                      : _buildMobileLoginContent(
                          loading: loading,
                          phoneErr: phoneErr,
                          errMsg: errMsg,
                        ),
                ),
                _buildMobileFooter(),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMobileLoginContent({
    required bool loading,
    required String? phoneErr,
    required String errMsg,
  }) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            text: 'Welcome ',
            children: [
              TextSpan(
                text: 'Back!',
                style: _p(26, w: FontWeight.w700, color: AppColors.royalBlue),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: _p(26, w: FontWeight.w700, color:AppColors.navy),
        ),
        const SizedBox(height: 6),
        Text(
          'Login to your Agremate account',
          textAlign: TextAlign.center,
          style: _p(14, color: const Color(0xFF6B7A99)),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: _p(15, w: FontWeight.w500, color: AppColors.textDark),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hoverColor: Colors.transparent,
            hintText: 'Enter 10 digit mobile number',
            hintStyle: _p(14, color: const Color(0xFF8C9BAE)),
            errorText: phoneErr,
            errorStyle: _p(11, color: AppColors.error),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.call, color:AppColors.navy, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppStrings.countryCode,
                  style: _p(15, w: FontWeight.w600, color:AppColors.navy),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 20,
                  color: const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 10),
              ],
            ),
            enabledBorder: _pill(const Color(0xFF2E80E5), 1.5),
            border: _pill(const Color(0xFF2E80E5), 1.5),
            focusedBorder: _pill(AppColors.sky, 2.2),
            errorBorder: _pill(AppColors.error, 1.5),
            focusedErrorBorder: _pill(AppColors.error, 2.2),
          ),
          onChanged: (val) => auth.onPhoneChanged(val),
        ),
        const SizedBox(height: 18),
        _GradientButton(
          label: AppStrings.sendOtp,
          icon: Icons.arrow_forward,
          loading: loading,
          disabled: loading,
          onTap: () => auth.onSendOtpPressed(_phoneController.text.trim()),
        ),
        if (errMsg.isNotEmpty) _errorRow(errMsg),
      ],
    );
  }

  Widget _buildMobileVerifyContent({
    required bool loading,
    required String? otpErr,
    required int secondsRemaining,
    required String errMsg,
  }) {
    return Column(
      children: [
        Text(
          AppStrings.verifyOtp,
          textAlign: TextAlign.center,
          style: _p(24, w: FontWeight.w700, color:AppColors.navy),
        ),
        const SizedBox(height: 6),
        Text(
          auth.isOtpSent.value
              ? AppStrings.otpSentTo(
                  AuthController.otpLength,
                  auth.phoneNumber.value,
                )
              : 'Enter the ${AuthController.otpLength} digit code sent to your mobile number',
          textAlign: TextAlign.center,
          style: _p(13.5, color: const Color(0xFF6B7A99)),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, c) {
            const gap = 12.0;
            final n = AuthController.otpLength;
            final box = math.min(56.0, (c.maxWidth - gap * (n - 1)) / n);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < n; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  SizedBox(
                    width: box,
                    height: box,
                    child: _otpBox(i, otpErr != null),
                  ),
                ],
              ],
            );
          },
        ),
        if (otpErr != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              otpErr,
              textAlign: TextAlign.center,
              style: _p(12, color: AppColors.error),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: loading || secondsRemaining > 0
                  ? null
                  : () => auth.onResendOtpPressed(),
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: secondsRemaining > 0 ? AppColors.hintGrey : AppColors.royalBlue,
              ),
              label: Text(
                secondsRemaining > 0
                    ? AppStrings.resendOtpIn(
                        auth.formatTime(secondsRemaining),
                      )
                    : AppStrings.resendOtp,
                style: _p(
                  13.5,
                  w: FontWeight.w500,
                  color: secondsRemaining > 0 ? AppColors.hintGrey : AppColors.royalBlue,
                ),
              ),
            ),
            TextButton(
              onPressed: loading
                  ? null
                  : () {
                      auth.onChangeNumberPressed();
                      _clearOtpBoxes();
                    },
              child: Text(
                AppStrings.changeNumber,
                style: _p(13.5, w: FontWeight.w500, color: AppColors.textGrey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _GradientButton(
          label: 'Verify & Login',
          loading: loading,
          disabled: loading,
          onTap: () => auth.onVerifyOtpPressed(_otpValue.trim()),
        ),
        if (errMsg.isNotEmpty) _errorRow(errMsg),
      ],
    );
  }

  Widget _buildMobileFooter() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(
                child: Divider(color: Color(0xFFD8E2F0), thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Trusted by Property Owners & Tenants',
                  style:
                      _p(11, w: FontWeight.w500, color: const Color(0xFF6B7A99)),
                ),
              ),
              const Expanded(
                child: Divider(color: Color(0xFFD8E2F0), thickness: 1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          child: SizedBox(
            width: double.infinity,
            height: 38,
            child: CustomPaint(painter: _SkylinePainter()),
          ),
        ),
      ],
    );
  }

  Widget _formsPanel({required bool wide}) {
    final content = Obx(() {
      final isOtpSent = auth.isOtpSent.value;
      final loading = auth.isLoading.value;
      final errMsg = auth.errorMessage.value;
      final phoneErr =
      auth.phoneError.value.isNotEmpty ? auth.phoneError.value : null;
      final otpErr = auth.otpError.value.isNotEmpty ? auth.otpError.value : null;
      final secondsRemaining = auth.secondsRemaining.value;

      return isOtpSent
          ? _verifyCard(
              isOtpSent: isOtpSent,
              loading: loading,
              otpErr: otpErr,
              secondsRemaining: secondsRemaining,
              errMsg: errMsg,
            )
          : _loginCard(
              isOtpSent: isOtpSent,
              loading: loading,
              phoneErr: phoneErr,
              errMsg: errMsg,
            );
    });

    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -110,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFD3E3FC)),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFE3EEFF)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: wide
                  ? FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: 640, child: content),
              )
                  : ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(44, 44, 44, 44),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1E50AA).withValues(alpha: 0.12),
          blurRadius: 40,
          offset: const Offset(0, 18),
        ),
      ],
    ),
    child: child,
  );

  Widget _loginCard({
    required bool isOtpSent,
    required bool loading,
    required String? phoneErr,
    required String errMsg,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Welcome ',
              children: [TextSpan(text: 'Back!', style: _p(34, w: FontWeight.w700, color: AppColors.royalBlue))],
            ),
            style: _p(34, w: FontWeight.w700, color:AppColors.navy),
          ),
          const SizedBox(height: 8),
          Text('Login to your Agremate account',
              style: _p(16, color: AppColors.textDark)),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: _p(17, w: FontWeight.w500, color: AppColors.textDark),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hoverColor: Colors.transparent,
              hintText: 'Enter 10 digit mobile number',
              hintStyle: _p(15, color: const Color(0xFF6B7A99)),
              errorText: phoneErr,
              errorStyle: _p(11, color: AppColors.error),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.call, color:AppColors.navy, size: 22),
                  const SizedBox(width: 8),
                  Text(AppStrings.countryCode,
                      style: _p(16, w: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(width: 8),
                ],
              ),
              enabledBorder: _pill(AppColors.royalBlue, 2),
              border: _pill(AppColors.royalBlue, 2),
              focusedBorder: _pill(AppColors.sky, 3),
              errorBorder: _pill(AppColors.error, 2),
              focusedErrorBorder: _pill(AppColors.error, 3),
            ),
            onChanged: (val) => auth.onPhoneChanged(val),
          ),
          const SizedBox(height: 22),
          _GradientButton(
            label: AppStrings.sendOtp,
            icon: Icons.arrow_forward,
            loading: loading && !isOtpSent,
            disabled: loading,
            onTap: () => auth.onSendOtpPressed(_phoneController.text.trim()),
          ),
          if (errMsg.isNotEmpty) _errorRow(errMsg),
        ],
      ),
    );
  }

  OutlineInputBorder _pill(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(999),
    borderSide: BorderSide(color: color, width: width),
  );


  Widget _verifyCard({
    required bool isOtpSent,
    required bool loading,
    required String? otpErr,
    required int secondsRemaining,
    required String errMsg,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFEEF4FF)),
                child: const Icon(Icons.verified_user_rounded,
                    size: 26, color: Color(0xFF0B4FD0)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.verifyOtp,
                        style: _p(26, w: FontWeight.w600, color:AppColors.navy)),
                    const SizedBox(height: 4),
                    Text(
                      isOtpSent
                          ? AppStrings.otpSentTo(
                          AuthController.otpLength, auth.phoneNumber.value)
                          : 'Enter the ${AuthController.otpLength} digit code sent to your mobile number',
                      style: _p(15, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          LayoutBuilder(builder: (context, c) {
            const gap = 16.0;
            final n = AuthController.otpLength;
            final box = math.min(72.0, (c.maxWidth - gap * (n - 1)) / n);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < n; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  SizedBox(width: box, height: box, child: _otpBox(i, otpErr != null)),
                ],
              ],
            );
          }),
          if (otpErr != null)
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 4),
              child: Text(otpErr, style: _p(13, color: AppColors.error)),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: loading || secondsRemaining > 0
                    ? null
                    : () => auth.onResendOtpPressed(),
                icon: Icon(Icons.refresh_rounded,
                    size: 22,
                    color: secondsRemaining > 0 ? AppColors.hintGrey : AppColors.royalBlue),
                label: Text(
                  secondsRemaining > 0
                      ? AppStrings.resendOtpIn(auth.formatTime(secondsRemaining))
                      : AppStrings.resendOtp,
                  style: _p(16,
                      w: FontWeight.w500,
                      color: secondsRemaining > 0 ? AppColors.hintGrey : AppColors.royalBlue),
                ),
              ),
              TextButton(
                onPressed: loading
                    ? null
                    : () {
                  auth.onChangeNumberPressed();
                  _clearOtpBoxes();
                },
                child: Text(AppStrings.changeNumber,
                    style: _p(16, w: FontWeight.w500, color: AppColors.textGrey)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _GradientButton(
            label: 'Verify & Login',
            loading: loading && isOtpSent,
            disabled: loading,
            onTap: () => auth.onVerifyOtpPressed(_otpValue.trim()),
          ),
          if (errMsg.isNotEmpty) _errorRow(errMsg),
        ],
      ),
    );
  }

  Widget _otpBox(int i, bool hasError) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _otpControllers[i].text.isEmpty &&
            i > 0) {
          _otpControllers[i - 1].clear();
          _otpNodes[i - 1].requestFocus();
          auth.onOtpChanged(_otpValue);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: _otpControllers[i],
        focusNode: _otpNodes[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: _p(26, w: FontWeight.w600, color:AppColors.navy),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hoverColor: Colors.transparent,
          counterText: '',
          isDense: true,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: hasError ? AppColors.error: AppColors.borderBlue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: hasError ? AppColors.error: AppColors.royalBlue, width: 2.5),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && i < AuthController.otpLength - 1) {
            _otpNodes[i + 1].requestFocus();
          }
          auth.onOtpChanged(_otpValue);
        },
      ),
    );
  }

  Widget _errorRow(String message) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: AppColors.error, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: _p(13, color: AppColors.error))),
      ],
    ),
  );
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final bool disabled;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.loading = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(999));
    return Opacity(
      opacity: (loading || disabled) ? 0.65 : 1,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(colors: [Color(0xFF0B4FD0), AppColors.sky]),
          boxShadow: [
            BoxShadow(
              color: AppColors.royalBlue.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: (loading || disabled) ? null : onTap,
            child: Center(
              child: loading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: _p(16, w: FontWeight.w600, color: Colors.white)),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _panelGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF5EA8FF), Color(0xFF9CCBFF), Color(0xFFE3EFFF)],
);

/// Desktop: fills the full height, curved right edge, text on top, house at the bottom.
class _BrandPanelWide extends StatelessWidget {
  const _BrandPanelWide();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _PanelClipper(),
      child: Container(
        decoration: const BoxDecoration(gradient: _panelGradient),
        child: LayoutBuilder(
          builder: (context, c) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 40, 0, 0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: c.maxHeight * 0.60,
                      maxWidth: c.maxWidth * 0.80,
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topLeft,
                      child: _BrandText(wide: true),
                    ),
                  ),
                ),
                const Expanded(child: _HouseScene()),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Phone: stacked above the forms.
class _BrandPanelNarrow extends StatelessWidget {
  const _BrandPanelNarrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: _panelGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(70)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, 40, 24, 0),
            child: _BrandText(wide: false),
          ),
          SizedBox(height: 230, child: _HouseScene()),
        ],
      ),
    );
  }
}

class _BrandText extends StatelessWidget {
  final bool wide;
  const _BrandText({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Logo(),
        const SizedBox(height: 36),
        Text(
          'Smarter Property\nManagement',
          style: _p(wide ? 46 : 32, w: FontWeight.w700, color:AppColors.navy, height: 1.12),
        ),
        const SizedBox(height: 12),
        Text(
          'Find, Rent and Manage Properties\nwith Ease',
          style: _p(wide ? 20 : 16, color:AppColors.navy, height: 1.4),
        ),
        const SizedBox(height: 28),
        const Wrap(
          spacing: 28,
          runSpacing: 16,
          children: [
            _Feature(icon: Icons.home_rounded, label: 'Manage\nProperties'),
            _Feature(icon: Icons.groups_rounded, label: 'Connect\nTenants'),
            _Feature(icon: Icons.trending_up_rounded, label: 'Grow Your\nBusiness'),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// House photo (fades into the sky) with the blue wave across the bottom.
class _HouseScene extends StatelessWidget {
  const _HouseScene();

  static const _aspect = 680 / 290;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        double imgW = w, imgH = w / _aspect;
        if (imgH > h) {
          imgH = h;
          imgW = h * _aspect;
        }
        final waveH = math.max(56.0, imgH * 0.20);

        Widget photo = Image.asset(
          'assets/images/house.jpg',
          width: imgW,
          height: imgH,
          fit: BoxFit.cover,
          semanticLabel: 'Modern house surrounded by city towers at dusk',
        );
        photo = ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.white],
            stops: [0.0, 0.30],
          ).createShader(r),
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.82, 1.0],
            ).createShader(r),
            child: photo,
          ),
        );

        return Stack(
          children: [
            Positioned(left: 0, bottom: 0, width: imgW, height: imgH, child: photo),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: waveH,
              child: CustomPaint(painter: _WavePainter()),
            ),
          ],
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    final back = Path()
      ..moveTo(0, h * 0.35)
      ..cubicTo(w * 0.30, h * 0.02, w * 0.60, h * 0.55, w, h * 0.10)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF4A98F8));

    final front = Path()
      ..moveTo(0, h * 0.62)
      ..cubicTo(w * 0.28, h * 0.28, w * 0.62, h * 0.95, w, h * 0.45)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      front,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0B4FD0), Color(0xFF1E7BFF)],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// The wavy right edge of the brand panel on desktop.
class _PanelClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width, h = s.height;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..cubicTo(w * 0.89, h * 0.10, w * 0.88, h * 0.30, w * 0.91, h * 0.50)
      ..cubicTo(w * 0.94, h * 0.68, w * 1.0, h * 0.82, w * 0.88, h)
      ..lineTo(0, h)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(
          'assets/images/login_bg_v2.jpg',
          width: 88,
          height: 70,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agremate', style: _p(38, w: FontWeight.w700, color:AppColors.navy, height: 1)),
            const SizedBox(height: 6),
            Text('Rent • Manage • Grow', style: _p(14, w: FontWeight.w500, color:AppColors.navy)),
          ],
        ),
      ],
    );
  }
}

class _HousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final roof = Paint()
      ..color = AppColors.royalBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(s.width * .06, s.height * .55)
      ..lineTo(s.width * .48, s.height * .10)
      ..lineTo(s.width * .90, s.height * .55);
    canvas.drawPath(path, roof);

    final win = Paint()..color =AppColors.navy;
    final w = s.width * .12;
    for (final dx in [.30, .45]) {
      for (final dy in [.48, .70]) {
        canvas.drawRect(Rect.fromLTWH(s.width * dx, s.height * dy, w, w), win);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Feature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.royalBlue.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, size: 34, color: AppColors.royalBlue),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: _p(13, w: FontWeight.w500, color:AppColors.navy, height: 1.25)),
        ],
      ),
    );
  }
}

class _MobileFeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MobileFeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.royalBlue.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, size: 32, color: AppColors.royalBlue),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: _p(12, w: FontWeight.w600, color:AppColors.navy, height: 1.25),
        ),
      ],
    );
  }
}

class _MobileHouseScene extends StatelessWidget {
  const _MobileHouseScene();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 195,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.white],
              stops: [0.0, 0.24],
            ).createShader(r),
            child: Image.asset(
              'assets/images/house.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 65,
            child: CustomPaint(painter: _WavePainter()),
          ),
        ],
      ),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  const _SkylinePainter();

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    final buildingPaint = Paint()
      ..color = const Color(0xFF7CB8F8).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final buildingPaintDark = Paint()
      ..color = const Color(0xFF5BA4F5).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final treePaint = Paint()
      ..color = const Color(0xFF58A0F5).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final buildings = [
      [0.02, 0.045, 0.50, 0],
      [0.08, 0.055, 0.85, 1],
      [0.15, 0.045, 0.40, 0],
      [0.21, 0.060, 0.70, 1],
      [0.29, 0.045, 0.55, 0],
      [0.35, 0.065, 0.92, 1],
      [0.43, 0.050, 0.50, 0],
      [0.50, 0.065, 0.78, 1],
      [0.58, 0.048, 0.60, 0],
      [0.64, 0.065, 0.95, 1],
      [0.72, 0.048, 0.45, 0],
      [0.78, 0.065, 0.75, 1],
      [0.86, 0.050, 0.55, 0],
      [0.92, 0.055, 0.40, 0],
    ];

    for (int i = 0; i < buildings.length; i++) {
      final b = buildings[i];
      final bx = (b[0] as double) * w;
      final bw = (b[1] as double) * w;
      final bh = (b[2] as double) * h;
      final by = h - bh;

      final paint = i % 2 == 0 ? buildingPaint : buildingPaintDark;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(bx, by, bw, bh),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        paint,
      );

      if (b[3] == 1 && bh > 16) {
        final winW = math.max(1.8, bw * 0.18);
        final winH = math.max(2.0, bh * 0.08);
        for (double wy = by + 4; wy < h - 4; wy += winH + 3) {
          canvas.drawRect(
            Rect.fromLTWH(bx + bw * 0.22, wy, winW, winH),
            windowPaint,
          );
          canvas.drawRect(
            Rect.fromLTWH(bx + bw * 0.58, wy, winW, winH),
            windowPaint,
          );
        }
      }
    }

    final treeX = [
      0.065,
      0.19,
      0.275,
      0.415,
      0.485,
      0.565,
      0.705,
      0.765,
      0.845,
      0.905
    ];
    for (final tx in treeX) {
      canvas.drawCircle(Offset(tx * w, h - 5), 4.5, treePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
