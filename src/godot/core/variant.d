module godot.core.variant;

import godot.c;
import godot.core;
import godot.classes.object;

import std.meta, std.traits;
import std.conv : text;
import std.range : iota;

struct Variant
{
	package(godot) godot_variant _godot_variant;
	
	enum Type
	{
		nil,
		
		// atomic types
		bool_,
		int_,
		real_,
		string,
		
		// math types
		
		vector2,// 5
		rect2,
		vector3,
		transform2d,
		plane,
		quat,// 10
		rect3,
		basis,
		transform,
		
		// misc types
		color,
		image,// 15
		node_path,
		rid,
		object,
		input_event,
		dictionary,// 20
		array,
		
		// arrays
		pool_byte_array,
		pool_int_array,
		pool_real_array,
		pool_string_array,// 25
		pool_vector2_array,
		pool_vector3_array,
		pool_color_array,
	}
	
	/// GDNative type that gets passed to the C functions
	alias InternalType = AliasSeq!
	(
		typeof(null),
		
		godot_bool,
		long,
		double,
		godot_string,
		
		godot_vector2,
		godot_rect2,
		godot_vector3,
		godot_transform2d,
		godot_plane,
		godot_quat,
		godot_rect3,
		godot_basis,
		godot_transform,
		
		godot_color,
		godot_image,
		godot_node_path,
		godot_rid,
		godot_object,
		godot_input_event,
		godot_dictionary,
		godot_array,
		
		godot_pool_byte_array,
		godot_pool_int_array,
		godot_pool_real_array,
		godot_pool_string_array,// 25
		godot_pool_vector2_array,
		godot_pool_vector3_array,
		godot_pool_color_array,
	);
	
	alias Object = godot_object;
	
	/// D type that this Variant implementation uses
	alias DType = AliasSeq!
	(
		typeof(null),
		
		bool,
		long,
		double,
		String,
		
		Vector2,// 5
		Rect2,
		Vector3,
		Transform2D,
		Plane,
		Quat,// 10
		Rect3,
		Basis,
		Transform,
		
		// misc types
		Color,
		Image,// 15
		NodePath,
		RID,
		GodotObject,
		InputEvent,
		Dictionary,// 20
		Array,
		
		// arrays
		PoolByteArray,
		PoolIntArray,
		PoolRealArray,
		PoolStringArray,// 25
		PoolVector2Array,
		PoolVector3Array,
		PoolColorArray,
	);
	
	/// special types allowed to work with Variant in addition to the internal types
	private enum bool specialCase(S) = isIntegral!S || isFloatingPoint!S; // || isSomeString!S;
	
	private enum bool implicit(Src, Dest) = is(Src : Dest) || isImplicitlyConvertible!(Src, Dest);
	
	/++
	Template to determine if T is compatible with Variant
	+/
	public template compatible(T)
	{
		private enum bool _implicit(D) = implicit!(T, D);
		
		enum bool compatible = specialCase!T || anySatisfy!(_implicit, DType);
	}
	
	static assert(allSatisfy!(compatible, DType));
	
	private template FunctionAs(Type type)
	{
		private enum string name_ = text(type);
		private enum string name = (name_[$-1]=='_')?(name_[0..$-1]):name_;
		
		mixin("alias FunctionAs = godot_variant_as_"~name~";");
	}
	private template FunctionNew(Type type)
	{
		private enum string name_ = text(type);
		private enum string name = (name_[$-1]=='_')?(name_[0..$-1]):name_;
		
		mixin("alias FunctionNew = godot_variant_new_"~name~";");
	}
	
	@disable this(this);
	@disable this();
	
	static Variant nil()
	{
		Variant v = void;
		godot_variant_new_nil(&v._godot_variant);
		return v;
	}
	
	this(in ref Variant other)
	{
		godot_variant_copy(&this._godot_variant, &other._godot_variant);
	}
	
	this(T)(in auto ref T input) if(!is(T == Variant) && !is(T==typeof(null)))
	{
		static if(isIntegral!T) enum VarType = Type.int_;
		else static if(isFloatingPoint!T) enum VarType = Type.real_;
		else static if(is(T : bool)) enum VarType = Type.bool_;
		//else static if(isSomeString!T) enum VarType = Type.string; // TODO
		else
		{
			enum bool _implicit(size_t di) = implicit!(T, DType[di]);
			alias Match = Filter!(_implicit, aliasSeqOf!(iota(DType.length)));
			static assert(Match.length != 0, "Type "~T.stringof~" isn't supported by Variant");
			static assert(Match.length == 1, "Multiple types match "~T.stringof);
			enum ptrdiff_t index = Match[0];
			enum VarType = EnumMembers!Type[index];
		}
		
		alias Fn = FunctionNew!VarType;
		alias PassType = Parameters!Fn[1]; // second param is the value
		
		alias IT = InternalType[VarType];
		
		static if(is(IT : godot_object)) Fn(&_godot_variant, cast(godot_object)cast(void*)input);
		else static if(is(IT == Unqual!PassType)) Fn(&_godot_variant, cast(IT)input); // value
		else Fn(&_godot_variant, cast(IT*)&input); // pointer
	}
	
	~this()
	{
		godot_variant_destroy(&_godot_variant);
	}
	
	Type type() const
	{
		return cast(Type)godot_variant_get_type(&_godot_variant);
	}
	
	inout(T) as(T : Variant)() inout { return this; }
	
	T as(T)() const if(!is(T == Variant) && !is(T==typeof(null)))
	{
		static if(isIntegral!T) enum VarType = Type.int_;
		else static if(isFloatingPoint!T) enum VarType = Type.real_;
		else static if(is(T : bool)) enum VarType = Type.bool_;
		//else static if(isSomeString!T) enum VarType = Type.string; // TODO
		else
		{
			enum bool _implicit(size_t di) = implicit!(T, DType[di]);
			alias Match = Filter!(_implicit, aliasSeqOf!(iota(DType.length)));
			static assert(Match.length != 0, "Type "~T.stringof~" isn't supported by Variant");
			static assert(Match.length == 1, "Multiple types match "~T.stringof);
			enum ptrdiff_t index = Match[0];
			enum VarType = EnumMembers!Type[index];
		}
		
		alias Fa = FunctionAs!VarType;
		
		alias IT = InternalType[VarType];
		
		IT ret = Fa(&_godot_variant);
		
		static if(isImplicitlyConvertible!(IT, T)) return ret;
		else return cast(T)ret;
		// TODO: *correct* conversion from C type may be different for a few types...
	}
	
	pragma(inline, true)
	void opAssign(T)(in auto ref T input)
	{
		import std.conv : emplace;
		emplace!(Variant)(&this, input);
	}
	
	bool opEquals(in ref Variant other) const
	{
		return cast(bool)godot_variant_operator_equal(&_godot_variant, &other._godot_variant);
	}
	
	int opCmp(in ref Variant other) const
	{
		if(godot_variant_operator_equal(&_godot_variant, &other._godot_variant))
			return 0;
		return godot_variant_operator_less(&_godot_variant, &other._godot_variant)?
			-1 : 1;
	}
	
	bool booleanize(bool* valid) const
	{
		godot_bool v;
		auto ret = godot_variant_booleanize(&_godot_variant, &v);
		*valid = cast(bool)v;
		return cast(bool)ret;
	}
}
