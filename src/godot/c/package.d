/*************************************************************************/
/*  godot/c/package.d                                                    */
/*  (translated from godot_c.h)                                          */
/*************************************************************************/
/*                       This file is part of:                           */
/*                           GODOT ENGINE                                */
/*                    http://www.godotengine.org                         */
/*************************************************************************/
/* Copyright (c) 2007-2017 Juan Linietsky, Ariel Manzur.                 */
/*                                                                       */
/* Permission is hereby granted, free of charge, to any person obtaining */
/* a copy of this software and associated documentation files (the       */
/* "Software"), to deal in the Software without restriction, including   */
/* without limitation the rights to use, copy, modify, merge, publish,   */
/* distribute, sublicense, and/or sell copies of the Software, and to    */
/* permit persons to whom the Software is furnished to do so, subject to */
/* the following conditions:                                             */
/*                                                                       */
/* The above copyright notice and this permission notice shall be        */
/* included in all copies or substantial portions of the Software.       */
/*                                                                       */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                */
/*************************************************************************/
module godot.c;

import std.typecons : Typedef;

@nogc nothrow:
extern(C):

//#include <stdbool.h>
//#include <stdint.h>

enum GODOT_API_VERSION = 1;

////// Error

enum godot_error {
	GODOT_OK,
	GODOT_FAILED, ///< Generic fail error
	GODOT_ERR_UNAVAILABLE, ///< What is requested is unsupported/unavailable
	GODOT_ERR_UNCONFIGURED, ///< The object being used hasnt been properly set up yet
	GODOT_ERR_UNAUTHORIZED, ///< Missing credentials for requested resource
	GODOT_ERR_PARAMETER_RANGE_ERROR, ///< Parameter given out of range (5)
	GODOT_ERR_OUT_OF_MEMORY, ///< Out of memory
	GODOT_ERR_FILE_NOT_FOUND,
	GODOT_ERR_FILE_BAD_DRIVE,
	GODOT_ERR_FILE_BAD_PATH,
	GODOT_ERR_FILE_NO_PERMISSION, // (10)
	GODOT_ERR_FILE_ALREADY_IN_USE,
	GODOT_ERR_FILE_CANT_OPEN,
	GODOT_ERR_FILE_CANT_WRITE,
	GODOT_ERR_FILE_CANT_READ,
	GODOT_ERR_FILE_UNRECOGNIZED, // (15)
	GODOT_ERR_FILE_CORRUPT,
	GODOT_ERR_FILE_MISSING_DEPENDENCIES,
	GODOT_ERR_FILE_EOF,
	GODOT_ERR_CANT_OPEN, ///< Can't open a resource/socket/file
	GODOT_ERR_CANT_CREATE, // (20)
	GODOT_ERR_QUERY_FAILED,
	GODOT_ERR_ALREADY_IN_USE,
	GODOT_ERR_LOCKED, ///< resource is locked
	GODOT_ERR_TIMEOUT,
	GODOT_ERR_CANT_CONNECT, // (25)
	GODOT_ERR_CANT_RESOLVE,
	GODOT_ERR_CONNECTION_ERROR,
	GODOT_ERR_CANT_AQUIRE_RESOURCE,
	GODOT_ERR_CANT_FORK,
	GODOT_ERR_INVALID_DATA, ///< Data passed is invalid	(30)
	GODOT_ERR_INVALID_PARAMETER, ///< Parameter passed is invalid
	GODOT_ERR_ALREADY_EXISTS, ///< When adding, item already exists
	GODOT_ERR_DOES_NOT_EXIST, ///< When retrieving/erasing, it item does not exist
	GODOT_ERR_DATABASE_CANT_READ, ///< database is full
	GODOT_ERR_DATABASE_CANT_WRITE, ///< database is full	(35)
	GODOT_ERR_COMPILATION_FAILED,
	GODOT_ERR_METHOD_NOT_FOUND,
	GODOT_ERR_LINK_FAILED,
	GODOT_ERR_SCRIPT_FAILED,
	GODOT_ERR_CYCLIC_LINK, // (40)
	GODOT_ERR_INVALID_DECLARATION,
	GODOT_ERR_DUPLICATE_SYMBOL,
	GODOT_ERR_PARSE_ERROR,
	GODOT_ERR_BUSY,
	GODOT_ERR_SKIP, // (45)
	GODOT_ERR_HELP, ///< user requested help!!
	GODOT_ERR_BUG, ///< a bug in the software certainly happened, due to a double check failing or unexpected behavior.
	GODOT_ERR_PRINTER_ON_FIRE, /// the parallel port printer is engulfed in flames
	GODOT_ERR_OMFG_THIS_IS_VERY_VERY_BAD, ///< shit happens, has never been used, though
	GODOT_ERR_WTF = GODOT_ERR_OMFG_THIS_IS_VERY_VERY_BAD ///< short version of the above
}

////// bool

alias godot_bool = int; // really `bool` = `_Bool` from C's stdbool.h

enum GODOT_TRUE = 1;
enum GODOT_FALSE = 0;

/////// int

alias godot_int = int; // C++'s int; Godot assumes it to be always 32 bits.

/////// real

alias godot_real = float;

/////// Object (forward declared)
//alias godot_object = void;
alias godot_object = Typedef!(void*, null, "godot_object");

/////// String

public import godot.c.string;

////// Vector2

public import godot.c.vector2;

////// Rect2

public import godot.c.rect2;

////// Vector3

public import godot.c.vector3;

////// Transform2D

public import godot.c.transform2d;

/////// Plane

public import godot.c.plane;

/////// Quat

public import godot.c.quat;

/////// Rect3

public import godot.c.rect3;

/////// Basis

public import godot.c.basis;

/////// Transform

public import godot.c.transform;

/////// Color

public import godot.c.color;

/////// Image

public import godot.c.image;

/////// NodePath

public import godot.c.node_path;

/////// RID

public import godot.c.rid;

/////// InputEvent

public import godot.c.input_event;

/////// Dictionary

public import godot.c.dictionary;

/////// Array

public import godot.c.array;

// single API file for Pool*Array
public import godot.c.pool_arrays;

void godot_object_destroy(godot_object p_o);

////// Variant

public import godot.c.variant;

////// Singleton API

godot_object godot_global_get_singleton(char* p_name); // result shouldn't be freed

////// MethodBind API

struct godot_method_bind {
	ubyte[1] _dont_touch_that; // TODO
}

godot_method_bind* godot_method_bind_get_method(const char* p_classname, const char* p_methodname);
void godot_method_bind_ptrcall(godot_method_bind* p_method_bind,
	godot_object p_instance, const void** p_args = null, void* p_ret = null);

////// Script API

struct godot_native_init_options {
	godot_bool in_editor;
	ulong core_api_hash;
	ulong editor_api_hash;
	ulong no_api_hash;
}

struct godot_native_terminate_options {
	godot_bool in_editor;
}

enum godot_method_rpc_mode {
	GODOT_METHOD_RPC_MODE_DISABLED,
	GODOT_METHOD_RPC_MODE_REMOTE,
	GODOT_METHOD_RPC_MODE_SYNC,
	GODOT_METHOD_RPC_MODE_MASTER,
	GODOT_METHOD_RPC_MODE_SLAVE,
}

struct godot_method_attributes {
	godot_method_rpc_mode rpc_type;
}

enum godot_property_hint {
	GODOT_PROPERTY_HINT_NONE, ///< no hint provided.
	GODOT_PROPERTY_HINT_RANGE, ///< hint_text = "min,max,step,slider; //slider is optional"
	GODOT_PROPERTY_HINT_EXP_RANGE, ///< hint_text = "min,max,step", exponential edit
	GODOT_PROPERTY_HINT_ENUM, ///< hint_text= "val1,val2,val3,etc"
	GODOT_PROPERTY_HINT_EXP_EASING, /// exponential easing funciton (Math::ease)
	GODOT_PROPERTY_HINT_LENGTH, ///< hint_text= "length" (as integer)
	GODOT_PROPERTY_HINT_SPRITE_FRAME,
	GODOT_PROPERTY_HINT_KEY_ACCEL, ///< hint_text= "length" (as integer)
	GODOT_PROPERTY_HINT_FLAGS, ///< hint_text= "flag1,flag2,etc" (as bit flags)
	GODOT_PROPERTY_HINT_LAYERS_2D_RENDER,
	GODOT_PROPERTY_HINT_LAYERS_2D_PHYSICS,
	GODOT_PROPERTY_HINT_LAYERS_3D_RENDER,
	GODOT_PROPERTY_HINT_LAYERS_3D_PHYSICS,
	GODOT_PROPERTY_HINT_FILE, ///< a file path must be passed, hint_text (optionally) is a filter "*.png,*.wav,*.doc,"
	GODOT_PROPERTY_HINT_DIR, ///< a directort path must be passed
	GODOT_PROPERTY_HINT_GLOBAL_FILE, ///< a file path must be passed, hint_text (optionally) is a filter "*.png,*.wav,*.doc,"
	GODOT_PROPERTY_HINT_GLOBAL_DIR, ///< a directort path must be passed
	GODOT_PROPERTY_HINT_RESOURCE_TYPE, ///< a resource object type
	GODOT_PROPERTY_HINT_MULTILINE_TEXT, ///< used for string properties that can contain multiple lines
	GODOT_PROPERTY_HINT_COLOR_NO_ALPHA, ///< used for ignoring alpha component when editing a color
	GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSY,
	GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSLESS,
	GODOT_PROPERTY_HINT_OBJECT_ID,
	GODOT_PROPERTY_HINT_TYPE_STRING, ///< a type string, the hint is the base type to choose
	GODOT_PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE, ///< so something else can provide this (used in scripts)
	GODOT_PROPERTY_HINT_METHOD_OF_VARIANT_TYPE, ///< a method of a type
	GODOT_PROPERTY_HINT_METHOD_OF_BASE_TYPE, ///< a method of a base type
	GODOT_PROPERTY_HINT_METHOD_OF_INSTANCE, ///< a method of an instance
	GODOT_PROPERTY_HINT_METHOD_OF_SCRIPT, ///< a method of a script & base
	GODOT_PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE, ///< a property of a type
	GODOT_PROPERTY_HINT_PROPERTY_OF_BASE_TYPE, ///< a property of a base type
	GODOT_PROPERTY_HINT_PROPERTY_OF_INSTANCE, ///< a property of an instance
	GODOT_PROPERTY_HINT_PROPERTY_OF_SCRIPT, ///< a property of a script & base
	GODOT_PROPERTY_HINT_MAX,
}

enum godot_property_usage_flags {

	GODOT_PROPERTY_USAGE_STORAGE = 1,
	GODOT_PROPERTY_USAGE_EDITOR = 2,
	GODOT_PROPERTY_USAGE_NETWORK = 4,
	GODOT_PROPERTY_USAGE_EDITOR_HELPER = 8,
	GODOT_PROPERTY_USAGE_CHECKABLE = 16, //used for editing global variables
	GODOT_PROPERTY_USAGE_CHECKED = 32, //used for editing global variables
	GODOT_PROPERTY_USAGE_INTERNATIONALIZED = 64, //hint for internationalized strings
	GODOT_PROPERTY_USAGE_GROUP = 128, //used for grouping props in the editor
	GODOT_PROPERTY_USAGE_CATEGORY = 256,
	GODOT_PROPERTY_USAGE_STORE_IF_NONZERO = 512, //only store if nonzero
	GODOT_PROPERTY_USAGE_STORE_IF_NONONE = 1024, //only store if false
	GODOT_PROPERTY_USAGE_NO_INSTANCE_STATE = 2048,
	GODOT_PROPERTY_USAGE_RESTART_IF_CHANGED = 4096,
	GODOT_PROPERTY_USAGE_SCRIPT_VARIABLE = 8192,
	GODOT_PROPERTY_USAGE_STORE_IF_NULL = 16384,
	GODOT_PROPERTY_USAGE_ANIMATE_AS_TRIGGER = 32768,
	GODOT_PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED = 65536,

	GODOT_PROPERTY_USAGE_DEFAULT = GODOT_PROPERTY_USAGE_STORAGE | GODOT_PROPERTY_USAGE_EDITOR | GODOT_PROPERTY_USAGE_NETWORK,
	GODOT_PROPERTY_USAGE_DEFAULT_INTL = GODOT_PROPERTY_USAGE_STORAGE | GODOT_PROPERTY_USAGE_EDITOR | GODOT_PROPERTY_USAGE_NETWORK | GODOT_PROPERTY_USAGE_INTERNATIONALIZED,
	GODOT_PROPERTY_USAGE_NOEDITOR = GODOT_PROPERTY_USAGE_STORAGE | GODOT_PROPERTY_USAGE_NETWORK,
}

struct godot_property_attributes {
	godot_method_rpc_mode rset_type;

	godot_int type;
	godot_property_hint hint;
	godot_string hint_string;
	godot_property_usage_flags usage;
	godot_variant default_value;
}

struct godot_instance_create_func {
	// instance pointer, method_data - return user data
	void* function(godot_object , void* ) create_func;
	void* method_data;
	void function(void* ) free_func;
}

struct godot_instance_destroy_func {
	// instance pointer, method data, user data
	void function(godot_object , void* , void* ) destroy_func;
	void* method_data;
	void function(void* ) free_func;
}

void godot_script_register_class(const char* p_name, const char* p_base, godot_instance_create_func p_create_func, godot_instance_destroy_func p_destroy_func);

void godot_script_register_tool_class(const char* p_name, const char* p_base, godot_instance_create_func p_create_func, godot_instance_destroy_func p_destroy_func);

struct godot_instance_method {
	// instance pointer, method data, user data, num args, args - return result as varaint
	godot_variant function(godot_object , void* , void* , int, godot_variant**) method;
	void* method_data;
	void function(void* ) free_func;
}

void godot_script_register_method(const char* p_name, const char* p_function_name, godot_method_attributes p_attr, godot_instance_method p_method);

struct godot_property_set_func {
	// instance pointer, method data, user data, value
	void function(godot_object , void* , void* , godot_variant) set_func;
	void* method_data;
	void function(void* ) free_func;
}

struct godot_property_get_func {
	// instance pointer, method data, user data, value
	godot_variant function(godot_object , void* , void* ) get_func;
	void* method_data;
	void function(void* ) free_func;
}

void godot_script_register_property(const char* p_name, const char* p_path, godot_property_attributes* p_attr, godot_property_set_func p_set_func, godot_property_get_func p_get_func);

struct godot_signal_argument {
	godot_string name;
	godot_int type;
	godot_property_hint hint;
	godot_string hint_string;
	godot_property_usage_flags usage;
	godot_variant default_value;
}

struct godot_signal {
	godot_string name;
	int num_args;
	godot_signal_argument* args;
	int num_default_args;
	godot_variant* default_args;
}

void godot_script_register_signal(const char* p_name, const godot_signal* p_signal);

void* godot_native_get_userdata(godot_object p_instance);

alias godot_class_constructor = godot_object function();

godot_class_constructor godot_get_class_constructor(const char *p_classname);

godot_dictionary godot_get_global_constants;

////// System Functions

//using these will help Godot track how much memory is in use in debug mode
void* godot_alloc(int p_bytes);
void* godot_realloc(void* p_ptr, int p_bytes);
void godot_free(void* p_ptr);

 
