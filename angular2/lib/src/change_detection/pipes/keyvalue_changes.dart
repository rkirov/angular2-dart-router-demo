library angular2.src.change_detection.pipes.keyvalue_changes;

import "package:angular2/src/facade/collection.dart"
    show ListWrapper, MapWrapper, StringMapWrapper;
import "package:angular2/src/facade/lang.dart"
    show stringify, looseIdentical, isJsObject;
import "pipe.dart" show WrappedValue, Pipe, PipeFactory;

/**
 * @exportedAs angular2/pipes
 */
class KeyValueChangesFactory extends PipeFactory {
  const KeyValueChangesFactory() : super();
  bool supports(obj) {
    return KeyValueChanges.supportsObj(obj);
  }
  Pipe create(cdRef) {
    return new KeyValueChanges();
  }
}
/**
 * @exportedAs angular2/pipes
 */
class KeyValueChanges extends Pipe {
  Map<dynamic, dynamic> _records;
  KVChangeRecord _mapHead;
  KVChangeRecord _previousMapHead;
  KVChangeRecord _changesHead;
  KVChangeRecord _changesTail;
  KVChangeRecord _additionsHead;
  KVChangeRecord _additionsTail;
  KVChangeRecord _removalsHead;
  KVChangeRecord _removalsTail;
  KeyValueChanges() : super() {
    /* super call moved to initializer */;
    this._records = MapWrapper.create();
    this._mapHead = null;
    this._previousMapHead = null;
    this._changesHead = null;
    this._changesTail = null;
    this._additionsHead = null;
    this._additionsTail = null;
    this._removalsHead = null;
    this._removalsTail = null;
  }
  static bool supportsObj(obj) {
    return obj is Map || isJsObject(obj);
  }
  bool supports(obj) {
    return KeyValueChanges.supportsObj(obj);
  }
  dynamic transform(map) {
    if (this.check(map)) {
      return WrappedValue.wrap(this);
    } else {
      return this;
    }
  }
  bool get isDirty {
    return !identical(this._additionsHead, null) ||
        !identical(this._changesHead, null) ||
        !identical(this._removalsHead, null);
  }
  forEachItem(Function fn) {
    KVChangeRecord record;
    for (record = this._mapHead;
        !identical(record, null);
        record = record._next) {
      fn(record);
    }
  }
  forEachPreviousItem(Function fn) {
    KVChangeRecord record;
    for (record = this._previousMapHead;
        !identical(record, null);
        record = record._nextPrevious) {
      fn(record);
    }
  }
  forEachChangedItem(Function fn) {
    KVChangeRecord record;
    for (record = this._changesHead;
        !identical(record, null);
        record = record._nextChanged) {
      fn(record);
    }
  }
  forEachAddedItem(Function fn) {
    KVChangeRecord record;
    for (record = this._additionsHead;
        !identical(record, null);
        record = record._nextAdded) {
      fn(record);
    }
  }
  forEachRemovedItem(Function fn) {
    KVChangeRecord record;
    for (record = this._removalsHead;
        !identical(record, null);
        record = record._nextRemoved) {
      fn(record);
    }
  }
  bool check(map) {
    this._reset();
    var records = this._records;
    KVChangeRecord oldSeqRecord = this._mapHead;
    KVChangeRecord lastOldSeqRecord = null;
    KVChangeRecord lastNewSeqRecord = null;
    bool seqChanged = false;
    this._forEach(map, (value, key) {
      var newSeqRecord;
      if (!identical(oldSeqRecord, null) && identical(key, oldSeqRecord.key)) {
        newSeqRecord = oldSeqRecord;
        if (!looseIdentical(value, oldSeqRecord.currentValue)) {
          oldSeqRecord.previousValue = oldSeqRecord.currentValue;
          oldSeqRecord.currentValue = value;
          this._addToChanges(oldSeqRecord);
        }
      } else {
        seqChanged = true;
        if (!identical(oldSeqRecord, null)) {
          oldSeqRecord._next = null;
          this._removeFromSeq(lastOldSeqRecord, oldSeqRecord);
          this._addToRemovals(oldSeqRecord);
        }
        if (MapWrapper.contains(records, key)) {
          newSeqRecord = MapWrapper.get(records, key);
        } else {
          newSeqRecord = new KVChangeRecord(key);
          MapWrapper.set(records, key, newSeqRecord);
          newSeqRecord.currentValue = value;
          this._addToAdditions(newSeqRecord);
        }
      }
      if (seqChanged) {
        if (this._isInRemovals(newSeqRecord)) {
          this._removeFromRemovals(newSeqRecord);
        }
        if (lastNewSeqRecord == null) {
          this._mapHead = newSeqRecord;
        } else {
          lastNewSeqRecord._next = newSeqRecord;
        }
      }
      lastOldSeqRecord = oldSeqRecord;
      lastNewSeqRecord = newSeqRecord;
      oldSeqRecord = identical(oldSeqRecord, null) ? null : oldSeqRecord._next;
    });
    this._truncate(lastOldSeqRecord, oldSeqRecord);
    return this.isDirty;
  }
  _reset() {
    if (this.isDirty) {
      KVChangeRecord record;
      // Record the state of the mapping
      for (record = this._previousMapHead = this._mapHead;
          !identical(record, null);
          record = record._next) {
        record._nextPrevious = record._next;
      }
      for (record = this._changesHead;
          !identical(record, null);
          record = record._nextChanged) {
        record.previousValue = record.currentValue;
      }
      for (record = this._additionsHead;
          record != null;
          record = record._nextAdded) {
        record.previousValue = record.currentValue;
      }
      // todo(vicb) once assert is supported

      // assert(() {

      //  var r = _changesHead;

      //  while (r != null) {

      //    var nextRecord = r._nextChanged;

      //    r._nextChanged = null;

      //    r = nextRecord;

      //  }

      //

      //  r = _additionsHead;

      //  while (r != null) {

      //    var nextRecord = r._nextAdded;

      //    r._nextAdded = null;

      //    r = nextRecord;

      //  }

      //

      //  r = _removalsHead;

      //  while (r != null) {

      //    var nextRecord = r._nextRemoved;

      //    r._nextRemoved = null;

      //    r = nextRecord;

      //  }

      //

      //  return true;

      //});
      this._changesHead = this._changesTail = null;
      this._additionsHead = this._additionsTail = null;
      this._removalsHead = this._removalsTail = null;
    }
  }
  _truncate(KVChangeRecord lastRecord, KVChangeRecord record) {
    while (!identical(record, null)) {
      if (identical(lastRecord, null)) {
        this._mapHead = null;
      } else {
        lastRecord._next = null;
      }
      var nextRecord = record._next;
      // todo(vicb) assert

      // assert((() {

      //  record._next = null;

      //  return true;

      //}));
      this._addToRemovals(record);
      lastRecord = record;
      record = nextRecord;
    }
    for (KVChangeRecord rec = this._removalsHead;
        !identical(rec, null);
        rec = rec._nextRemoved) {
      rec.previousValue = rec.currentValue;
      rec.currentValue = null;
      MapWrapper.delete(this._records, rec.key);
    }
  }
  _isInRemovals(KVChangeRecord record) {
    return identical(record, this._removalsHead) ||
        !identical(record._nextRemoved, null) ||
        !identical(record._prevRemoved, null);
  }
  _addToRemovals(KVChangeRecord record) {
    // todo(vicb) assert

    // assert(record._next == null);

    // assert(record._nextAdded == null);

    // assert(record._nextChanged == null);

    // assert(record._nextRemoved == null);

    // assert(record._prevRemoved == null);
    if (identical(this._removalsHead, null)) {
      this._removalsHead = this._removalsTail = record;
    } else {
      this._removalsTail._nextRemoved = record;
      record._prevRemoved = this._removalsTail;
      this._removalsTail = record;
    }
  }
  _removeFromSeq(KVChangeRecord prev, KVChangeRecord record) {
    var next = record._next;
    if (identical(prev, null)) {
      this._mapHead = next;
    } else {
      prev._next = next;
    }
  }
  _removeFromRemovals(KVChangeRecord record) {
    // todo(vicb) assert

    // assert(record._next == null);

    // assert(record._nextAdded == null);

    // assert(record._nextChanged == null);
    var prev = record._prevRemoved;
    var next = record._nextRemoved;
    if (identical(prev, null)) {
      this._removalsHead = next;
    } else {
      prev._nextRemoved = next;
    }
    if (identical(next, null)) {
      this._removalsTail = prev;
    } else {
      next._prevRemoved = prev;
    }
    record._prevRemoved = record._nextRemoved = null;
  }
  _addToAdditions(KVChangeRecord record) {
    // todo(vicb): assert

    // assert(record._next == null);

    // assert(record._nextAdded == null);

    // assert(record._nextChanged == null);

    // assert(record._nextRemoved == null);

    // assert(record._prevRemoved == null);
    if (identical(this._additionsHead, null)) {
      this._additionsHead = this._additionsTail = record;
    } else {
      this._additionsTail._nextAdded = record;
      this._additionsTail = record;
    }
  }
  _addToChanges(KVChangeRecord record) {
    // todo(vicb) assert

    // assert(record._nextAdded == null);

    // assert(record._nextChanged == null);

    // assert(record._nextRemoved == null);

    // assert(record._prevRemoved == null);
    if (identical(this._changesHead, null)) {
      this._changesHead = this._changesTail = record;
    } else {
      this._changesTail._nextChanged = record;
      this._changesTail = record;
    }
  }
  String toString() {
    var items = [];
    var previous = [];
    var changes = [];
    var additions = [];
    var removals = [];
    KVChangeRecord record;
    for (record = this._mapHead;
        !identical(record, null);
        record = record._next) {
      ListWrapper.push(items, stringify(record));
    }
    for (record = this._previousMapHead;
        !identical(record, null);
        record = record._nextPrevious) {
      ListWrapper.push(previous, stringify(record));
    }
    for (record = this._changesHead;
        !identical(record, null);
        record = record._nextChanged) {
      ListWrapper.push(changes, stringify(record));
    }
    for (record = this._additionsHead;
        !identical(record, null);
        record = record._nextAdded) {
      ListWrapper.push(additions, stringify(record));
    }
    for (record = this._removalsHead;
        !identical(record, null);
        record = record._nextRemoved) {
      ListWrapper.push(removals, stringify(record));
    }
    return "map: " +
        items.join(", ") +
        "\n" +
        "previous: " +
        previous.join(", ") +
        "\n" +
        "additions: " +
        additions.join(", ") +
        "\n" +
        "changes: " +
        changes.join(", ") +
        "\n" +
        "removals: " +
        removals.join(", ") +
        "\n";
  }
  _forEach(obj, Function fn) {
    if (obj is Map) {
      MapWrapper.forEach(obj, fn);
    } else {
      StringMapWrapper.forEach(obj, fn);
    }
  }
}
/**
 * @exportedAs angular2/pipes
 */
class KVChangeRecord {
  var key;
  var previousValue;
  var currentValue;
  KVChangeRecord _nextPrevious;
  KVChangeRecord _next;
  KVChangeRecord _nextAdded;
  KVChangeRecord _nextRemoved;
  KVChangeRecord _prevRemoved;
  KVChangeRecord _nextChanged;
  KVChangeRecord(key) {
    this.key = key;
    this.previousValue = null;
    this.currentValue = null;
    this._nextPrevious = null;
    this._next = null;
    this._nextAdded = null;
    this._nextRemoved = null;
    this._prevRemoved = null;
    this._nextChanged = null;
  }
  String toString() {
    return looseIdentical(this.previousValue, this.currentValue)
        ? stringify(this.key)
        : (stringify(this.key) +
            "[" +
            stringify(this.previousValue) +
            "->" +
            stringify(this.currentValue) +
            "]");
  }
}
