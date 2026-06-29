import 'package:flutter/material.dart';

abstract class TableWidgetColumnWidth extends TableColumnWidth {
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry padding;

  const TableWidgetColumnWidth({
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.all(8.0),
  });
}

class FixedTableWidgetColumnWidth extends TableWidgetColumnWidth {
  final double value;

  const FixedTableWidgetColumnWidth(
    this.value, {
    super.alignment,
    super.padding,
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
    super.padding,
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
    super.padding,
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
    super.padding,
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
