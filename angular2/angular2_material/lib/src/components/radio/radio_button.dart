library angular2_material.src.components.radio.radio_button;

import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, onChange;
import "package:angular2/src/core/annotations_impl/view.dart" show View;
import "package:angular2/src/core/annotations_impl/visibility.dart"
    show Parent, Ancestor;
import "package:angular2/src/core/annotations_impl/di.dart" show Attribute;
import "package:angular2/src/di/annotations_impl.dart" show Optional;
import "package:angular2_material/src/components/radio/radio_dispatcher.dart"
    show MdRadioDispatcher;
import "package:angular2/src/facade/lang.dart"
    show isPresent, StringWrapper, NumberWrapper;
import "package:angular2/src/facade/async.dart"
    show ObservableWrapper, EventEmitter;
import "package:angular2/src/facade/collection.dart" show ListWrapper;
import "package:angular2_material/src/core/constants.dart"
    show KEY_UP, KEY_DOWN, KEY_SPACE;
import "package:angular2/src/facade/browser.dart"
    show Event, KeyboardEvent; // TODO(jelbourn): Behaviors to test

// Disabled radio don't select
// Disabled radios don't propagate click event
// Radios are disabled by parent group
// Radios set default tab index iff not in parent group
// Radios are unique-select
// Radio updates parent group's value
// Change to parent group's value updates the selected child radio
// Radio name is pulled on parent group
// Radio group changes on arrow keys
// Radio group skips disabled radios on arrow keys
num _uniqueIdCounter = 0;
@Component(
    selector: "md-radio-button",
    lifecycle: const [onChange],
    properties: const {
  "id": "id",
  "name": "name",
  "value": "value",
  "checked": "checked",
  "disabled": "disabled"
},
    hostListeners: const {"keydown": "onKeydown(\$event)"},
    hostProperties: const {
  "id": "id",
  "tabindex": "tabindex",
  "role": "attr.role",
  "checked": "attr.aria-checked",
  "disabled": "attr.aria-disabled"
})
@View(
    templateUrl: "angular2_material/src/components/radio/radio_button.html",
    directives: const [])
class MdRadioButton {
  /** Whether this radio is checked. */
  bool checked; /** Whether the radio is disabled. */
  bool disabled_; /** The unique ID for the radio button. */
  String id; /** Analog to HTML 'name' attribute used to group radios for unique selection. */
  String name; /** Value assigned to this radio. Used to assign the value to the parent MdRadioGroup. */
  dynamic value; /** The parent radio group. May or may not be present. */
  MdRadioGroup radioGroup; /** Dispatcher for coordinating radio unique-selection by name. */
  MdRadioDispatcher radioDispatcher;
  num tabindex;
  String role;
  MdRadioButton(@Optional() @Parent() MdRadioGroup radioGroup,
      @Attribute("id") String id, @Attribute("tabindex") String tabindex,
      MdRadioDispatcher radioDispatcher) {
    // Assertions. Ideally these should be stripped out by the compiler.
    // TODO(jelbourn): Assert that there's no name binding AND a parent radio group.
    this.radioGroup = radioGroup;
    this.radioDispatcher = radioDispatcher;
    this.value = null;
    this.role = "radio";
    this.checked = false;
    this.id = isPresent(id) ? id : '''md-radio-${ _uniqueIdCounter ++}''';
    ; // Whenever a radio button with the same name is checked, uncheck this radio button.
    radioDispatcher.listen((name) {
      if (name == this.name) {
        this.checked = false;
      }
    }); // When this radio-button is inside of a radio-group, the group determines the name.
    if (isPresent(radioGroup)) {
      this.name = radioGroup.getName();
      this.radioGroup.register(this);
    } // If the user has not set a tabindex, default to zero (in the normal document flow).
    if (!isPresent(radioGroup)) {
      this.tabindex =
          isPresent(tabindex) ? NumberWrapper.parseInt(tabindex, 10) : 0;
    } else {
      this.tabindex = -1;
    }
  } /** Change handler invoked when bindings are resolved or when bindings have changed. */
  onChange(_) {
    if (isPresent(this.radioGroup)) {
      this.name = this.radioGroup.getName();
    }
  } /** Whether this radio button is disabled, taking the parent group into account. */
  bool isDisabled() {
    // Here, this.disabled may be true/false as the result of a binding, may be the empty string
    // if the user just adds a `disabled` attribute with no value, or may be absent completely.
    // TODO(jelbourn): If someone sets `disabled="disabled"`, will this work in dart?
    return this.disabled ||
        (isPresent(this.disabled) && StringWrapper.equals(this.disabled, "")) ||
        (isPresent(this.radioGroup) && this.radioGroup.disabled);
  }
  get disabled {
    return this.disabled_;
  }
  set disabled(value) {
    this.disabled_ = isPresent(value) && !identical(value, false);
  } /** Select this radio button. */
  select(Event event) {
    if (this.isDisabled()) {
      event.stopPropagation();
      return;
    } // Notifiy all radio buttons with the same name to un-check.
    this.radioDispatcher.notify(this.name);
    this.checked = true;
    if (isPresent(this.radioGroup)) {
      this.radioGroup.updateValue(this.value, this.id);
    }
  } /** Handles pressing the space key to select this focused radio button. */
  onKeydown(KeyboardEvent event) {
    if (event.keyCode == KEY_SPACE) {
      event.preventDefault();
      this.select(event);
    }
  }
}
@Component(
    selector: "md-radio-group",
    lifecycle: const [onChange],
    events: const ["change"],
    properties: const {"disabled": "disabled", "value": "value"},
    hostListeners: const {
  // TODO(jelbourn): Remove ^ when event retargeting is fixed.
  "^keydown": "onKeydown(\$event)"
},
    hostProperties: const {
  "tabindex": "tabindex",
  "role": "attr.role",
  "disabled": "attr.aria-disabled",
  "activedescendant": "attr.aria-activedescendant"
})
@View(templateUrl: "angular2_material/src/components/radio/radio_group.html")
class MdRadioGroup {
  /** The selected value for the radio group. The value comes from the options. */
  dynamic value; /** The HTML name attribute applied to radio buttons in this group. */
  String name_; /** Dispatcher for coordinating radio unique-selection by name. */
  MdRadioDispatcher radioDispatcher; /** List of child radio buttons. */
  List<MdRadioButton> radios_;
  dynamic activedescendant;
  bool disabled_; /** The ID of the selected radio button. */
  String selectedRadioId;
  EventEmitter change;
  num tabindex;
  String role;
  MdRadioGroup(@Attribute("tabindex") String tabindex,
      @Attribute("disabled") String disabled,
      MdRadioDispatcher radioDispatcher) {
    this.name_ = '''md-radio-group-${ _uniqueIdCounter ++}''';
    this.radios_ = [];
    this.change = new EventEmitter();
    this.radioDispatcher = radioDispatcher;
    this.selectedRadioId = "";
    this.disabled_ = false;
    this.role =
        "radiogroup"; // The simple presence of the `disabled` attribute dictates disabled state.
    this.disabled = isPresent(
        disabled); // If the user has not set a tabindex, default to zero (in the normal document flow).
    this.tabindex =
        isPresent(tabindex) ? NumberWrapper.parseInt(tabindex, 10) : 0;
  } /** Gets the name of this group, as to be applied in the HTML 'name' attribute. */
  String getName() {
    return this.name_;
  }
  get disabled {
    return this.disabled_;
  }
  set disabled(value) {
    this.disabled_ = isPresent(value) && !identical(value, false);
  } /** Change handler invoked when bindings are resolved or when bindings have changed. */
  onChange(_) {
    // If the component has a disabled attribute with no value, it will set disabled = ''.
    this.disabled = isPresent(this.disabled) &&
        !identical(this.disabled,
            false); // If the value of this radio-group has been set or changed, we have to look through the
    // child radio buttons and select the one that has a corresponding value (if any).
    if (isPresent(this.value) && this.value != "") {
      this.radioDispatcher.notify(this.name_);
      ListWrapper.forEach(this.radios_, (radio) {
        if (radio.value == this.value) {
          radio.checked = true;
          this.selectedRadioId = radio.id;
          this.activedescendant = radio.id;
        }
      });
    }
  } /** Update the value of this radio group from a child md-radio being selected. */
  updateValue(dynamic value, String id) {
    this.value = value;
    this.selectedRadioId = id;
    this.activedescendant = id;
    ObservableWrapper.callNext(this.change, null);
  } /** Registers a child radio button with this group. */
  register(MdRadioButton radio) {
    ListWrapper.push(this.radios_, radio);
  } /** Handles up and down arrow key presses to change the selected child radio. */
  onKeydown(KeyboardEvent event) {
    if (this.disabled) {
      return;
    }
    switch (event.keyCode) {
      case KEY_UP:
        this.stepSelectedRadio(-1);
        event.preventDefault();
        break;
      case KEY_DOWN:
        this.stepSelectedRadio(1);
        event.preventDefault();
        break;
    }
  } // TODO(jelbourn): Replace this with a findIndex method in the collections facade.
  num getSelectedRadioIndex() {
    for (var i = 0; i < this.radios_.length; i++) {
      if (this.radios_[i].id == this.selectedRadioId) {
        return i;
      }
    }
    return -1;
  } /** Steps the selected radio based on the given step value (usually either +1 or -1). */
  stepSelectedRadio(step) {
    var index = this.getSelectedRadioIndex() + step;
    if (index < 0 || index >= this.radios_.length) {
      return;
    }
    var radio = this.radios_[
        index]; // If the next radio is line is disabled, skip it (maintaining direction).
    if (radio.disabled) {
      this.stepSelectedRadio(step + (step < 0 ? -1 : 1));
      return;
    }
    this.radioDispatcher.notify(this.name_);
    radio.checked = true;
    ObservableWrapper.callNext(this.change, null);
    this.value = radio.value;
    this.selectedRadioId = radio.id;
    this.activedescendant = radio.id;
  }
}
