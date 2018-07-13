/// Something, Something see the licesne file.

import 'dart:math';
import 'package:angular/angular.dart';
import 'package:froobular/app_component.template.dart' as ng;

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  directives: [TableComponent, ColumnDirective],
  template: r'''
    <button (click)="addItem()">Add Item</button>
    <button (click)="removeItem()">Remove Item</button>
    <ng-table [controller]="controller">
      <div *column="let row">
        {{row.id}}
      </div>

      <div *column="let row">
        {{row.name}}
      </div>

      <div *column="let row">
        {{row.done}}
      </div>
    </ng-table >
  '''
)
class AppComponent {
  TableController<Todo> controller;
  AppComponent() {
    controller = new TableController(new List.generate(10, (_) => new Todo.random()));
  }

  void addItem() {
    controller.add(new Todo.random());
  }

  void removeItem() {
    controller.remove();
  }
}

class Todo {
  static final _generator = new Random();

  String name = '';
  int id;
  bool done;

  Todo.random() {
    id = _generator.nextInt(1000);
    done = _generator.nextBool();
    int length = _generator.nextInt(20) + 5;
    while (length > 0) {
      name += new String.fromCharCode(_generator.nextInt(200) + 40);
      length--;
    }
  }
}


@Component(
  selector: 'ng-table',
  template: r'''
    <template #ref></template>
    <ng-content></ng-content>
  ''',

)
class TableComponent implements AfterContentInit {
  TableController<Object> _controller;
  final _templates = <TemplateRef>[];


  @Input('controller')
  set controller(TableController<Object> controller) {
    if (_controller != null) {
      viewContainer.clear();
    }
    controller._table = this;
    _controller = controller;
  }

  @ViewChild('ref', read: ViewContainerRef)
  ViewContainerRef viewContainer;

  @override
  void ngAfterContentInit() {
    for (var row in _controller._data) {
      _renderRow(row);
    }
  }

  void _add(Object row) {
    _renderRow(row);
  }

  void _remove() {
    viewContainer.remove();
  }

  void _renderRow(Object row, [int index = -1]) {
    final componentRef = viewContainer.createComponent<RowComponent>(ng.RowComponentNgFactory, index);
    final container = componentRef.instance.viewContainer;
    // Template order can be specified by another source, just have them 
    // register a name or id in template.
    for (int i = 0; i < _templates.length; i++) {
      container.insertEmbeddedView(_templates[i], i)
        ..setLocal('\$implicit', row);
    }
  }
}

@Component(
  selector: 'ng-row',
  template: '<template #ref></template>',
)
class RowComponent {
  @ViewChild('ref', read: ViewContainerRef)
  ViewContainerRef viewContainer;
}


@Directive(
  selector: '[column]'
)
class ColumnDirective {
  final TemplateRef _template;
  final TableComponent _table;

  ColumnDirective(this._template, this._table) {
    _table._templates.add(_template);
  }
}

class TableController<T> {
  final List<T> _data;
  TableComponent _table;

  TableController([Iterable<T> initial = const[]])
    : _data = List.from<T>(initial);

  void add(T row) {
    _data.add(row);
    _table._add(row);
  }

  void remove() {
    _data.removeLast();
    _table._remove();
  }
}