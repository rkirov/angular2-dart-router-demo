library examples.src.todo.index;

import "package:angular2/angular2.dart" show bootstrap, For;
import "services/TodoStore.dart" show Store, Todo, TodoFactory;
import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show
        ReflectionCapabilities; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

@Component(selector: "todo-app", injectables: const [Store, TodoFactory])
@View(templateUrl: "todo.html", directives: const [For])
class TodoApp {
  Store todoStore;
  Todo todoEdit;
  TodoFactory factory;
  TodoApp(Store store, TodoFactory factory) {
    this.todoStore = store;
    this.todoEdit = null;
    this.factory = factory;
  }
  enterTodo($event, inputElement) {
    if (identical($event.which, 13)) {
      this.addTodo(inputElement.value);
      inputElement.value = "";
    }
  }
  editTodo(Todo todo) {
    this.todoEdit = todo;
  }
  doneEditing($event, Todo todo) {
    var which = $event.which;
    var target = $event.target;
    if (identical(which, 13)) {
      todo.title = target.value;
      this.todoEdit = null;
    } else if (identical(which, 27)) {
      this.todoEdit = null;
      target.value = todo.title;
    }
  }
  addTodo(String newTitle) {
    this.todoStore.add(this.factory.create(newTitle, false));
  }
  completeMe(Todo todo) {
    todo.completed = !todo.completed;
  }
  deleteMe(Todo todo) {
    this.todoStore.remove(todo);
  }
  toggleAll($event) {
    var isComplete = $event.target.checked;
    this.todoStore.list.forEach((todo) {
      todo.completed = isComplete;
    });
  }
  clearCompleted() {
    this.todoStore.removeBy((todo) => todo.completed);
  }
}
main() {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  bootstrap(TodoApp);
}
