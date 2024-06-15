#define MB_CODES
#define MB_FUNC_OK 0
#define MB_FUNC_IGNORE 1
#define MB_FUNC_WARNING 2
#define MB_FUNC_ERR 3
#define MB_FUNC_BYE 4
#define MB_FUNC_SUSPEND 5
#define MB_FUNC_END 6
#define MB_LOOP_BREAK 101
#define MB_LOOP_CONTINUE 102
#define MB_SUB_RETURN 103
#define MB_EXTENDED_ABORT 201

Enum mb_error_e
   SE_NO_ERR = 0,
   ' Common
   SE_CM_FUNC_EXISTS,
   SE_CM_FUNC_NOT_EXISTS,
   SE_CM_NOT_SUPPORTED,
   ' Parsing
   SE_PS_OPEN_FILE_FAILED,
   SE_PS_SYMBOL_TOO_LONG,
   SE_PS_INVALID_CHAR,
   SE_PS_INVALID_MODULE,
   SE_PS_DUPLICATE_IMPORT,
   ' Running
   SE_RN_EMPTY_PROGRAM,
   SE_RN_PROGRAM_TOO_LONG,
   SE_RN_SYNTAX_ERROR,
   SE_RN_OUT_OF_MEMORY,
   SE_RN_OVERFLOW,
   SE_RN_UNEXPECTED_TYPE,
   SE_RN_INVALID_STRING,
   SE_RN_INTEGER_EXPECTED,
   SE_RN_NUMBER_EXPECTED,
   SE_RN_STRING_EXPECTED,
   SE_RN_VAR_EXPECTED,
   SE_RN_INDEX_OUT_OF_BOUND,
   SE_RN_CANNOT_FIND_WITH_GIVEN_INDEX,
   SE_RN_TOO_MANY_DIMENSIONS,
   SE_RN_RANK_OUT_OF_BOUND,
   SE_RN_INVALID_ID_USAGE,
   SE_RN_CANNOT_ASSIGN_TO_RESERVED_WORD,
   SE_RN_DUPLICATE_ID,
   SE_RN_INCOMPLETE_STRUCTURE,
   SE_RN_LABEL_NOT_EXISTS,
   SE_RN_NO_RETURN_POINT,
   SE_RN_COLON_EXPECTED,
   SE_RN_COMMA_EXPECTED,
   SE_RN_COMMA_OR_SEMICOLON_EXPECTED,
   SE_RN_OPEN_BRACKET_EXPECTED,
   SE_RN_CLOSE_BRACKET_EXPECTED,
   SE_RN_NESTED_TOO_MUCH,
   SE_RN_OPERATION_FAILED,
   SE_RN_OPERATOR_EXPECTED,
   SE_RN_ASSIGN_OPERATOR_EXPECTED,
   SE_RN_THEN_EXPECTED,
   SE_RN_ELSE_EXPECTED,
   SE_RN_ENDIF_EXPECTED,
   SE_RN_TO_EXPECTED,
   SE_RN_NEXT_EXPECTED,
   SE_RN_UNTIL_EXPECTED,
   SE_RN_LOOP_VAR_EXPECTED,
   SE_RN_JUMP_LABEL_EXPECTED,
   SE_RN_CALCULATION_ERROR,
   SE_RN_INVALID_EXPRESSION,
   SE_RN_DIVIDE_BY_ZERO,
   SE_RN_REACHED_TO_WRONG_FUNCTION,
   SE_RN_CANNOT_SUSPEND_HERE,
   SE_RN_CANNOT_MIX_INSTRUCTIONAL_AND_STRUCTURED,
   SE_RN_INVALID_ROUTINE,
   SE_RN_ROUTINE_EXPECTED,
   SE_RN_DUPLICATE_ROUTINE,
   SE_RN_INVALID_CLASS,
   SE_RN_CLASS_EXPECTED,
   SE_RN_DUPLICATE_CLASS,
   SE_RN_HASH_AND_COMPARE_MUST_BE_PROVIDED_TOGETHER,
   SE_RN_INVALID_LAMBDA,
   SE_RN_EMPTY_COLLECTION,
   SE_RN_LIST_EXPECTED,
   SE_RN_INVALID_ITERATOR,
   SE_RN_ITERABLE_EXPECTED,
   SE_RN_COLLECTION_EXPECTED,
   SE_RN_COLLECTION_OR_ITERATOR_EXPECTED,
   SE_RN_REFERENCED_TYPE_EXPECTED,
   ' Extended abort
   SE_EA_EXTENDED_ABORT,
   ' Extra
   SE_COUNT
End Enum

Enum mb_data_e
   MB_DT_NIL = 0,
   MB_DT_UNKNOWN = 1 Shl 0,
   MB_DT_INT = 1 Shl 1,
   MB_DT_REAL = 1 Shl 2,
   MB_DT_NUM = MB_DT_INT Or MB_DT_REAL,
   MB_DT_STRING = 1 Shl 3,
   MB_DT_TYPE = 1 Shl 4,
   MB_DT_USERTYPE = 1 Shl 5,

   MB_DT_ARRAY = 1 Shl 7,
   MB_DT_ROUTINE = 1 Shl 13
End Enum

Enum mb_meta_func_e
   MB_MF_IS = 1 Shl 0,
   MB_MF_ADD = 1 Shl 1,
   MB_MF_SUB = 1 Shl 2,
   MB_MF_MUL = 1 Shl 3,
   MB_MF_DIV = 1 Shl 4,
   MB_MF_NEG = 1 Shl 5,
   MB_MF_CALC = MB_MF_IS Or MB_MF_ADD Or MB_MF_SUB Or MB_MF_MUL Or MB_MF_DIV Or MB_MF_NEG,
   MB_MF_COLL = 1 Shl 6,
   MB_MF_FUNC = 1 Shl 7
End Enum

Enum mb_meta_status_e
   MB_MS_NONE = 0,
   MB_MS_DONE = 1 Shl 0,
   MB_MS_RETURNED = 1 Shl 1
End Enum

Enum mb_routine_type_e
   MB_RT_NONE,
   MB_RT_SCRIPT,
   MB_RT_LAMBDA,
   MB_RT_NATIVE
End Enum

Union mb_value_u Field = 1
   integer_ As Integer
   float_point As Single
   string_ As ZString Ptr
   type_ As Long'mb_data_e
   usertype As Any Ptr
   array As Any Ptr
   routine As Any Ptr
   bytes As Unsigned Byte
End Union

Type mb_value_t Field = 1
   type_ As Long'mb_data_e
   value As mb_value_u
End Type


Extern "C"
Declare Function mb_init() As Integer
Declare Function mb_dispose() As Integer
Declare Function mb_open(ByRef s As Any Ptr) As Integer
Declare Function mb_close(ByRef s As Any Ptr) As Integer
Declare Function mb_reset(ByRef s As Any Ptr, clear_funcs As Unsigned Byte, clear_vars As Unsigned Byte) As Integer

Declare Function mb_fork(ByRef s As Any Ptr, r As Any Ptr, clear_forked As Unsigned Byte) As Integer
Declare Function mb_join(ByRef s As Any Ptr) As Integer
Declare Function mb_get_forked_from(s As Any Ptr, ByRef src As Any Ptr) As Integer

Declare Function mb_register_func(s As Any Ptr, n As ZString Ptr, f As Function cdecl (As Any Ptr, ByRef As Any Ptr) As Integer) As Integer
Declare Function mb_remove_func(s As Any Ptr, n As ZString Ptr) As Integer
Declare Function mb_remove_reserved_func(s As Any Ptr, n As ZString Ptr) As Integer
Declare Function mb_begin_module(s As Any Ptr, n As ZString Ptr) As Integer
Declare Function mb_end_module(s As Any Ptr) As Integer

Declare Function mb_attempt_func_begin(s As Any Ptr, ByRef l As Any Ptr) As Integer
Declare Function mb_attempt_func_end(s As Any Ptr, ByRef l As Any Ptr) As Integer
Declare Function mb_attempt_open_bracket(s As Any Ptr, ByRef l As Any Ptr) As Integer
Declare Function mb_attempt_close_bracket(s As Any Ptr, ByRef l As Any Ptr) As Integer
Declare Function mb_has_arg(s As Any Ptr, ByRef l As Any Ptr) As Integer
Declare Function mb_pop_int(s As Any Ptr, ByRef l As Any Ptr, ByRef val_ As Integer) As Integer
Declare Function mb_pop_real(s As Any Ptr, ByRef l As Any Ptr, ByRef val_ As Single) As Integer
Declare Function mb_pop_string(s As Any Ptr, ByRef l As Any Ptr, ByRef val_ As ZString Ptr) As Integer
Declare Function mb_pop_usertype(s As Any Ptr, ByRef l As Any Ptr, ByRef val_ As Any Ptr) As Integer
Declare Function mb_pop_value(s As Any Ptr, ByRef l As Any Ptr, ByRef val_ As mb_value_t) As Integer
Declare Function mb_push_int(s As Any Ptr, ByRef l As Any Ptr, val_ As Integer) As Integer
Declare Function mb_push_real(s As Any Ptr, ByRef l As Any Ptr, val_ As Single) As Integer
Declare Function mb_push_string(s As Any Ptr, ByRef l As Any Ptr, val_ As ZString Ptr) As Integer
Declare Function mb_push_usertype(s As Any Ptr, ByRef l As Any Ptr, val_ As Any Ptr) As Integer
Declare Function mb_push_value(s As Any Ptr, ByRef l As Any Ptr, val_ As mb_value_t) As Integer

Declare Function mb_begin_class(s As Any Ptr, ByRef l As Any Ptr, n As ZString Ptr, ByRef meta As mb_value_t Ptr, c As Integer, ByRef out_ As mb_value_t) As Integer
Declare Function mb_end_class(s As Any Ptr, ByRef l As Any Ptr) As Integer
Declare Function mb_get_class_userdata(s As Any Ptr, ByRef l As Any Ptr, ByRef d As Any Ptr) As Integer
Declare Function mb_set_class_userdata(s As Any Ptr, ByRef l As Any Ptr, ByRef d As Any Ptr) As Integer

Declare Function mb_get_value_by_name(s As Any Ptr, ByRef l As Any Ptr, n As ZString Ptr, ByRef val_ As mb_value_t) As Integer
Declare Function mb_get_vars(s As Any Ptr,  ByRef l As Any Ptr, r As Sub cdecl(As Any Ptr, As ZString Ptr, As Integer) , stack_offset As Integer) As Integer
Declare Function mb_add_var(s As Any Ptr, ByRef l As Any Ptr, n As ZString Ptr, val_ As mb_value_t, force As Unsigned Byte) As Integer
Declare Function mb_get_var(s As Any Ptr, ByRef l As Any Ptr, ByRef v As Any Ptr, redir As Unsigned Byte) As Integer
Declare Function mb_get_var_name(s As Any Ptr, v As Any Ptr, ByRef n As ZString Ptr) As Integer
Declare Function mb_get_var_value(s As Any Ptr, v As Any Ptr, ByRef val_ As mb_value_t) As Integer
Declare Function mb_set_var_value(s As Any Ptr, v As Any Ptr, val As mb_value_t) As Integer
Declare Function mb_init_array(s As Any Ptr, ByRef l As Any Ptr, t As mb_data_e, ByRef d As Integer, c As Integer, ByRef a As Any Ptr) As Integer
Declare Function mb_get_array_len(s As Any Ptr, ByRef l As Any Ptr, a As Any Ptr, r As Integer, ByRef i As Integer) As Integer
Declare Function mb_get_array_elem(s As Any Ptr, ByRef l As Any Ptr, a As Any Ptr, ByRef d As Integer, c As Integer, ByRef val_ As mb_value_t) As Integer
Declare Function mb_set_array_elem(s As Any Ptr, ByRef l As Any Ptr, a As Any Ptr, ByRef d As Integer, c As Integer, val_ As mb_value_t) As Integer
Declare Function mb_init_coll(s As Any Ptr, ByRef l As Any Ptr, ByRef coll As mb_value_t) As Integer
Declare Function mb_get_coll(s As Any Ptr, ByRef l As Any Ptr, coll As mb_value_t, idx As mb_value_t, ByRef val_ As mb_value_t) As Integer
Declare Function mb_set_coll(s As Any Ptr, ByRef l As Any Ptr, coll As mb_value_t, idx As mb_value_t, val_ As mb_value_t) As Integer
Declare Function mb_remove_coll(s As Any Ptr, ByRef l As Any Ptr, coll As mb_value_t, idx As mb_value_t) As Integer
Declare Function mb_count_coll(s As Any Ptr, ByRef l As Any Ptr, coll As mb_value_t, ByRef c As Integer) As Integer
Declare Function mb_keys_of_coll(s As Any Ptr, ByRef l As Any Ptr, coll As mb_value_t, ByRef keys As mb_value_t, c As Integer) As Integer
Declare Function mb_make_ref_value(s As Any Ptr, val_ As Any Ptr, ByRef out_ As mb_value_t, un As Sub cdecl (As Any Ptr, As Any Ptr), cl As Function cdecl (As Any Ptr, As Any Ptr) As Any Ptr, hs As Function cdecl (As Any Ptr, As Any Ptr) As Unsigned Integer, cp As Function cdecl (As Any Ptr, As Any Ptr, As Any Ptr) As Integer, ft As Function cdecl (As Any Ptr, As Any Ptr, As ZString Ptr, As Unsigned Integer) As Integer) As Integer
Declare Function mb_get_ref_value(s As Any Ptr, ByRef l As Any Ptr, val_ As mb_value_t, ByRef out_ As Any Ptr) As Integer
Declare Function mb_ref_value(s As Any Ptr, ByRef l As Any Ptr, val_ As mb_value_t) As Integer
Declare Function mb_unref_value(s As Any Ptr, ByRef l As Any Ptr, val_ As mb_value_t) As Integer
Declare Function mb_set_alive_checker(s As Any Ptr, f As Sub cdecl (As Any Ptr, As Any Ptr, As Sub cdecl (As Any Ptr, As Any Ptr, As mb_value_t))) As Integer
Declare Function mb_set_alive_checker_of_value(s As Any Ptr, ByRef l As Any Ptr, val As mb_value_t, f As Sub cdecl (As Any Ptr, As Any Ptr, As mb_value_t, As Sub cdecl (As Any Ptr, As Any Ptr, As mb_value_t))) As Integer
Declare Function mb_override_value(s As Any Ptr, ByRef l As Any Ptr, val_ As mb_value_t, m As mb_meta_func_e, f As Any Ptr) As Integer
Declare Function mb_dispose_value(s As Any Ptr, val_ As mb_value_t) As Integer

Declare Function mb_get_routine(s As Any Ptr, ByRef l As Any Ptr, n As ZString Ptr, ByRef val_ As mb_value_t) As Integer
Declare Function mb_set_routine(s As Any Ptr, ByRef l As Any Ptr, n As ZString Ptr, f As Function cdecl(As Any Ptr, ByRef As Any Ptr, ByRef As mb_value_t, As Unsigned Integer, As Any Ptr, As Function cdecl (As Any Ptr, ByRef As Any Ptr, ByRef As mb_value_t, As Unsigned Integer, ByRef As Unsigned Integer, As Any Ptr) As Integer, As Function cdecl (As Any Ptr, ByRef As Any Ptr, ByRef As mb_value_t, As Unsigned Integer, ByRef As Unsigned Integer, As Any Ptr, ByRef As mb_value_t) As Integer) As Integer, force As Unsigned Byte) As Integer
Declare Function mb_eval_routine(s As Any Ptr, ByRef l As Any Ptr, val_ As mb_value_t, args As mb_value_t, argc As Unsigned Integer, ByRef ret_ As mb_value_t) As Integer
Declare Function mb_get_routine_type(s As Any Ptr, val_ As mb_value_t, ByRef y As mb_routine_type_e) As Integer

Declare Function mb_load_string(s As Any Ptr, l As ZString Ptr, reset As Unsigned Byte) As Integer
Declare Function mb_load_file(s As Any Ptr, f As ZString Ptr) As Integer
Declare Function mb_run(s As Any Ptr, clear_parser As Unsigned Byte) As Integer
Declare Function mb_suspend(ss As Any Ptr, ByRef l As Any Ptr) As Integer
Declare Function mb_schedule_suspend(s As Any Ptr, t As Integer) As Integer

Declare Function mb_debug_get(s As Any Ptr, n As ZString Ptr, ByRef val_ As mb_value_t) As Integer
Declare Function mb_debug_set(s As Any Ptr, n As ZString Ptr, val_ As mb_value_t) As Integer
Declare Function mb_debug_count_stack_frames(s As Any Ptr) As Integer
Declare Function mb_debug_get_stack_trace(s As Any Ptr, ByRef fs As ZString Ptr, fc As Unsigned Integer) As Integer
Declare Function mb_debug_set_stepped_handler(s As Any Ptr, prev As Function cdecl (As Any Ptr, ByRef As Any Ptr, As ZString Ptr, As Integer, As Unsigned Short, As Unsigned Short) As Integer, post As Function cdecl (As Any Ptr, ByRef As Any Ptr, As ZString Ptr, As Integer, As Unsigned Short, As Unsigned Short) As Integer) As Integer

Declare Function mb_get_type_string(t As mb_data_e) As ZString Ptr

Declare Function mb_raise_error(s As Any Ptr, ByRef l As Any Ptr, err_ As mb_error_e, ret_ As Integer) As Integer
Declare Function mb_get_last_error(s As Any Ptr, ByRef file As ZString Ptr, ByRef pos_ As Integer, ByRef row_ As Unsigned Short, ByRef col_ As Unsigned Short) As mb_error_e
Declare Function mb_get_error_desc(err_ As mb_error_e) As ZString Ptr
Declare Function mb_set_error_handler(s As Any Ptr, h As Sub cdecl (As Any Ptr, As mb_error_e, As ZString Ptr, As ZString Ptr, As Integer, As Unsigned Short, As Unsigned Short, As Integer)) As Integer

Declare Function mb_set_printer(s As Any Ptr, p As Function cdecl(As Any Ptr, As ZString Ptr, ...) As Integer) As Integer
Declare Function mb_set_inputer(s As Any Ptr, p As Function cdecl(As Any Ptr, As ZString Ptr, As ZString Ptr, As Integer) As Integer) As Integer

Declare Function mb_set_import_handler(s As Any Ptr, h As Function cdecl(As Any Ptr, As ZString Ptr) As Integer) As Integer
Declare Function mb_set_memory_manager(a As Function cdecl (As Unsigned Integer) As UByte Ptr, f As Sub cdecl (As UByte Ptr)) As Integer
Declare Function mb_get_gc_enabled(s As Any Ptr) As Unsigned Byte
Declare Function mb_set_gc_enabled(s As Any Ptr, gc As Unsigned Byte) As Integer
Declare Function mb_gc(s As Any Ptr, ByRef collected As Integer) As Integer
Declare Function mb_get_userdata(s As Any Ptr, ByRef d As Any Ptr) As Integer
Declare Function mb_set_userdata(s As Any Ptr, d As Any Ptr) As Integer
Declare Function mb_gets(s As Any Ptr, pmt As ZString Ptr, buf As UByte Ptr, n As Integer) As Integer
Declare Function mb_memdup(val_ As ZString Ptr, size As Unsigned Integer) As ZString Ptr
End Extern

