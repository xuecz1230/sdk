// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cpu_profile_element;

import 'dart:async';
import 'dart:html';
import 'observatory_element.dart';
import 'package:observatory/service.dart';
import 'package:observatory/app.dart';
import 'package:observatory/cpu_profile.dart';
import 'package:observatory/elements.dart';
import 'package:polymer/polymer.dart';

List<String> sorted(Set<String> attributes) {
  var list = attributes.toList();
  list.sort();
  return list;
}

abstract class ProfileTreeRow<T> extends TableTreeRow {
  final CpuProfile profile;
  final T node;
  final String selfPercent;
  final String percent;
  bool _infoBoxShown = false;
  HtmlElement infoBox;
  HtmlElement infoButton;

  ProfileTreeRow(TableTree tree, TableTreeRow parent,
                 this.profile, this.node, double selfPercent, double percent)
      : super(tree, parent),
        selfPercent = Utils.formatPercentNormalized(selfPercent),
        percent = Utils.formatPercentNormalized(percent);

  static _addToMemberList(DivElement memberList, Map<String, String> items) {
    items.forEach((k, v) {
      var item = new DivElement();
      item.classes.add('memberItem');
      var name = new DivElement();
      name.classes.add('memberName');
      name.text = k;
      var value = new DivElement();
      value.classes.add('memberValue');
      value.text = v;
      item.children.add(name);
      item.children.add(value);
      memberList.children.add(item);
    });
  }

  makeInfoBox() {
    if (infoBox != null) {
      return;
    }
    infoBox = new DivElement();
    infoBox.classes.add('infoBox');
    infoBox.classes.add('shadow');
    infoBox.style.display = 'none';
    listeners.add(infoBox.onClick.listen((e) => e.stopPropagation()));
  }

  makeInfoButton() {
    infoButton = new SpanElement();
    infoButton.style.marginLeft = 'auto';
    infoButton.style.marginRight = '1em';
    infoButton.children.add(new Element.tag('icon-info-outline'));
    listeners.add(infoButton.onClick.listen((event) {
      event.stopPropagation();
      toggleInfoBox();
    }));
  }

  static const attributes = const {
    'optimized' : const ['O', null, 'Optimized'],
    'unoptimized' : const ['U', null, 'Unoptimized'],
    'inlined' : const ['I', null, 'Inlined'],
    'dart' : const ['D', null, 'Dart'],
    'tag' : const ['T', null, 'Tag'],
    'native' : const ['N', null, 'Native'],
    'stub': const ['S', null, 'Stub'],
    'synthetic' : const ['?', null, 'Synthetic'],
  };

  HtmlElement newAttributeBox(String attribute) {
    List attributeDetails = attributes[attribute];
    if (attributeDetails == null) {
      print('could not find attribute $attribute');
      return null;
    }
    var element = new SpanElement();
    element.style.border = 'solid 2px #ECECEC';
    element.style.height = '100%';
    element.style.display = 'inline-block';
    element.style.textAlign = 'center';
    element.style.minWidth = '1.5em';
    element.style.fontWeight = 'bold';
    if (attributeDetails[1] != null) {
      element.style.backgroundColor = attributeDetails[1];
    }
    element.text = attributeDetails[0];
    element.title = attributeDetails[2];
    return element;
  }

  onHide() {
    super.onHide();
    infoBox = null;
    infoButton = null;
  }

  showInfoBox() {
    if ((infoButton == null) || (infoBox == null)) {
      return;
    }
    _infoBoxShown = true;
    infoBox.style.display = 'block';
    infoButton.children.clear();
    infoButton.children.add(new Element.tag('icon-info'));
  }

  hideInfoBox() {
    _infoBoxShown = false;
    if ((infoButton == null) || (infoBox == null)) {
      return;
    }
    infoBox.style.display = 'none';
    infoButton.children.clear();
    infoButton.children.add(new Element.tag('icon-info-outline'));
  }

  toggleInfoBox() {
   if (_infoBoxShown) {
     hideInfoBox();
   } else {
     showInfoBox();
   }
  }

  hideAllInfoBoxes() {
    final List<ProfileTreeRow> rows = tree.rows;
    for (var row in rows) {
      row.hideInfoBox();
    }
  }

  onClick(MouseEvent e) {
    e.stopPropagation();
    if (e.altKey) {
      bool show = !_infoBoxShown;
      hideAllInfoBoxes();
      if (show) {
        showInfoBox();
      }
      return;
    }
    super.onClick(e);
  }

  HtmlElement newCodeRef(ProfileCode code) {
    var codeRef = new Element.tag('code-ref');
    codeRef.ref = code.code;
    return codeRef;
  }

  HtmlElement newFunctionRef(ProfileFunction function) {
    var ref = new Element.tag('function-ref');
    ref.ref = function.function;
    return ref;
  }

  HtmlElement hr() {
    var element = new HRElement();
    return element;
  }

  HtmlElement div(String text) {
    var element = new DivElement();
    element.text = text;
    return element;
  }

  HtmlElement br() {
    return new BRElement();
  }

  HtmlElement span(String text) {
    var element = new SpanElement();
    element.style.minWidth = '1em';
    element.text = text;
    return element;
  }
}

class CodeProfileTreeRow extends ProfileTreeRow<CodeCallTreeNode> {
  CodeProfileTreeRow(TableTree tree, CodeProfileTreeRow parent,
                     CpuProfile profile, CodeCallTreeNode node)
      : super(tree, parent, profile, node,
              node.profileCode.normalizedExclusiveTicks,
              node.percentage) {
    // fill out attributes.
  }

  bool hasChildren() => node.children.length > 0;

  void onShow() {
    super.onShow();

    if (children.length == 0) {
      for (var childNode in node.children) {
        var row = new CodeProfileTreeRow(tree, this, profile, childNode);
        children.add(row);
      }
    }

    // Fill in method column.
    var methodColumn = flexColumns[0];
    methodColumn.style.justifyContent = 'flex-start';
    methodColumn.style.position = 'relative';

    // Percent.
    var percentNode = new DivElement();
    percentNode.text = percent;
    percentNode.style.minWidth = '5em';
    percentNode.style.textAlign = 'right';
    percentNode.title = 'Executing: $selfPercent';
    methodColumn.children.add(percentNode);

    // Gap.
    var gap = new SpanElement();
    gap.style.minWidth = '1em';
    methodColumn.children.add(gap);

    // Code link.
    var codeRef = newCodeRef(node.profileCode);
    codeRef.style.alignSelf = 'center';
    methodColumn.children.add(codeRef);

    gap = new SpanElement();
    gap.style.minWidth = '1em';
    methodColumn.children.add(gap);

    for (var attribute in sorted(node.attributes)) {
      methodColumn.children.add(newAttributeBox(attribute));
    }

    makeInfoBox();
    methodColumn.children.add(infoBox);

    infoBox.children.add(span('Code '));
    infoBox.children.add(newCodeRef(node.profileCode));
    infoBox.children.add(span(' '));
    for (var attribute in sorted(node.profileCode.attributes)) {
      infoBox.children.add(newAttributeBox(attribute));
    }
    infoBox.children.add(br());
    infoBox.children.add(br());
    var memberList = new DivElement();
    memberList.classes.add('memberList');
    infoBox.children.add(br());
    infoBox.children.add(memberList);
    ProfileTreeRow._addToMemberList(memberList, {
        'Exclusive ticks' : node.profileCode.formattedExclusiveTicks,
        'Cpu time' : node.profileCode.formattedCpuTime,
        'Inclusive ticks' : node.profileCode.formattedInclusiveTicks,
        'Call stack time' : node.profileCode.formattedOnStackTime,
    });

    makeInfoButton();
    methodColumn.children.add(infoButton);

    // Fill in self column.
    var selfColumn = flexColumns[1];
    selfColumn.style.position = 'relative';
    selfColumn.style.alignItems = 'center';
    selfColumn.text = selfPercent;
  }
}

class FunctionProfileTreeRow extends ProfileTreeRow<FunctionCallTreeNode> {
  FunctionProfileTreeRow(TableTree tree, FunctionProfileTreeRow parent,
                         CpuProfile profile, FunctionCallTreeNode node)
      : super(tree, parent, profile, node,
              node.profileFunction.normalizedExclusiveTicks,
              node.percentage) {
    // fill out attributes.
  }

  bool hasChildren() => node.children.length > 0;

  onShow() {
    super.onShow();
    if (children.length == 0) {
      for (var childNode in node.children) {
        var row = new FunctionProfileTreeRow(tree, this, profile, childNode);
        children.add(row);
      }
    }

    var methodColumn = flexColumns[0];
    methodColumn.style.justifyContent = 'flex-start';

    var codeAndFunctionColumn = new DivElement();
    codeAndFunctionColumn.classes.add('flex-column');
    codeAndFunctionColumn.style.justifyContent = 'center';
    codeAndFunctionColumn.style.width = '100%';
    methodColumn.children.add(codeAndFunctionColumn);

    var functionRow = new DivElement();
    functionRow.classes.add('flex-row');
    functionRow.style.position = 'relative';
    functionRow.style.justifyContent = 'flex-start';
    codeAndFunctionColumn.children.add(functionRow);

    // Insert the parent percentage
    var parentPercent = new SpanElement();
    parentPercent.text = percent;
    parentPercent.style.minWidth = '4em';
    parentPercent.style.alignSelf = 'center';
    parentPercent.style.textAlign = 'right';
    parentPercent.title = 'Executing: $selfPercent';
    functionRow.children.add(parentPercent);

    // Gap.
    var gap = new SpanElement();
    gap.style.minWidth = '1em';
    gap.text = ' ';
    functionRow.children.add(gap);

    var functionRef = new Element.tag('function-ref');
    functionRef.ref = node.profileFunction.function;
    functionRef.style.alignSelf = 'center';
    functionRow.children.add(functionRef);

    gap = new SpanElement();
    gap.style.minWidth = '1em';
    gap.text = ' ';
    functionRow.children.add(gap);

    for (var attribute in sorted(node.attributes)) {
      functionRow.children.add(newAttributeBox(attribute));
    }

    makeInfoBox();
    functionRow.children.add(infoBox);

    if (node.profileFunction.function.kind.hasDartCode()) {
      infoBox.children.add(div('Code for current node'));
      infoBox.children.add(br());
      var totalTicks = node.totalCodesTicks;
      var numCodes = node.codes.length;
      for (var i = 0; i < numCodes; i++) {
        var codeRowSpan = new DivElement();
        codeRowSpan.style.paddingLeft = '1em';
        infoBox.children.add(codeRowSpan);
        var nodeCode = node.codes[i];
        var ticks = nodeCode.ticks;
        var percentage = Utils.formatPercent(ticks, totalTicks);
        var percentageSpan = new SpanElement();
        percentageSpan.style.display = 'inline-block';
        percentageSpan.text = '$percentage';
        percentageSpan.style.minWidth = '5em';
        percentageSpan.style.textAlign = 'right';
        codeRowSpan.children.add(percentageSpan);
        var codeRef = new Element.tag('code-ref');
        codeRef.ref = nodeCode.code.code;
        codeRef.style.marginLeft = '1em';
        codeRef.style.marginRight = 'auto';
        codeRef.style.width = '100%';
        codeRowSpan.children.add(codeRef);
      }
      infoBox.children.add(hr());
    }
    infoBox.children.add(span('Function '));
    infoBox.children.add(newFunctionRef(node.profileFunction));
    infoBox.children.add(span(' '));
    for (var attribute in sorted(node.profileFunction.attributes)) {
      infoBox.children.add(newAttributeBox(attribute));
    }
    var memberList = new DivElement();
    memberList.classes.add('memberList');
    infoBox.children.add(br());
    infoBox.children.add(br());
    infoBox.children.add(memberList);
    infoBox.children.add(br());
    ProfileTreeRow._addToMemberList(memberList, {
        'Exclusive ticks' : node.profileFunction.formattedExclusiveTicks,
        'Cpu time' : node.profileFunction.formattedCpuTime,
        'Inclusive ticks' : node.profileFunction.formattedInclusiveTicks,
        'Call stack time' : node.profileFunction.formattedOnStackTime,
    });

    if (node.profileFunction.function.kind.hasDartCode()) {
      infoBox.children.add(div('Code containing function'));
      infoBox.children.add(br());
      var totalTicks = profile.sampleCount;
      var codes = node.profileFunction.profileCodes;
      var numCodes = codes.length;
      for (var i = 0; i < numCodes; i++) {
        var codeRowSpan = new DivElement();
        codeRowSpan.style.paddingLeft = '1em';
        infoBox.children.add(codeRowSpan);
        var profileCode = codes[i];
        var code = profileCode.code;
        var ticks = profileCode.inclusiveTicks;
        var percentage = Utils.formatPercent(ticks, totalTicks);
        var percentageSpan = new SpanElement();
        percentageSpan.style.display = 'inline-block';
        percentageSpan.text = '$percentage';
        percentageSpan.style.minWidth = '5em';
        percentageSpan.style.textAlign = 'right';
        percentageSpan.title = 'Inclusive ticks';
        codeRowSpan.children.add(percentageSpan);
        var codeRef = new Element.tag('code-ref');
        codeRef.ref = code;
        codeRef.style.marginLeft = '1em';
        codeRef.style.marginRight = 'auto';
        codeRef.style.width = '100%';
        codeRowSpan.children.add(codeRef);
      }
    }

    makeInfoButton();
    methodColumn.children.add(infoButton);

    // Fill in self column.
    var selfColumn = flexColumns[1];
    selfColumn.style.position = 'relative';
    selfColumn.style.alignItems = 'center';
    selfColumn.text = selfPercent;
  }
}

/// Displays a CpuProfile
@CustomTag('cpu-profile')
class CpuProfileElement extends ObservatoryElement {
  static const MICROSECONDS_PER_SECOND = 1000000.0;

  @published Isolate isolate;
  @observable String sampleCount = '';
  @observable String refreshTime = '';
  @observable String sampleRate = '';
  @observable String stackDepth = '';
  @observable String timeSpan = '';
  @observable String fetchTime = '';
  @observable String loadTime = '';
  @observable String tagSelector = 'UserVM';
  @observable String modeSelector = 'Function';
  @observable String directionSelector = 'Up';

  @observable String state = 'Requested';
  @observable var exception;
  @observable var stackTrace;

  final Stopwatch _sw = new Stopwatch();

  final CpuProfile profile = new CpuProfile();

  CpuProfileElement.created() : super.created();

  @override
  void attached() {
    super.attached();
  }

  void isolateChanged(oldValue) {
    _getCpuProfile().catchError(app.handleException);
  }

  void tagSelectorChanged(oldValue) {
    _getCpuProfile().catchError(app.handleException);
  }

  void modeSelectorChanged(oldValue) {
    _updateView();
  }

  void directionSelectorChanged(oldValue) {
    _updateView();
  }

  Future clearCpuProfile() {
    profile.clear();
    if (isolate == null) {
      return new Future.value(null);
    }
    return isolate.invokeRpc('_clearCpuProfile', { })
        .then((ServiceMap response) {
          _updateView();
        });
  }

  Future refresh() {
    return _getCpuProfile();
  }

  _onFetchStarted() {
    _sw.reset();
    _sw.start();
    state = 'Requested';
  }

  _onFetchFinished() {
    _sw.stop();
    fetchTime = formatTimeMilliseconds(_sw.elapsedMilliseconds);
  }

  Future _onLoadStarted() {
    _sw.reset();
    _sw.start();
    state = 'Loading';
    return window.animationFrame;
  }

  _onLoadFinished() {
    _sw.stop();
    loadTime = formatTimeMilliseconds(_sw.elapsedMilliseconds);
    state = 'Loaded';
  }

  Future _getCpuProfile() async {
    profile.clear();
    if (isolate == null) {
      return new Future.value(null);
    }
    _onFetchStarted();
    try {
      var params = { 'tags': tagSelector };
      var response = await isolate.invokeRpc('_getCpuProfile', params);
      _onFetchFinished();
      await _onLoadStarted();
      profile.load(isolate, response);
      _onLoadFinished();
      _updateView();
    } catch (e, st) {
      bool handled = false;
      if (e is ServerRpcException) {
        ServerRpcException se = e;
        if (se.code == ServerRpcException.kFeatureDisabled) {
          state = 'Disabled';
          handled = true;
        }
      }
      if (!handled) {
        state = 'Exception';
        exception = e;
        stackTrace = st;
        rethrow;
      }
    }
  }

  void _updateView() {
    sampleCount = profile.sampleCount.toString();
    refreshTime = new DateTime.now().toString();
    stackDepth = profile.stackDepth.toString();
    sampleRate = profile.sampleRate.toStringAsFixed(0);
    timeSpan = formatTime(profile.timeSpan);
    CpuProfileTreeElement cpuProfileTreeElement =
        shadowRoot.querySelector('#cpuProfileTree');
    ProfileTreeDirection direction = ProfileTreeDirection.Exclusive;
    if (directionSelector != 'Up') {
      direction = ProfileTreeDirection.Inclusive;
    }
    ProfileTreeMode mode = ProfileTreeMode.Function;
    if (modeSelector == 'Code') {
      mode = ProfileTreeMode.Code;
    }
    cpuProfileTreeElement.profile = profile;
    cpuProfileTreeElement.direction = direction;
    cpuProfileTreeElement.mode = mode;
    cpuProfileTreeElement.render();
  }
}

class NameSortedTable extends SortedTable {
  NameSortedTable(columns) : super(columns);
  @override
  dynamic getSortKeyFor(int row, int col) {
    if (col == FUNCTION_COLUMN) {
      // Use name as sort key.
      return rows[row].values[col].name;
    }
    return super.getSortKeyFor(row, col);
  }

  SortedTableRow rowFromIndex(int tableIndex) {
    final modelIndex = sortedRows[tableIndex];
    return rows[modelIndex];
  }

  static const FUNCTION_SPACER_COLUMNS = const [];
  static const FUNCTION_COLUMN = 2;
  TableRowElement _makeFunctionRow() {
    var tr = new TableRowElement();
    var cell;

    // Add percentage.
    cell = tr.insertCell(-1);
    cell = tr.insertCell(-1);

    // Add function ref.
    cell = tr.insertCell(-1);
    var functionRef = new Element.tag('function-ref');
    cell.children.add(functionRef);

    return tr;
  }

  static const CALL_SPACER_COLUMNS = const [];
  static const CALL_FUNCTION_COLUMN = 1;
  TableRowElement _makeCallRow() {
    var tr = new TableRowElement();
    var cell;

    // Add percentage.
    cell = tr.insertCell(-1);
    // Add function ref.
    cell = tr.insertCell(-1);
    var functionRef = new Element.tag('function-ref');
    cell.children.add(functionRef);
    return tr;
  }

  _updateRow(TableRowElement tr,
             int rowIndex,
             List spacerColumns,
             int refColumn) {
    var row = rows[rowIndex];
    // Set reference
    var ref = tr.children[refColumn].children[0];
    ref.ref = row.values[refColumn];

    for (var i = 0; i < row.values.length; i++) {
      if (spacerColumns.contains(i) || (i == refColumn)) {
        // Skip spacer columns.
        continue;
      }
      var cell = tr.children[i];
      cell.title = row.values[i].toString();
      cell.text = getFormattedValue(rowIndex, i);
    }
  }

  _updateTableView(HtmlElement table,
                   HtmlElement makeEmptyRow(),
                   void onRowClick(TableRowElement tr),
                   List spacerColumns,
                   int refColumn) {
    assert(table != null);

    // Resize DOM table.
    if (table.children.length > sortedRows.length) {
      // Shrink the table.
      var deadRows = table.children.length - sortedRows.length;
      for (var i = 0; i < deadRows; i++) {
        table.children.removeLast();
      }
    } else if (table.children.length < sortedRows.length) {
      // Grow table.
      var newRows = sortedRows.length - table.children.length;
      for (var i = 0; i < newRows; i++) {
        var row = makeEmptyRow();
        row.onClick.listen((e) {
          e.stopPropagation();
          e.preventDefault();
          onRowClick(row);
        });
        table.children.add(row);
      }
    }

    assert(table.children.length == sortedRows.length);

    // Fill table.
    for (var i = 0; i < sortedRows.length; i++) {
      var rowIndex = sortedRows[i];
      var tr = table.children[i];
      _updateRow(tr, rowIndex, spacerColumns, refColumn);
    }
  }
}

@CustomTag('cpu-profile-table')
class CpuProfileTableElement extends ObservatoryElement {
  final Stopwatch _sw = new Stopwatch();
  final CpuProfile profile = new CpuProfile();
  StreamSubscription _resizeSubscription;
  @observable NameSortedTable profileTable;
  @observable NameSortedTable profileCallersTable;
  @observable NameSortedTable profileCalleesTable;
  @observable ServiceFunction focusedFunction;
  @observable int focusedRow;
  @observable String fetchTime = '';
  @observable String loadTime = '';
  @observable String state = 'Requested';
  @observable var exception;
  @observable var stackTrace;
  @observable Isolate isolate;
  @observable String sampleCount = '';
  @observable String refreshTime = '';
  @observable String sampleRate = '';
  @observable String stackDepth = '';
  @observable String timeSpan = '';
  @observable String directionSelector = 'Up';

  CpuProfileTableElement.created() : super.created() {
    var columns = [
        new SortedTableColumn.withFormatter('Executing (%)',
                                            Utils.formatPercentNormalized),
        new SortedTableColumn.withFormatter('In stack (%)',
                                            Utils.formatPercentNormalized),
        new SortedTableColumn('Method'),
    ];
    profileTable = new NameSortedTable(columns);
    profileTable.sortColumnIndex = 0;

    columns = [
        new SortedTableColumn.withFormatter('Callees (%)',
                                            Utils.formatPercentNormalized),
        new SortedTableColumn('Method')
    ];
    profileCalleesTable = new NameSortedTable(columns);
    profileCalleesTable.sortColumnIndex = 0;

    columns = [
        new SortedTableColumn.withFormatter('Callers (%)',
                                            Utils.formatPercentNormalized),
        new SortedTableColumn('Method')
    ];
    profileCallersTable = new NameSortedTable(columns);
    profileCallersTable.sortColumnIndex = 0;
  }

  attached() {
    super.attached();
    _resizeSubscription = window.onResize.listen((_) => _updateSize());
    _updateSize();
  }

  detached() {
    super.detached();
    if (_resizeSubscription != null) {
      _resizeSubscription.cancel();
    }
  }

  _updateSize() {
    HtmlElement e = $['main'];
    final totalHeight = window.innerHeight;
    final top = e.offset.top;
    final bottomMargin = 32;
    final mainHeight = totalHeight - top - bottomMargin;
    e.style.setProperty('height', '${mainHeight}px');
  }

  isolateChanged() {
    _getCpuProfile()
      .catchError(app.handleException)
      .whenComplete(checkParameters);
  }

  checkParameters() {
    var functionId = app.locationManager.uri.queryParameters['functionId'];
    if (functionId == null) {
      _focusOnFunction(null);
      return;
    }
    if (isolate == null) {
      return;
    }
    isolate.getObject(functionId).then((func) => _focusOnFunction(func));
  }

  void directionSelectorChanged(oldValue) {
    _updateFunctionTreeView();
  }

  Future refresh() {
    return _getCpuProfile();
  }

  _onFetchStarted() {
    _sw.reset();
    _sw.start();
    state = 'Requested';
  }

  _onFetchFinished() {
    _sw.stop();
    fetchTime = formatTimeMilliseconds(_sw.elapsedMilliseconds);
  }

  _onLoadStarted() {
    _sw.reset();
    _sw.start();
    state = 'Loading';
  }

  _onLoadFinished() {
    _sw.stop();
    loadTime = formatTimeMilliseconds(_sw.elapsedMilliseconds);
    state = 'Loaded';
  }

  Future clearCpuProfile() {
    profile.clear();
    _clearView();
    if (isolate == null) {
      return new Future.value(null);
    }
    return isolate.invokeRpc('_clearCpuProfile', { })
    .then((ServiceMap response) {
      _updateView();
    });
  }

  Future _getCpuProfile() async {
    profile.clear();
    _clearView();
    if (isolate == null) {
      return new Future.value(null);
    }
    _onFetchStarted();
    try {
      var params = { 'tags': 'None' };
      var response = await isolate.invokeRpc('_getCpuProfile', params);
      _onFetchFinished();
      _onLoadStarted();
      profile.load(isolate, response);
      profile.buildFunctionCallerAndCallees();
      _onLoadFinished();
      _updateView();
    } catch (e, st) {
      bool handled = false;
      if (e is ServerRpcException) {
        ServerRpcException se = e;
        if (se.code == ServerRpcException.kFeatureDisabled) {
          state = 'Disabled';
          handled = true;
        }
      }
      if (!handled) {
        state = 'Exception';
        exception = e;
        stackTrace = st;
        rethrow;
      }
    }
  }

  _clearView() {
    profileTable.clearRows();
    _renderTable();
  }

  _updateView() {
    sampleCount = profile.sampleCount.toString();
    refreshTime = new DateTime.now().toString();
    stackDepth = profile.stackDepth.toString();
    sampleRate = profile.sampleRate.toStringAsFixed(0);
    timeSpan = formatTime(profile.timeSpan);
    _buildFunctionTable();
    _renderTable();
    _updateFunctionTreeView();
  }

  int _findFunctionRow(ServiceFunction function) {
    for (var i = 0; i < profileTable.sortedRows.length; i++) {
      var rowIndex = profileTable.sortedRows[i];
      var row = profileTable.rows[rowIndex];
      if (row.values[NameSortedTable.FUNCTION_COLUMN] == function) {
        return i;
      }
    }
    return -1;
  }

  _scrollToFunction(ServiceFunction function) {
    TableSectionElement tableBody = $['profile-table'];
    var row = _findFunctionRow(function);
    if (row == -1) {
      return;
    }
    tableBody.children[row].classes.remove('shake');
    // trigger reflow.
    tableBody.children[row].offsetHeight;
    tableBody.children[row].scrollIntoView(ScrollAlignment.CENTER);
    tableBody.children[row].classes.add('shake');
  }

  _clearFocusedFunction() {
    TableSectionElement tableBody = $['profile-table'];
    // Clear current focus.
    if (focusedRow != null) {
      tableBody.children[focusedRow].classes.remove('focused');
    }
    focusedRow = null;
    focusedFunction = null;
  }

  _focusOnFunction(ServiceFunction function) {
    if (focusedFunction == function) {
      // Do nothing.
      return;
    }

    _clearFocusedFunction();

    if (function == null) {
      _updateFunctionTreeView();
      _clearCallTables();
      return;
    }

    var row = _findFunctionRow(function);
    if (row == -1) {
      _updateFunctionTreeView();
      _clearCallTables();
      return;
    }

    focusedRow = row;
    focusedFunction = function;

    TableSectionElement tableBody = $['profile-table'];
    tableBody.children[focusedRow].classes.add('focused');
    _updateFunctionTreeView();
    _buildCallersTable(focusedFunction);
    _buildCalleesTable(focusedFunction);
  }

  _onRowClick(TableRowElement tr) {
    var tableBody = $['profile-table'];
    var row = profileTable.rowFromIndex(tableBody.children.indexOf(tr));
    var function = row.values[NameSortedTable.FUNCTION_COLUMN];
    app.locationManager.goReplacingParameters(
        {
          'functionId': function.id
        }
    );
  }

  _renderTable() {
    profileTable._updateTableView($['profile-table'],
                                  profileTable._makeFunctionRow,
                                  _onRowClick,
                                  NameSortedTable.FUNCTION_SPACER_COLUMNS,
                                  NameSortedTable.FUNCTION_COLUMN);
  }

  _buildFunctionTable() {
    for (var func in profile.functions) {
      if ((func.exclusiveTicks == 0) && (func.inclusiveTicks == 0)) {
        // Skip.
        continue;
      }
      var row = [
        func.normalizedExclusiveTicks,
        func.normalizedInclusiveTicks,
        func.function,
      ];
      profileTable.addRow(new SortedTableRow(row));
    }
    profileTable.sort();
  }

  _renderCallTable(TableSectionElement view,
                   NameSortedTable model,
                   void onRowClick(TableRowElement tr)) {
    model._updateTableView(view,
                           model._makeCallRow,
                           onRowClick,
                           NameSortedTable.CALL_SPACER_COLUMNS,
                           NameSortedTable.CALL_FUNCTION_COLUMN);
  }

  _buildCallTable(Map<ProfileFunction, int> calls,
                  NameSortedTable model) {
    model.clearRows();
    if (calls == null) {
      return;
    }
    var sum = 0;
    calls.values.forEach((i) => sum += i);
    calls.forEach((func, count) {
      var row = [
          count / sum,
          func.function,
      ];
      model.addRow(new SortedTableRow(row));
    });
    model.sort();
  }

  _clearCallTables() {
    _buildCallersTable(null);
    _buildCalleesTable(null);
  }

  _onCallersClick(TableRowElement tr) {
    var table = $['callers-table'];
    final row = profileCallersTable.rowFromIndex(table.children.indexOf(tr));
    var function = row.values[NameSortedTable.CALL_FUNCTION_COLUMN];
    _scrollToFunction(function);
  }

  _buildCallersTable(ServiceFunction function) {
    var calls = (function != null) ? function.profile.callers : null;
    var table = $['callers-table'];
    _buildCallTable(calls, profileCallersTable);
    _renderCallTable(table, profileCallersTable, _onCallersClick);
  }

  _onCalleesClick(TableRowElement tr) {
    var table = $['callees-table'];
    final row = profileCalleesTable.rowFromIndex(table.children.indexOf(tr));
    var function = row.values[NameSortedTable.CALL_FUNCTION_COLUMN];
    _scrollToFunction(function);
  }

  _buildCalleesTable(ServiceFunction function) {
    var calls = (function != null) ? function.profile.callees : null;
    var table = $['callees-table'];
    _buildCallTable(calls, profileCalleesTable);
    _renderCallTable(table, profileCalleesTable, _onCalleesClick);
  }

  _changeSort(Element target, NameSortedTable table) {
    if (target is TableCellElement) {
      if (table.sortColumnIndex != target.cellIndex) {
        table.sortColumnIndex = target.cellIndex;
        table.sortDescending = true;
      } else {
        table.sortDescending = !profileTable.sortDescending;
      }
      table.sort();
    }
  }

  changeSortProfile(Event e, var detail, Element target) {
    _changeSort(target, profileTable);
    _renderTable();
  }

  changeSortCallers(Event e, var detail, Element target) {
    _changeSort(target, profileCallersTable);
    _renderCallTable($['callers-table'], profileCallersTable, _onCallersClick);
  }

  changeSortCallees(Event e, var detail, Element target) {
    _changeSort(target, profileCalleesTable);
    _renderCallTable($['callees-table'], profileCalleesTable, _onCalleesClick);
  }

  //////
  ///
  /// Function tree.
  ///
  TableTree functionTree;
  _updateFunctionTreeView() {
    CpuProfileTreeElement cpuProfileTreeElement =
        shadowRoot.querySelector('#cpuProfileTree');
    ProfileTreeDirection direction = ProfileTreeDirection.Exclusive;
    if (directionSelector != 'Up') {
      direction = ProfileTreeDirection.Inclusive;
    }
    ProfileTreeMode mode = ProfileTreeMode.Function;
    cpuProfileTreeElement.profile = profile;
    cpuProfileTreeElement.direction = direction;
    cpuProfileTreeElement.mode = mode;
    cpuProfileTreeElement.functionFilter = (FunctionCallTreeNode node) {
      return node.profileFunction.function == focusedFunction;
    };
    cpuProfileTreeElement.render();
  }
}

enum ProfileTreeDirection {
  Exclusive,
  Inclusive
}

enum ProfileTreeMode {
  Code,
  Function,
}

@CustomTag('cpu-profile-tree')
class CpuProfileTreeElement extends ObservatoryElement {
  ProfileTreeDirection direction = ProfileTreeDirection.Exclusive;
  ProfileTreeMode mode = ProfileTreeMode.Function;
  CpuProfile profile;
  TableTree codeTree;
  TableTree functionTree;
  FunctionCallTreeNodeFilter functionFilter;

  CpuProfileTreeElement.created() : super.created();

  void render() {
    _updateView();
  }

  void _updateView() {
    if (functionTree != null) {
      functionTree.clear();
      functionTree = null;
    }
    if (codeTree != null) {
      codeTree.clear();
      codeTree = null;
    }
    bool exclusive = direction == ProfileTreeDirection.Exclusive;
    if (mode == ProfileTreeMode.Code) {
      _buildCodeTree(exclusive);
    } else {
      assert(mode == ProfileTreeMode.Function);
      _buildFunctionTree(exclusive);
    }
  }

  void _buildFunctionTree(bool exclusive) {
    if (functionTree == null) {
      var tableBody = shadowRoot.querySelector('#treeBody');
      assert(tableBody != null);
      functionTree = new TableTree(tableBody, 2);
    }
    if (profile == null) {
      return;
    }
    var tree = profile.loadFunctionTree(exclusive ? 'exclusive' : 'inclusive');
    if (tree == null) {
      return;
    }
    if (functionFilter != null) {
      tree = tree.filtered(functionFilter);
    }
    var rootRow =
        new FunctionProfileTreeRow(functionTree, null, profile, tree.root);
    functionTree.initialize(rootRow);
  }

  void _buildCodeTree(bool exclusive) {
    if (codeTree == null) {
      var tableBody = shadowRoot.querySelector('#treeBody');
      assert(tableBody != null);
      codeTree = new TableTree(tableBody, 2);
    }
    if (profile == null) {
      return;
    }
    var tree = profile.loadCodeTree(exclusive ? 'exclusive' : 'inclusive');
    if (tree == null) {
      return;
    }
    var rootRow = new CodeProfileTreeRow(codeTree, null, profile, tree.root);
    codeTree.initialize(rootRow);
  }
}
