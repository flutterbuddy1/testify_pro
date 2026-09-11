import 'package:flutter/material.dart';

/// Vertical splitter bar for resizing columns (left / right)
class DesktopVerticalSplitter extends StatefulWidget {
  final ValueChanged<double> onDrag;
  final VoidCallback? onDoubleTap;
  final double width;
  final bool isCollapsed;

  const DesktopVerticalSplitter({
    super.key,
    required this.onDrag,
    this.onDoubleTap,
    this.width = 6.0,
    this.isCollapsed = false,
  });

  @override
  State<DesktopVerticalSplitter> createState() =>
      _DesktopVerticalSplitterState();
}

class _DesktopVerticalSplitterState extends State<DesktopVerticalSplitter> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _isHovered || _isDragging;

    return MouseRegion(
      cursor: widget.isCollapsed
          ? SystemMouseCursors.click
          : SystemMouseCursors.resizeColumn,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: widget.onDoubleTap,
        onHorizontalDragStart: (_) => setState(() => _isDragging = true),
        onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
        onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
        onHorizontalDragCancel: () => setState(() => _isDragging = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.35)
              : Colors.transparent,
          child: Center(
            child: Container(
              width: isActive ? 3.0 : 1.0,
              height: double.infinity,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal splitter bar for resizing rows (top / bottom)
class DesktopHorizontalSplitter extends StatefulWidget {
  final ValueChanged<double> onDrag;
  final VoidCallback? onDoubleTap;
  final double height;
  final Widget? trailingActions;

  const DesktopHorizontalSplitter({
    super.key,
    required this.onDrag,
    this.onDoubleTap,
    this.height = 10.0,
    this.trailingActions,
  });

  @override
  State<DesktopHorizontalSplitter> createState() =>
      _DesktopHorizontalSplitterState();
}

class _DesktopHorizontalSplitterState extends State<DesktopHorizontalSplitter> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = _isHovered || _isDragging;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: widget.onDoubleTap,
        onVerticalDragStart: (_) => setState(() => _isDragging = true),
        onVerticalDragUpdate: (details) => widget.onDrag(details.delta.dy),
        onVerticalDragEnd: (_) => setState(() => _isDragging = false),
        onVerticalDragCancel: () => setState(() => _isDragging = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          width: double.infinity,
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.15)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Top border
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              // Center grip pill
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isActive ? 48.0 : 32.0,
                  height: isActive ? 4.0 : 3.0,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Trailing action buttons if provided
              if (widget.trailingActions != null)
                Positioned(
                  right: 8,
                  child: widget.trailingActions!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
