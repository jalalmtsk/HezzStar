import 'dart:math';
import 'package:flutter/material.dart';
import 'FlyingRewardManager.dart';

class FlyingRewardWidget extends StatefulWidget {
  final Offset startOffset;
  final GlobalKey endKey;
  final int amount;
  final RewardType type;
  final VoidCallback onCompleted;

  const FlyingRewardWidget({
    super.key,
    required this.startOffset,
    required this.endKey,
    required this.amount,
    required this.type,
    required this.onCompleted,
  });

  @override
  State<FlyingRewardWidget> createState() => _FlyingRewardWidgetState();
}

class _FlyingRewardWidgetState extends State<FlyingRewardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<Offset>? _animation; // Nullable
  late Offset _randomOffset;

  @override
  void initState() {
    super.initState();

    // Random offset for slight variation in trajectory
    final random = Random();
    _randomOffset = Offset(random.nextDouble() * 50 - 25, random.nextDouble() * 50 - 25);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600 + random.nextInt(300)),
    );

    // Initialize animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAnimation());
  }

  void _initAnimation() {
    if (!mounted) return;

    final context = widget.endKey.currentContext;
    if (context == null) {
      // Retry in next frame if not ready
      WidgetsBinding.instance.addPostFrameCallback((_) => _initAnimation());
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initAnimation());
      return;
    }

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final endOffset = position + Offset(size.width / 2 - 16, size.height / 2 - 16);

    _animation = Tween<Offset>(
      begin: widget.startOffset + _randomOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onCompleted();
    });

    _controller.forward();

    // Rebuild now that animation is ready
    setState(() {});
  }

  Color _getTextColor() {
    switch (widget.type) {
      case RewardType.gold:
        return Colors.amber;
      case RewardType.gem:
        return Colors.cyanAccent;
      case RewardType.star:
        return Colors.yellowAccent.shade700;
    }
  }

  String _getIconPath() {
    switch (widget.type) {
      case RewardType.gold:
        return 'assets/UI/Icons/Gamification/Gold_Icon.png';
      case RewardType.gem:
        return 'assets/UI/Icons/Gamification/Gems_Icon.png';
      case RewardType.star:
        return 'assets/UI/Icons/Gamification/Xp_Icon.png';
    }
  }

  @override
  void dispose() {
    if (_controller.isAnimating) widget.onCompleted();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animation == null) {
      // Animation not ready yet
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Positioned(
          left: _animation!.value.dx,
          top: _animation!.value.dy,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Trail
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_getTextColor().withOpacity(0.8), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Icon
              Image.asset(_getIconPath(), width: 39, height: 39),
            ],
          ),
        );
      },
    );
  }
}

