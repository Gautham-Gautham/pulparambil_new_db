import 'package:flutter/material.dart';
import 'package:pulparambil/Core/Utils/size_utils.dart';
import '../../Theme/theme_helper.dart';
import 'base_button.dart';

class CustomElevatedButton extends BaseButton {
  const CustomElevatedButton(
      {super.key,
      this.decoration,
      this.leftIcon,
      this.rightIcon,
      EdgeInsets? margin,
      VoidCallback? onPressed,
      ButtonStyle? buttonStyle,
      Alignment? alignment,
      TextStyle? buttonTextStyle,
      bool? isDisabled,
      double? height,
      double? width,
      required String text})
      : super(
          text: text,
          onPressed: onPressed,
          buttonStyle: buttonStyle,
          isDisabled: isDisabled,
          buttonTextStyle: buttonTextStyle,
          height: height,
          width: width,
          alignment: alignment,
          margin: margin,
        );

  final BoxDecoration? decoration;

  final Widget? leftIcon;

  final Widget? rightIcon;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: buildElevatedButtonWidget)
        : buildElevatedButtonWidget;
  }

  Widget get buildElevatedButtonWidget => Container(
        height: height ?? 25.v,
        width: width ?? double.maxFinite,
        margin: margin,
        decoration: decoration,
        child: ElevatedButton(
          style: buttonStyle,
          onPressed: isDisabled ?? false ? null : onPressed ?? () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leftIcon ?? const SizedBox.shrink(),
              Text(
                text,
                style: buttonTextStyle ?? theme.textTheme.labelMedium,
              ),
              rightIcon ?? const SizedBox.shrink()
            ],
          ),
        ),
      );
}
