import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformBottomSheet extends StatefulWidget {
  final Widget initialChild;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final ValueNotifier<double>? sizeNotifier;
  final ValueNotifier<Widget>? childNotifier;
  final bool isDismissible;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool isScrollControlled;
  final bool enableDrag;

  const PlatformBottomSheet({
    super.key,
    required this.initialChild,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 0.5,
    this.sizeNotifier,
    this.childNotifier,
    this.isDismissible = true,
    this.backgroundColor,
    this.borderRadius,
    this.isScrollControlled = true,
    this.enableDrag = true,
  });

  @override
  State<PlatformBottomSheet> createState() => _PlatformBottomSheetState();

  static show<T>({
    required BuildContext context,
    required Widget child,
    double initialChildSize = 0.5,
    double minChildSize = 0.25,
    double maxChildSize = 0.9,
    ValueNotifier<double>? sizeNotifier,
    ValueNotifier<Widget>? childNotifier,
    bool isDismissible = true,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool isScrollControlled = true,
    bool enableDrag = true,
    double? topSafeArea = 0,
  }) {
    if (Platform.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        barrierDismissible: isDismissible,
        barrierColor: Colors.transparent,
        builder: (context) => PlatformBottomSheet(
          initialChild: child,
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          sizeNotifier: sizeNotifier,
          childNotifier: childNotifier,
          isDismissible: isDismissible,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          isScrollControlled: true,
          enableDrag: enableDrag,
        ),
      );
    } else {
      return showBottomSheet(
        context: context,
        enableDrag: enableDrag,
        showDragHandle: false,
        backgroundColor: Colors.transparent,
        builder: (context) => PlatformBottomSheet(
          initialChild: child,
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          sizeNotifier: sizeNotifier,
          childNotifier: childNotifier,
          isDismissible: isDismissible,
          backgroundColor: backgroundColor,
          isScrollControlled: true,
          borderRadius: borderRadius,
        ),
      );
    }
  }
}

class _PlatformBottomSheetState extends State<PlatformBottomSheet> {
  late double currentSize;
  late Widget currentChild;

  final DraggableScrollableController _dragController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    currentSize = widget.initialChildSize;
    currentChild = widget.initialChild;
    widget.sizeNotifier?.addListener(_updateSize);
    widget.childNotifier?.addListener(_updateChild);
  }

  void _updateSize() {
    if (mounted && widget.sizeNotifier != null) {
      setState(() {
        currentSize = widget.sizeNotifier!.value;
      });
      _dragController.animateTo(
        currentSize,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateChild() {
    if (mounted && widget.childNotifier != null) {
      setState(() {
        currentChild = widget.childNotifier!.value;
      });
    }
  }

  @override
  void dispose() {
    widget.sizeNotifier?.removeListener(_updateSize);
    widget.childNotifier?.removeListener(_updateChild);
    _dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildCupertinoSheet() : _buildMaterialSheet();
  }

  Widget _buildMaterialSheet() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = MediaQuery.of(context).size.height;

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (_) => false,
          child: SizedBox(
            height: height,
            child: DraggableScrollableSheet(
              initialChildSize: currentSize,
              minChildSize: widget.minChildSize,
              maxChildSize: widget.maxChildSize,
              snap: true,
              shouldCloseOnMinExtent: false,
              controller: _dragController,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor ?? Colors.white,
                    borderRadius: widget.borderRadius ??
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: currentChild,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildCupertinoSheet() {
    return GestureDetector(
      onVerticalDragUpdate: widget.enableDrag ? _handleDragUpdate : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: MediaQuery.of(context).size.height * currentSize,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * widget.minChildSize,
          maxHeight: MediaQuery.of(context).size.height * widget.maxChildSize,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? CupertinoColors.systemBackground,
          borderRadius: widget.borderRadius ??
              const BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.enableDrag) _buildDragHandle(),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: currentChild,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      height: 20,
      alignment: Alignment.center,
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    final newSize = currentSize - (details.primaryDelta! / screenHeight);

    if (newSize >= widget.minChildSize && newSize <= widget.maxChildSize) {
      setState(() {
        currentSize = newSize;
      });
      widget.sizeNotifier?.value = newSize;
    }
  }
}
