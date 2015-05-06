library benchmarks.src.naive_infinite_scroll.cells;

import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper;
import "common.dart"
    show Company, Opportunity, Offering, Account, CustomDate, STATUS_LIST;
import "package:angular2/directives.dart"
    show
        For; // TODO(radokirov): Once the application is transpiled by TS instead of Traceur,
// add those imports back into 'angular2/angular2';
import "package:angular2/src/core/annotations_impl/annotations.dart"
    show Component, Directive;
import "package:angular2/src/core/annotations_impl/view.dart" show View;

class HasStyle {
  Map style;
  HasStyle() {
    this.style = MapWrapper.create();
  }
  set width(w) {
    MapWrapper.set(this.style, "width", w);
  }
}
@Component(
    selector: "company-name",
    properties: const {"width": "cell-width", "company": "company"})
@View(
    directives: const [],
    template: '''<div [style]="style">{{company.name}}</div>''')
class CompanyNameComponent extends HasStyle {
  Company company;
}
@Component(
    selector: "opportunity-name",
    properties: const {"width": "cell-width", "opportunity": "opportunity"})
@View(
    directives: const [],
    template: '''<div [style]="style">{{opportunity.name}}</div>''')
class OpportunityNameComponent extends HasStyle {
  Opportunity opportunity;
}
@Component(
    selector: "offering-name",
    properties: const {"width": "cell-width", "offering": "offering"})
@View(
    directives: const [],
    template: '''<div [style]="style">{{offering.name}}</div>''')
class OfferingNameComponent extends HasStyle {
  Offering offering;
}
class Stage {
  String name;
  bool isDisabled;
  Map style;
  Function apply;
}
@Component(
    selector: "stage-buttons",
    properties: const {"width": "cell-width", "offering": "offering"})
@View(directives: const [For], template: '''
      <div [style]="style">
          <button template="for #stage of stages"
                  [disabled]="stage.isDisabled"
                  [style]="stage.style"
                  on-click="setStage(stage)">
            {{stage.name}}
          </button>
      </div>''')
class StageButtonsComponent extends HasStyle {
  Offering _offering;
  List<Stage> stages;
  Offering get offering {
    return this._offering;
  }
  set offering(Offering offering) {
    this._offering = offering;
    this._computeStageButtons();
  }
  setStage(Stage stage) {
    this._offering.status = stage.name;
    this._computeStageButtons();
  }
  _computeStageButtons() {
    var disabled = true;
    this.stages = ListWrapper.clone(STATUS_LIST.map((status) {
      var isCurrent = this._offering.status == status;
      var stage = new Stage();
      stage.name = status;
      stage.isDisabled = disabled;
      var stageStyle = MapWrapper.create();
      MapWrapper.set(stageStyle, "background-color",
          disabled ? "#DDD" : isCurrent ? "#DDF" : "#FDD");
      stage.style = stageStyle;
      if (isCurrent) {
        disabled = false;
      }
      return stage;
    }));
  }
}
@Component(
    selector: "account-cell",
    properties: const {"width": "cell-width", "account": "account"})
@View(directives: const [], template: '''
      <div [style]="style">
        <a href="/account/{{account.accountId}}">
          {{account.accountId}}
        </a>
      </div>''')
class AccountCellComponent extends HasStyle {
  Account account;
}
@Component(
    selector: "formatted-cell",
    properties: const {"width": "cell-width", "value": "value"})
@View(
    directives: const [],
    template: '''<div [style]="style">{{formattedValue}}</div>''')
class FormattedCellComponent extends HasStyle {
  String formattedValue;
  set value(value) {
    if (value is CustomDate) {
      this.formattedValue =
          '''${ value . month}/${ value . day}/${ value . year}''';
    } else {
      this.formattedValue = value.toString();
    }
  }
}
