import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

typedef ItemToString<T extends Object> = String Function(T option);

class ComboBoxForm<T extends Object> extends StatefulWidget {
  final fluent.TextEditingController controller;
  final String? placeHolder;
  final Widget? prefix;
  final TextDirection? textDirection;
  final TextStyle? style;
  final double? cursorHeight;
  final void Function()? onEditingComplete;
  final void Function(String value)? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final bool readOnly;
  final bool autofocus;
  final void Function(T value) onSelectedItem;
  final AutocompleteOptionToString<T>? labelString;
  final AutocompleteOptionToString<T> labelMenu;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsets scrollPadding;
  final FutureOr<List<T>> Function(String value) itemsBuilder;
  final Widget? Function(T item)? itemViewBuilder;
  final int minCharsForSuggestions;
  final FormFieldValidator<String>? validator;
  final WidgetStatePropertyAll<BoxDecoration>? decoration;

  const ComboBoxForm({
    super.key,
    this.placeHolder,
    this.decoration,
    this.textDirection,
    this.style,
    this.cursorHeight,
    this.onEditingComplete,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.readOnly = false,
    this.autofocus = false,
    required this.onSelectedItem,
    this.labelString,
    required this.labelMenu,
    this.focusNode,
    this.inputFormatters,
    required this.controller,
    this.scrollPadding = const EdgeInsets.all(20.0),
    required this.itemsBuilder,
    this.itemViewBuilder,
    this.minCharsForSuggestions = 0,
    this.validator,
    this.prefix,
  }) : assert(minCharsForSuggestions >= 0);

  @override
  State<ComboBoxForm<T>> createState() => _ComboBoxFormState<T>();
}

class _ComboBoxFormState<T extends Object> extends State<ComboBoxForm<T>>
    with TickerProviderStateMixin {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<T> _suggestions = [];
  int _selectedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final _focusNode = FocusNode();

  @override
  void dispose() {
    _overlayEntry?.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      animationBehavior: AnimationBehavior.preserve,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  void _handleArrowUp() {
    if (_suggestions.isEmpty) return;
    _selectedIndex = (_selectedIndex - 1) % _suggestions.length;
    _overlayEntry?.markNeedsBuild();
  }

  void _handleArrowDown() {
    if (_suggestions.isEmpty) return;
    _selectedIndex = (_selectedIndex + 1) % _suggestions.length;
    _overlayEntry?.markNeedsBuild();
  }

  void _handleEnter() {
    if (_selectedIndex >= 0 && _selectedIndex < _suggestions.length) {
      _onSelectedItem(_suggestions[_selectedIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowUp): _handleArrowUp,
        const SingleActivator(LogicalKeyboardKey.arrowDown): _handleArrowDown,
        const SingleActivator(LogicalKeyboardKey.enter): _handleEnter,
      },
      child: Focus(
        focusNode: _focusNode,
        onFocusChange: (hasFocus) {
          if (hasFocus) return;
          _selectedIndex > -1
              ? _onSelectedItem(_suggestions[_selectedIndex])
              : _removeOverlay(useAnimation: false);
        },
        child: CompositedTransformTarget(
          link: _layerLink,
          child: fluent.TextFormBox(
            focusNode: widget.focusNode,
            controller: widget.controller,
            textDirection: widget.textDirection,
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            style: widget.style?.copyWith(fontWeight: FontWeight.bold),
            cursorHeight: widget.cursorHeight,
            decoration: widget.decoration,
            onEditingComplete: widget.onEditingComplete,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            readOnly: widget.readOnly,
            onChanged: _onTextChanged,
            inputFormatters: widget.inputFormatters,
            scrollPadding: widget.scrollPadding,
            autofocus: widget.autofocus,
            validator: widget.validator,
            placeholder: widget.placeHolder,
            prefix: widget.prefix,
          ),
        ),
      ),
    );
  }

  void _removeOverlay({bool useAnimation = true}) {
    if (_overlayEntry != null && useAnimation) _animationController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final color = ColorScheme.of(context).secondary;
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: SizeTransition(
            sizeFactor: _animation,
            child: Material(
              elevation: 5.0,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 250),
                child: ListView.separated(
                  separatorBuilder: (_, index) {
                    return Divider(thickness: 0.10, height: 1.0);
                  },
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      hoverColor: _selectedIndex == index ? color : null,
                      onTap: () => _onSelectedItem(_suggestions[index]),
                      onHover: (result) {
                        _selectedIndex = index;
                        _overlayEntry?.markNeedsBuild();
                      },
                      child: Container(
                        color: _selectedIndex == index ? color : null,
                        padding: const EdgeInsets.all(4.5),
                        child: widget.itemViewBuilder == null
                            ? fluent.Text(
                                widget.labelMenu(_suggestions[index]),
                                style: widget.style,
                              )
                            : widget.itemViewBuilder!(_suggestions[index]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSelectedItem(T item) {
    widget.controller.text = widget.labelString != null
        ? widget.labelString!(item)
        : widget.labelMenu(item);
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
    _removeOverlay(useAnimation: false);
    widget.onSelectedItem(item);
    if (widget.focusNode == null) _focusNode.unfocus();
  }

  void _onTextChanged(String value) async {
    _removeOverlay();
    if (value.isEmpty) return;
    _selectedIndex = -1;
    _suggestions = value.length >= widget.minCharsForSuggestions
        ? await widget.itemsBuilder(value)
        : [];
    if (_suggestions.isEmpty) return;
    if (_suggestions.length == 1) _selectedIndex = 0;
    // ignore: use_build_context_synchronously
    Overlay.of(context).insert(_overlayEntry = _createOverlayEntry());
    _animationController.forward();
    if (widget.onChanged != null) widget.onChanged!(value);
  }
}
