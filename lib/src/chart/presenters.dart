import 'dart:ui' as ui show Offset, Paint, PaintingStyle;

import 'package:flutter/painting.dart' as painting show TextPainter;
import 'package:flutter/widgets.dart' as widgets show Widget;
import 'package:flutter/material.dart' as material;

import 'chart_options.dart';
// import 'chart_data.dart';

import 'layouters.dart';


/// todo 0 document
class LinePresenter {
  ui.Paint paint;
  ui.Offset from;
  ui.Offset to;

  LinePresenter({ui.Offset from, ui.Offset to, ui.Paint paint}) {

    this.paint = paint;
    this.paint.strokeWidth = 3.0; // todo 1 set as option
    this.from = from;
    this.to = to;
  }
}

ui.Paint gridLinesPaint(ChartOptions options) {
  ui.Paint paint = new ui.Paint();
  paint.color = options.gridLinesColor;
  paint.style = ui.PaintingStyle.stroke;
  paint.strokeWidth = 1.0;

  return paint;
}

////////////////////////////
/// Base class for
class StackableValuePointPresenter {

  StackableValuePoint valuePoint;
  StackableValuePoint nextRightColumnValuePoint;
  int rowIndex;
  ChartOptions options;

  StackableValuePointPresenter({
    StackableValuePoint valuePoint,
    StackableValuePoint nextRightColumnValuePoint,
    int rowIndex,
    ChartOptions options}) {
    this.valuePoint = valuePoint;
    this.nextRightColumnValuePoint = nextRightColumnValuePoint;
    this.rowIndex = rowIndex;
    this.options = options;
  }
}

/////////////////////////////

/// Represents the point at which data value is shown,
/// and the line from this point to the next point
/// on the right.
///
/// The line, is from this [valuePoint]
/// to the valuePoint of the PointAndLinePresenter
/// next in the [PresentersColumn]'s
/// [presenters] list.
class PointAndLinePresenter extends StackableValuePointPresenter {

  // todo 1 consider: extends StackableValuePoint / ValuePresenter

  LinePresenter linePresenter;
  ui.Offset point; // offset where the data point will be painted
  ui.Paint innerPaint;
  ui.Paint outerPaint;
  double innerRadius;
  double outerRadius;

  PointAndLinePresenter({
    StackableValuePoint valuePoint,
    StackableValuePoint nextRightColumnValuePoint,
    int rowIndex,
    LineChartOptions options,
    var pointPresenterCreator,
  })
      : super(
    valuePoint: valuePoint,
    nextRightColumnValuePoint: nextRightColumnValuePoint,
    rowIndex: rowIndex,
    options: options,
  ){

    // todo -1 move to super (shared for VerticalBar and PointAndLine)
    ui.Paint linePresenterPaint = new ui.Paint();
    linePresenterPaint.color = options.dataRowsColors[rowIndex % options.dataRowsColors.length];

    ui.Offset fromPoint = valuePoint.to;
    ui.Offset toPoint = nextRightColumnValuePoint?.to;
    toPoint ??= fromPoint;
    linePresenter = new LinePresenter(
      from: fromPoint,
      to: toPoint,
      paint: linePresenterPaint,
    );
    this.point = fromPoint; // point is the left (from) end of the line
    this.innerPaint = new ui.Paint();
    this.innerPaint.color = material.Colors.yellow;
    this.outerPaint = new ui.Paint();
    this.outerPaint.color = material.Colors.black;
    this.innerRadius = options.hotspotInnerRadius;
    this.outerRadius = options.hotspotOuterRadius;

  }
}

// todo -2 make this an actual bar presenter

class VerticalBarPresenter extends StackableValuePointPresenter {


  LinePresenter linePresenter;
  ui.Offset point;

  VerticalBarPresenter({
    StackableValuePoint valuePoint,
    StackableValuePoint nextRightColumnValuePoint,
    int rowIndex,
    LineChartOptions options})
      : super(
    valuePoint: valuePoint,
    nextRightColumnValuePoint: nextRightColumnValuePoint,
    rowIndex: rowIndex,
    options: options,
  ){

    ui.Paint linePresenterPaint = new ui.Paint();
    linePresenterPaint.color = options.dataRowsColors[rowIndex % options.dataRowsColors.length];

    ui.Offset fromPoint = valuePoint.to;
    ui.Offset toPoint = nextRightColumnValuePoint?.to;
    toPoint ??= fromPoint;
    linePresenter = new LinePresenter(
      from: fromPoint,
      to: toPoint,
      paint: linePresenterPaint,
    );
    this.point = fromPoint; // point is the left (from) end of the line

  }
}


/* todo -1 delete when extension works
class PointAndLinePresenter {

  // todo 1 consider: extends StackableValuePoint / ValuePresenter

  LinePresenter linePresenter;
  ui.Offset point; // value point
  ui.Paint innerPaint;
  ui.Paint outerPaint;
  double innerRadius;
  double outerRadius;
  ChartOptions options;

  PointAndLinePresenter({
    StackableValuePoint valuePoint,
    StackableValuePoint nextRightColumnValuePoint,
    int rowIndex,
    LineChartOptions options}) {

    ui.Paint linePresenterPaint = new ui.Paint();
    linePresenterPaint.color = options.dataRowsColors[rowIndex % options.dataRowsColors.length];

    ui.Offset fromPoint = valuePoint.to;
    ui.Offset toPoint = nextRightColumnValuePoint?.to;
    toPoint ??= fromPoint;
    linePresenter = new LinePresenter(
      from: fromPoint,
      to: toPoint,
      paint: linePresenterPaint,
    );
    this.point = fromPoint; // point is the left (from) end of the line
    this.innerPaint = new ui.Paint();
    this.innerPaint.color = material.Colors.yellow;
    this.outerPaint = new ui.Paint();
    this.outerPaint.color = material.Colors.black;
    this.innerRadius = options.hotspotInnerRadius;
    this.outerRadius = options.hotspotOuterRadius;

  }
}

class PointAndLinePresentersColumn {

// todo 1 consider: extends ValuePointsColumn / ValuePresentersColumn

  List<PointAndLinePresenter> presenters = new List();
  PointAndLinePresentersColumn nextRightPointsColumn;

  PointAndLinePresentersColumn({
    ValuePointsColumn pointsColumn,
    LineChartOptions options}) {
    // setup the contained presenters from points
    int rowIndex = 0;
    pointsColumn.stackablePoints.forEach((StackableValuePoint stackablePoint) {
      var nextRightColumnValuePoint =
      pointsColumn.nextRightPointsColumn != null ? pointsColumn.nextRightPointsColumn.stackablePoints[rowIndex] : null;

      PointAndLinePresenter presenter = new PointAndLinePresenter(
        valuePoint: stackablePoint,
        nextRightColumnValuePoint: nextRightColumnValuePoint,
        rowIndex: rowIndex,
        options: options,
      );
      this.presenters.add(presenter);
      rowIndex++;
    });

  }

}
 */

class PresentersColumn {

// todo 1 consider: extends ValuePointsColumn / ValuePresentersColumn

  List<StackableValuePointPresenter> presenters = new List();
  PresentersColumn nextRightPointsColumn; // todo -2 address the base class (not a presenter)

  PresentersColumn({
    ValuePointsColumn pointsColumn,
    LineChartOptions options,
    var pointPresenterCreator,
  }) {
    // setup the contained presenters from points
    int rowIndex = 0;
    pointsColumn.stackablePoints.forEach((StackableValuePoint stackablePoint) {
      var nextRightColumnValuePoint =
      pointsColumn.nextRightPointsColumn != null ? pointsColumn.nextRightPointsColumn.stackablePoints[rowIndex] : null;

      /* todo -2
      PointAndLinePresenter presenter = new PointAndLinePresenter(
        valuePoint: stackablePoint,
        nextRightColumnValuePoint: nextRightColumnValuePoint,
        rowIndex: rowIndex,
        options: options,
      );
      */
      StackableValuePointPresenter presenter = pointPresenterCreator(
        valuePoint: stackablePoint,
        nextRightColumnValuePoint: nextRightColumnValuePoint,
        rowIndex: rowIndex,
        options: options,
      );
      this.presenters.add(presenter);
      rowIndex++;
    });

  }

}

// todo 0 : write this in terms of abstracts, reuse implementation
class PresentersColumns {

  // todo 1 consider: extends ValuePresentersColumns or extend List

  List<PresentersColumn> presentersColumns = new List();

  PresentersColumns({
    ValuePointsColumns pointsColumns,
    LineChartOptions options,
    var pointPresenterCreator,
  }) {
    // iterate "column first", that is, over valuePointsColumns.
    PresentersColumn leftPresentersColumn = null;
    pointsColumns.pointsColumns.forEach((ValuePointsColumn pointsColumn) {
      var presentersColumn = new PresentersColumn(
        pointsColumn: pointsColumn,
        options: options,
        pointPresenterCreator: pointPresenterCreator,
      );
      presentersColumns.add(presentersColumn);
      leftPresentersColumn?.nextRightPointsColumn = presentersColumn;
      leftPresentersColumn = presentersColumn;
    });
  }

  // todo -2 move to creator of this class - to setupPresentersColumns - needs to differ between VerticalBar and PointAndLine
  // todo -2 this needs adding a param, like pointPresenterCreator
  static StackableValuePoint pointCreator(double x, double y, StackableValuePoint underThisPoint) {
    double fromY = underThisPoint == null ? 0.0 : underThisPoint.fromY; // VerticalBar: toY
    return new StackableValuePoint(x: x, y: y, stackFromY: fromY);
  }


}
