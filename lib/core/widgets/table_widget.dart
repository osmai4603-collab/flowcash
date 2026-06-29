import 'package:flowcash/core/theme_fluent/app_colors.dart';
import 'package:flutter/material.dart';

import '../theme/paddings.dart';

abstract class TableWidgetColumnWidth extends TableColumnWidth {
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;
  final double? fieldHeight;

  const TableWidgetColumnWidth({
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.all(4.0),
    this.fieldHeight,
  });
}

class FixedTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final double value;

  const FixedTableWidgetColumnWidth(
    this.value, {
    super.alignment,
    super.padding, super.fieldHeight,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value;
  }
}

class FlexTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final double value;

  const FlexTableWidgetColumnWidth(
    this.value, {
    super.alignment,
        super.padding, super.fieldHeight,
  });

  @override
  double flex(Iterable<RenderBox> cells) {
    return value;
  }

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return 0.0;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return 0.0;
  }
}

class FractionTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final double value;

  const FractionTableWidgetColumnWidth(
    this.value, {
    super.alignment,
        super.padding, super.fieldHeight,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value * containerWidth;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return value * containerWidth;
  }
}

class IntrinsicTableWidgetColumnWidth extends TableWidgetColumnWidth {
  const IntrinsicTableWidgetColumnWidth({
    super.alignment,
    super.padding, super.fieldHeight,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    double maxIntrinsicWidth = 0.0;
    for (final RenderBox cell in cells) {
      maxIntrinsicWidth = maxIntrinsicWidth > cell.getMaxIntrinsicWidth(double.infinity)
          ? maxIntrinsicWidth
          : cell.getMaxIntrinsicWidth(double.infinity);
    }
    return maxIntrinsicWidth;
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    double minIntrinsicWidth = 0.0;
    for (final RenderBox cell in cells) {
      minIntrinsicWidth = minIntrinsicWidth > cell.getMinIntrinsicWidth(double.infinity)
          ? minIntrinsicWidth
          : cell.getMinIntrinsicWidth(double.infinity);
    }
    return minIntrinsicWidth;
  }
}

class MaxTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final TableColumnWidth a;
  final TableColumnWidth b;

  const MaxTableWidgetColumnWidth(
    this.a,
    this.b, {
    super.alignment,
    super.padding,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return a.maxIntrinsicWidth(cells, containerWidth) > b.maxIntrinsicWidth(cells, containerWidth)
        ? a.maxIntrinsicWidth(cells, containerWidth)
        : b.maxIntrinsicWidth(cells, containerWidth);
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return a.minIntrinsicWidth(cells, containerWidth) > b.minIntrinsicWidth(cells, containerWidth)
        ? a.minIntrinsicWidth(cells, containerWidth)
        : b.minIntrinsicWidth(cells, containerWidth);
  }
}

class MinTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final TableColumnWidth a;
  final TableColumnWidth b;

  const MinTableWidgetColumnWidth(
    this.a,
    this.b, {
    super.alignment,
    super.padding,
  });

  @override
  double maxIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return a.maxIntrinsicWidth(cells, containerWidth) < b.maxIntrinsicWidth(cells, containerWidth)
        ? a.maxIntrinsicWidth(cells, containerWidth)
        : b.maxIntrinsicWidth(cells, containerWidth);
  }

  @override
  double minIntrinsicWidth(Iterable<RenderBox> cells, double containerWidth) {
    return a.minIntrinsicWidth(cells, containerWidth) < b.minIntrinsicWidth(cells, containerWidth)
        ? a.minIntrinsicWidth(cells, containerWidth)
        : b.minIntrinsicWidth(cells, containerWidth);
  }
}

class TableWidget<T> extends StatelessWidget {
  final Map<int, TableWidgetColumnWidth> columns;
  final void Function(T item)? onTapRow;
  final void Function(T item)? onDoubleTap;
  final void Function(T item)? onLongPressed;
  final List<Widget> Function(BuildContext context, T item, int index) builder;
  final List<String> header;
  final List<T> items;
  final double borderThickness;
  final Color? rowColor;
  final bool Function(T item, int index)? paintRowColorWhen;
  final double? minWidth;

  const TableWidget({
    super.key,
    required this.columns,
    this.onTapRow,
    this.onDoubleTap,
    this.onLongPressed,
    required this.builder,
    required this.header,
    required this.items,
    this.borderThickness = 0.50,
    this.paintRowColorWhen,
    this.rowColor,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _buildBody(context),
        ),
      ],
    );

    if (minWidth != null) {
      child = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth!),
          child: SizedBox(
            width: minWidth,
            child: child,
          ),
        ),
      );
    }

    return child;
  }

  Widget _buildHeader(BuildContext context) {
    final style = AppStyle.of(context);
    return Table(
      border: TableBorder(top: BorderSide(width: borderThickness, color: style.outline), verticalInside: BorderSide(width: borderThickness, color: style.outline), bottom: BorderSide(width: borderThickness, color: style.outline)),
      defaultVerticalAlignment: .middle,
      columnWidths: columns,
      children: [
        TableRow(
          children: header.asMap().entries.map((entry) {
            final index = entry.key;
            final title = entry.value;
            final columnWidth = columns[index];
            return Container(
              alignment: AlignmentDirectional.center,
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: style.body.copyWith(fontWeight: FontWeight.bold, fontSize: 12.50),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final style = AppStyle.of(context);
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) =>  Divider(height: 0, thickness: borderThickness, color: style.outline),
      itemBuilder: (context, indexOfRow) {
        final item = items[indexOfRow];
        final widgets = builder(context, item, indexOfRow);
        return Material(
          color: paintRowColorWhen != null
            ? (paintRowColorWhen!(item, indexOfRow) ? rowColor : null)
            : rowColor,
          child: InkWell(
            onTap: onTapRow != null ? () => onTapRow!(item) : null,
            onDoubleTap: onDoubleTap != null ? () => onDoubleTap!(item) : null,
            onLongPress: onLongPressed != null ? () => onLongPressed!(item) : null,
            child: Table(
              border: TableBorder.symmetric(inside: BorderSide(width: borderThickness, color: style.outline)),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: columns,
              children: [
                TableRow(
                  children: List.generate(columns.values.length, (indexOfField) {
                    final column = columns[indexOfField];
                    if(column == null || indexOfField >= widgets.length) {
                      return Container(
                        color: style.error,
                        height: column?.fieldHeight,
                        padding: Paddings.xsmallAll,
                        alignment: AlignmentDirectional.center,
                        child: Text(
                          'لم يتم اضافة الحقل هنا',
                          style: style.body.copyWith(color: style.onError),
                        ),
                      );
                    }
                    return Container(
                      height: column.fieldHeight,
                      padding: column.padding,
                      alignment: column.alignment,
                      child: widgets[indexOfField],
                    );
                  })
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
