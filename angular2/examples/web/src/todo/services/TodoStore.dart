library examples.src.todo.services.TodoStore;

import "package:angular2/src/di/annotations_impl.dart" show Injectable;
import "package:angular2/src/facade/collection.dart"
    show ListWrapper; // base model for RecordStore

class KeyModel {
  num key;
  KeyModel(num k) {
    this.key = k;
  }
}
class Todo extends KeyModel {
  String title;
  bool completed;
  Todo(num key, String theTitle, bool isCompleted) : super(key) {
    /* super call moved to initializer */;
    this.title = theTitle;
    this.completed = isCompleted;
  }
}
@Injectable()
class TodoFactory {
  num _uid;
  TodoFactory() {
    this._uid = 0;
  }
  nextUid() {
    this._uid = this._uid + 1;
    return this._uid;
  }
  create(String title, bool isCompleted) {
    return new Todo(this.nextUid(), title, isCompleted);
  }
} // Store manages any generic item that inherits from KeyModel
@Injectable()
class Store {
  List<KeyModel> list;
  Store() {
    this.list = [];
  }
  add(KeyModel record) {
    ListWrapper.push(this.list, record);
  }
  remove(KeyModel record) {
    this.spliceOut(record);
  }
  removeBy(Function callback) {
    var records = ListWrapper.filter(this.list, callback);
    ListWrapper.removeAll(this.list, records);
  }
  spliceOut(KeyModel record) {
    var i = this.indexFor(record);
    if (i > -1) {
      return ListWrapper.splice(this.list, i, 1)[0];
    }
    return null;
  }
  indexFor(KeyModel record) {
    return this.list.indexOf(record);
  }
}
