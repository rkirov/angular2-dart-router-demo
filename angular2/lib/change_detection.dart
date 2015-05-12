/**
 * @module
 * @public
 * @description
 * Change detection enables data binding in Angular.
 */
library angular2.change_detection;

export "src/change_detection/parser/ast.dart"
    show
        ASTWithSource,
        AST,
        AstTransformer,
        AccessMember,
        LiteralArray,
        ImplicitReceiver;
export "src/change_detection/parser/lexer.dart" show Lexer;
export "src/change_detection/parser/parser.dart" show Parser;
export "src/change_detection/parser/locals.dart" show Locals;
export "src/change_detection/exceptions.dart"
    show ExpressionChangedAfterItHasBeenChecked, ChangeDetectionError;
export "src/change_detection/interfaces.dart"
    show ProtoChangeDetector, ChangeDispatcher, ChangeDetector, ChangeDetection;
export "src/change_detection/constants.dart"
    show CHECK_ONCE, CHECK_ALWAYS, DETACHED, CHECKED, ON_PUSH, DEFAULT;
export "src/change_detection/proto_change_detector.dart"
    show DynamicProtoChangeDetector, JitProtoChangeDetector;
export "src/change_detection/binding_record.dart" show BindingRecord;
export "src/change_detection/directive_record.dart"
    show DirectiveIndex, DirectiveRecord;
export "src/change_detection/dynamic_change_detector.dart"
    show DynamicChangeDetector;
export "src/change_detection/change_detector_ref.dart" show ChangeDetectorRef;
export "src/change_detection/pipes/pipe_registry.dart" show PipeRegistry;
export "src/change_detection/change_detection_util.dart" show uninitialized;
export "src/change_detection/pipes/pipe.dart" show WrappedValue, Pipe;
export "src/change_detection/pipes/null_pipe.dart"
    show NullPipe, NullPipeFactory;
export "src/change_detection/change_detection.dart"
    show
        defaultPipes,
        DynamicChangeDetection,
        JitChangeDetection,
        defaultPipeRegistry;
// HACK: workaround for Traceur behavior.

// It expects all transpiled modules to contain this marker.

// TODO: remove this when we no longer use traceur
var ___esModule = true;
