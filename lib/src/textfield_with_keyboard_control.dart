import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

// TODO: organize the properties

class TextFieldWithKeyboardControl extends StatefulWidget {
  const TextFieldWithKeyboardControl({
    super.key,
    required this.focusNode,
    required this.controller,
    this.showKeyboardIcon = true,
    this.inputTextStyle,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autofocus = true,
    this.startShowKeyboard = false,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines = 1,
    this.expands = false,
    this.forceLine = true,
    this.inputDecoration,
    this.onSubmitted,
    this.onChanged,
    this.onEditingComplete,
    this.keyboardIcon,
    this.selectedKeyboardIcon,
    this.onDoubleTap,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.onHighlightChanged,
    this.onHover,
    this.mouseCursor,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.overlayColor,
    this.splashColor,
    this.splashFactory,
    this.radius,
    this.borderRadius,
    this.customBorder,
  });

  /// TextField Properties
  final bool startShowKeyboard;
  final bool showKeyboardIcon;
  final NoKeyboardFocusNode focusNode;
  final void Function(String value)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String value)? onSubmitted;
  final TextEditingController controller;
  final TextStyle? inputTextStyle;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autofocus;
  final InputDecoration? inputDecoration;
  final Widget? keyboardIcon;
  final Widget? selectedKeyboardIcon;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final bool expands;
  final bool forceLine;

  /// InkWell Properties:
  final void Function()? onDoubleTap;
  final void Function()? onLongPress;
  final void Function(TapDownDetails tapDownDetails)? onTapDown;
  final void Function(TapUpDetails tapUpDetails)? onTapUp;
  final void Function()? onTapCancel;
  final void Function(bool value)? onHighlightChanged;
  final void Function(bool hovered)? onHover;
  final MouseCursor? mouseCursor;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? highlightColor;
  final MaterialStateProperty<Color?>? overlayColor;
  final Color? splashColor;
  final InteractiveInkFeatureFactory? splashFactory;
  final double? radius;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;

  @override
  State<TextFieldWithKeyboardControl> createState() => _TextFieldWithKeyboardControlState();
}

class _TextFieldWithKeyboardControlState extends State<TextFieldWithKeyboardControl> {
  late final void Function() fun;
  late bool showKeyboard;
  late bool visibleKeyboard;

  final editTextStateKey = GlobalKey<EditableTextState>();

  late StreamSubscription<bool> keyboardSubscription;
  final keyboardVisibilityController = KeyboardVisibilityController();

  @override
  void initState() {
    showKeyboard = widget.startShowKeyboard;

    fun = () {
      setState(() {
        if (widget.focusNode.hasFocus && showKeyboard) {
          editTextStateKey.currentState?.requestKeyboard();
        }
      });
    };

    widget.focusNode.addListener(fun);

    keyboardSubscription = keyboardVisibilityController.onChange.listen((visible) {
      visibleKeyboard = visible;

      if (widget.focusNode.hasFocus) {
        if (visibleKeyboard && !showKeyboard) {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        } else if (!visibleKeyboard && showKeyboard) {
          setState(() => showKeyboard = false);
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(fun);
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final txtTheme = Theme.of(context).textTheme;

    final suffixIcon = IconButton(
      isSelected: showKeyboard,
      icon: widget.keyboardIcon ?? const Icon(Icons.keyboard_alt_outlined),
      selectedIcon: widget.selectedKeyboardIcon ?? Icon(Icons.keyboard_hide_outlined, color: colorScheme.primary),
      onPressed: () => toggleShowKeyboard(showKeyboard),
    );

    final inputDecoration = widget.inputDecoration?.copyWith(suffixIcon: suffixIcon) ??
        InputDecoration(
          border: const OutlineInputBorder(),
          focusColor: colorScheme.primary,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          suffixIcon: showKeyboard ? suffixIcon : null,
        );

    return InkWell(
      onTap: () => widget.focusNode.requestFocus(),
      onDoubleTap: widget.onDoubleTap,
      onLongPress: widget.onLongPress,
      onTapDown: widget.onTapDown,
      onTapUp: widget.onTapUp,
      onTapCancel: widget.onTapCancel,
      onHighlightChanged: widget.onHighlightChanged,
      onHover: widget.onHover,
      mouseCursor: widget.mouseCursor,
      focusColor: widget.focusColor,
      hoverColor: widget.hoverColor,
      highlightColor: widget.highlightColor,
      overlayColor: widget.overlayColor,
      splashColor: widget.splashColor,
      splashFactory: widget.splashFactory,
      radius: widget.radius,
      borderRadius: widget.borderRadius,
      customBorder: widget.customBorder,
      child: InputDecorator(
        isFocused: widget.focusNode.hasFocus,
        isEmpty: widget.controller.text.isEmpty,
        decoration: inputDecoration,
        child: IgnorePointer(
          child: EditableText(
            key: editTextStateKey,
            autofocus: widget.autofocus,
            controller: widget.controller,
            focusNode: widget.focusNode,
            style: widget.inputTextStyle ?? txtTheme.bodyLarge ?? const TextStyle(),
            backgroundCursorColor: colorScheme.primary,
            cursorColor: colorScheme.primary,
            onSubmitted: widget.onSubmitted,
          ),
        ),
      ),
    );
  }

  void toggleShowKeyboard(bool value) {
    setState(() {
      showKeyboard = !value;
      widget.focusNode.requestFocus();

      if (!showKeyboard) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      } else {
        editTextStateKey.currentState?.requestKeyboard();
      }
    });
  }
}

class NoKeyboardFocusNode extends FocusNode {
  @override
  bool consumeKeyboardToken() => false;
}
