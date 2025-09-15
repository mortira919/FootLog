import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CoachChatFabButton extends StatelessWidget {
  final bool visible;
  final VoidCallback? onTap;

  const CoachChatFabButton({
    super.key,
    this.visible = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = 50.0.w;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: visible ? 1 : 0,
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          child: InkResponse(
            onTap: onTap,
            radius: size,
            containedInkWell: true,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759), // зелёный
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.forum, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
