import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double height;
  final Gradient gradient;
  final VoidCallback? onPressed;
  final String label;
  // final Widget? child;

  const GradientButton({
    Key? key,
    required this.onPressed,
    // required this.child,
    this.borderRadius,
    this.width,
    this.height = 48.0,
    required this.label,
    this.gradient = const LinearGradient(colors: [
      Color(0xff3A9FBE),
      Color(0xff17E1DA),
    ]),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(12);
    return Container(
      width: width ?? 200,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
