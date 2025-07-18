import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../theme/nature_theme.dart';

class LeafFloatingEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double intensity;
  
  const LeafFloatingEffect({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
    this.intensity = 1.0,
  });
  
  @override
  State<LeafFloatingEffect> createState() => _LeafFloatingEffectState();
}

class _LeafFloatingEffectState extends State<LeafFloatingEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Transform.translate(
          offset: Offset(
            (value - 0.5) * 10 * widget.intensity,
            (value - 0.5) * 5 * widget.intensity,
          ),
          child: Transform.rotate(
            angle: (value - 0.5) * 0.1 * widget.intensity,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class NatureShimmerEffect extends StatelessWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  
  const NatureShimmerEffect({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFF52796F),
    this.highlightColor = const Color(0xFF95D5B2),
  });
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 2000),
      child: child,
    );
  }
}

class TreeGrowthAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  
  const TreeGrowthAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.elasticOut,
  });
  
  @override
  State<TreeGrowthAnimation> createState() => _TreeGrowthAnimationState();
}

class _TreeGrowthAnimationState extends State<TreeGrowthAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class NatureTextAnimation extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  
  const NatureTextAnimation({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 100),
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: style ?? Theme.of(context).textTheme.headlineMedium,
          speed: speed,
        ),
      ],
      totalRepeatCount: 1,
    );
  }
}

class LeafParticleEffect extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final Color particleColor;
  final double particleSize;
  
  const LeafParticleEffect({
    super.key,
    required this.child,
    this.particleCount = 20,
    this.particleColor = NatureTheme.leafGreen,
    this.particleSize = 8.0,
  });
  
  @override
  State<LeafParticleEffect> createState() => _LeafParticleEffectState();
}

class _LeafParticleEffectState extends State<LeafParticleEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _particles = List.generate(
      widget.particleCount,
      (index) => _Particle(
        x: (index / widget.particleCount) * 2 - 1,
        y: -1.5,
        size: widget.particleSize,
        color: widget.particleColor,
        speed: 0.3 + (index % 3) * 0.1,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(_particles, _controller.value),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  final double size;
  final Color color;
  final double speed;
  
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;
  
  _ParticlePainter(this.particles, this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    
    for (final particle in particles) {
      final progress = (animationValue + particle.speed) % 1.0;
      final x = (particle.x + 1) * size.width / 2;
      final y = progress * size.height * 1.5;
      
      paint.color = particle.color.withValues(alpha: 1.0 - progress);
      
      // Draw leaf shape
      final path = Path();
      path.moveTo(x, y);
      path.quadraticBezierTo(x + particle.size, y - particle.size, x, y - particle.size * 2);
      path.quadraticBezierTo(x - particle.size, y - particle.size, x, y);
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NatureGradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  
  const NatureGradientBackground({
    super.key,
    required this.child,
    this.gradient = NatureTheme.forestGradient,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}

class PulsatingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Duration duration;
  
  const PulsatingIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color = NatureTheme.forestGreen,
    this.duration = const Duration(milliseconds: 1500),
  });
  
  @override
  State<PulsatingIcon> createState() => _PulsatingIconState();
}

class _PulsatingIconState extends State<PulsatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class NatureCard extends StatelessWidget {
  final Widget child;
  final BoxDecoration? decoration;
  final EdgeInsets padding;
  final double elevation;
  final VoidCallback? onTap;
  
  const NatureCard({
    super.key,
    required this.child,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 8,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return TreeGrowthAnimation(
      child: LeafFloatingEffect(
        intensity: 0.5,
        child: Card(
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: decoration ?? NatureDecorations.forestCard,
            padding: padding,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WaveLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  
  const WaveLoadingIndicator({
    super.key,
    this.color = NatureTheme.forestGreen,
    this.size = 50,
  });
  
  @override
  State<WaveLoadingIndicator> createState() => _WaveLoadingIndicatorState();
}

class _WaveLoadingIndicatorState extends State<WaveLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final double animationValue;
  
  _WavePainter({required this.color, required this.animationValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    for (int i = 0; i < 3; i++) {
      final currentRadius = radius * (animationValue + i * 0.3) % 1.0;
      final opacity = 1.0 - ((animationValue + i * 0.3) % 1.0);
      
      paint.color = color.withValues(alpha: opacity * 0.3);
      canvas.drawCircle(center, currentRadius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}