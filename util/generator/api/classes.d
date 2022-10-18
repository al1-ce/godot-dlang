module api.classes;

import godotutil.string;
import api.methods, api.enums, api.util;

import asdf;

import std.range;
import std.algorithm.searching, std.algorithm.iteration, std.algorithm.sorting;
import std.path;
import std.conv : text;
import std.string;

struct ClassList
{
	GodotClass[] classes;
	GodotClass[Type] dictionary;
}

struct ClassConstant
{
	string name;
	int value;
}

struct BuiltinConstant
{
	string name;
	string value;
	@serdeOptional Type type;

	// have to manually parse it as in different types value can be both string or int
	SerdeException deserializeFromAsdf(Asdf data)
    {
		// here we try read 3 options, 'name' variant is for native_structs
        name = data["name"].get!string(null);

		// optional
		if (auto ty = data["type"].get!string(null))
		{
			type = Type.get(ty);
		}

		// try read string, otherwise simply assume it's an int
		value = data["value"].get!string(null);
		if (value is null)
		{
			value = text(data["value"].get!int(0));
		}
		
        return null;
    }
}



struct Operator
{
	string name;
	@serdeOptional Type right_type;
	//@serdeOptional
	Type return_type;
}

class Constructor : GodotMethod
{
	int index;
	//@serdeOptional CtorArguments[] arguments;

	override void finalizeDeserialization(Asdf data)
	{
		super.finalizeDeserialization(data);
		name = "new_" ~ text(index);
	}

	override Constructor isConstructor() const
	{
		return cast() this;
	}

	override string funKindName() const 
	{
		return "ctor";
	}

	override string loader() const
	{
		return format(`GDNativeClassBinding.%s.mb = _godot_api.variant_get_ptr_constructor(%s, %d);`,
			wrapperIdentifier,
			parent.name.toNativeVariantType(),
			index
		);
	}
}

//struct CtorArguments
//{
//	string name;
//	Type type;
//}

// they are unrelated actually but have same fields
//alias BuiltinMembers = CtorArguments;
alias BuiltinMembers = GodotArgument;


final class GodotClass
{
	Type name;
	@serdeOptional @serdeKeys("inherits", "base_class") Type base_class;
	@serdeOptional string api_type;
	@serdeOptional bool singleton;
	@serdeOptional string singleton_name;
	@serdeOptional @serdeKeys("is_instantiable", "instanciable") bool instanciable;
	@serdeOptional @serdeKeys("is_refcounted", "is_reference") bool is_reference;
	@serdeOptional BuiltinConstant[] constants; // TODO: can constants be things other than ints?
	@serdeOptional GodotMethod[] methods;
	@serdeOptional GodotProperty[] properties;
	@serdeOptional GodotEnum[] enums;

	// built-in types only
	@serdeIgnore bool isBuiltinClass;
	@serdeOptional bool has_destructor;
	@serdeOptional bool is_keyed;
	@serdeOptional Type indexing_return_type;
	@serdeOptional Operator[] operators;
	@serdeOptional Constructor[] constructors;
	@serdeOptional BuiltinMembers[] members;
	// end built-in types only
	
	void addUsedClass(in Type c)
	{
		auto u = c.unqual();
		if(u.isPrimitive || u.isCoreType || u.godot == "Object") return;
		if(u.isTypedArray) u = u.arrayType;
		if(!used_classes.canFind(u)) used_classes ~= u;
	}

	void finalizeDeserialization(Asdf data)
	{
		assert(name.objectClass is null);
		name.objectClass = this;
		name.original = this;

		// why they are different? name != Type.get(name.godot)
		Type.get(name.godot).original = this;
		Type.get(name.godot).objectClass = this;
		
		if(base_class && base_class.godot != "Object" && name.godot != "Object") used_classes ~= base_class;
		
		foreach(m; constructors)
		{
			m.parent = this;
			m.return_type = name;
		}
		foreach(m; methods)
		{
			m.parent = this;
		}
		foreach(ref e; enums)
		{
			e.parent = this;
			foreach(n; e.values) constantsInEnums ~= n.name;
		}
	}
	
	@serdeIgnore:
	//ClassList* parent;
	
	const(Type)[] used_classes;
	//GodotClass base_class_ptr = null; // needs to be set after all classes loaded
	GodotClass[] descendant_ptrs; /// direct descendent classes
	
	Type[] missingEnums; /// enums that were left unregistered in Godot
	
	string ddocBrief;
	string ddoc;
	string[string] ddocConstants;
	
	string[] constantsInEnums; // names of constants that are enum members
	
	string bindingStruct() const
	{
		string ret = "\tpackage(godot) __gshared bool _classBindingInitialized = false;\n";
		ret ~= "\tpackage(godot) static struct GDNativeClassBinding\n\t{\n";
		ret ~= "\t\t__gshared:\n";
		if(singleton)
		{
			ret ~= "\t\tgodot_object _singleton;\n";
			ret ~= "\t\timmutable char* _singletonName = \""~name.godot.chompPrefix("_")~"\";\n";
		}
		foreach(const ct; constructors)
		{
			ret ~= ct.binding;
		}
		if (has_destructor)
		{
			ret ~= destuctorBinding();
		}
		foreach(const m; methods)
		{
			ret ~= m.binding;
		}
		ret ~= "\t}\n";
		return ret;
	}

	string destuctorBinding() const
	{
		string ret;
		ret ~= "\t\tGDNativePtrDestructor destructor;\n";
		return ret;
	}
	
	string source()
	{
		string ret;

		// generate the set of referenced classes
		foreach(m; joiner([cast(GodotMethod[]) constructors, methods]))
		{
			// TODO: unify return and parameters logic, well that sucks as it basically repeats itself
			// maybe a simple chain(ret, args[]) will do?
			import std.algorithm.searching;
			if(m.return_type.isEnum)
			{
				auto c = m.return_type.enumParent;
				if (!c)
					c = Type.get(enumParent(m.return_type.godot));
				if(c && c !is name) addUsedClass(c);
			}
			else if(m.return_type !is name)
			{
				addUsedClass(m.return_type);
			}
			foreach(const a; m.arguments)
			{
				if(a.type.isEnum)
				{
					auto c = cast() a.type.enumParent;
					if (!c)
						c = Type.get(enumParent(a.type.godot));
					if(c && c !is name) addUsedClass(c);
				}
				else if(a.type !is name)
				{
					addUsedClass(a.type);
				}
			}
		}
		foreach(p; properties)
		{
			// some crazy property named like "streams" that returns "stream_" type (that does not exists)
			if (!(p.getter && p.setter))
				continue;

			Type pType;
			GodotMethod getterMethod;
			foreach(GodotClass c; BaseRange(cast()this))
			{
				if(!getterMethod)
				{
					auto g = c.methods.find!(m => m.name == p.getter);
					if(!g.empty) getterMethod = g.front;
				}
				
				if(getterMethod) break;
				if(c.base_class is null) break;
			}
			if(getterMethod) pType = getterMethod.return_type;
			else pType = p.type;

			if(pType.godot.canFind(',')) continue; /// FIXME: handle with common base. Also see godot#35467
			if(pType.isEnum)
			{
				auto c = pType.enumParent;
				if(c && c !is name) addUsedClass(c);
			}
			else if(pType !is name)
			{
				addUsedClass(pType);
			}
		}
		assert(!used_classes.canFind(name));
		assert(!used_classes.canFind!(c => c.godot == "Object"));

		if (!isBuiltinClass)
		{
			ret ~= "module godot." ~ name.moduleName ~ ";\n\n";

			ret ~= `import std.meta : AliasSeq, staticIndexOf;
import std.traits : Unqual;
import godot.d.traits;
import godot.core;
import godot.c;
import godot.d.bind;
import godot.d.reference;
import godot.globalenums;
import godot.object;
import godot.classdb;`;
			ret ~= "\n";
		}

		foreach(const u; used_classes)
		{
			if (!u.moduleName)
				continue;
			ret ~= "import godot.";
			ret ~= u.moduleName;
			ret ~= ";\n";
		}

		string className = name.d;
		if(singleton) className ~= "Singleton";
		if(isBuiltinClass) className ~= "_Bind";
		ret ~= "/**\n"~ddoc~"\n*/\n";
		ret ~= "@GodotBaseClass struct "~className;
		ret ~= "\n{\n";
		ret ~= "\tpackage(godot) enum string _GODOT_internal_name = \""~name.godot~"\";\n";
		ret ~= "public:\n";
		// way to much PITA, ignore for now
		//ret ~= "@nogc nothrow:\n";
		
		// Pointer to Godot object, fake inheritance through alias this
		if(name.godot != "Object" && name.godot != "CoreConstants" && !isBuiltinClass)
		{
			ret ~= "\tunion { /** */ godot_object _godot_object; /** */ "~base_class.d;
			if(base_class && base_class.original && base_class.original.singleton) 
				ret ~= "Singleton";
			ret ~= " _GODOT_base; }\n\talias _GODOT_base this;\n";
			ret ~= "\talias BaseClasses = AliasSeq!(typeof(_GODOT_base), typeof(_GODOT_base).BaseClasses);\n";
		}
		else
		{
			ret ~= "\tgodot_object _godot_object;\n";
			ret ~= "\talias BaseClasses = AliasSeq!();\n";
		}
		
		ret ~= bindingStruct;
		
		// equality
		ret ~= "\t/// \n";
		ret ~= "\tpragma(inline, true) bool opEquals(in "~className~" other) const\n";
		ret ~= "\t{ return _godot_object.ptr is other._godot_object.ptr; }\n";
		// null assignment to simulate D class references
		ret ~= "\t/// \n";
		ret ~= "\tpragma(inline, true) typeof(null) opAssign(typeof(null) n)\n";
		ret ~= "\t{ _godot_object.ptr = n; return null; }\n";
		// equality with null; unfortunately `_godot_object is null` doesn't work with structs
		ret ~= "\t/// \n";
		ret ~= "\tpragma(inline, true) bool opEquals(typeof(null) n) const\n";
		ret ~= "\t{ return _godot_object.ptr is n; }\n";
		// comparison operator
		if(name.godot == "Object")
		{
			ret ~= "\t/// \n";
			ret ~= "\tpragma(inline, true) int opCmp(in GodotObject other) const\n";
			ret ~= "\t{ const void* a = _godot_object.ptr, b = other._godot_object.ptr; return a is b ? 0 : a < b ? -1 : 1; }\n";
			ret ~= "\t/// \n";
			ret ~= "\tpragma(inline, true) int opCmp(T)(in T other) const if(extendsGodotBaseClass!T)\n";
			ret ~= "\t{ const void* a = _godot_object.ptr, b = other.owner._godot_object.ptr; return a is b ? 0 : a < b ? -1 : 1; }\n";
		}
		// hash function
		ret ~= "\t/// \n";
		ret ~= "\textern(D) size_t toHash() const nothrow @trusted { return cast(size_t)_godot_object.ptr; }\n";
		
		ret ~= "\tmixin baseCasts;\n";

		// Godot constructor.
		ret ~= "\t/// Construct a new instance of "~className~".\n";
		ret ~= "\t/// Note: use `memnew!"~className~"` instead.\n";
		ret ~= "\tstatic "~className~" _new()\n\t{\n";
		ret ~= "\t\tif(auto obj = _godot_api.classdb_construct_object(\""~name.godot~"\"))\n";
		ret ~= "\t\t\treturn "~className~"(godot_object(obj));\n";
		ret ~= "\t\treturn typeof(this).init;\n";
		ret ~= "\t}\n";

		foreach(ct; constructors)
		{
			//ret ~= "\tstatic "~name.d~" "~ ct.name ~ ct.templateArgsString ~ ct.argsString ~ "\n\t{\n";
			//ret ~= "\t\tif(auto fn = _godot_api.variant_get_ptr_constructor(GDNATIVE_VARIANT_TYPE_"~name.godot.snakeToCamel.toUpper ~ ", " ~ text(ct.index) ~"))\n";
			//ret ~= "\t\t\treturn "~name.d~"(godot_object(fn(...)));\n";
			//ret ~= "\t\treturn typeof(this).init;\n";
			//ret ~= "\t}\n";
			ret ~= ct.source;
		}

		// currently only core types can have destructor
		if (has_destructor)
		{
			ret ~= "\tvoid _destructor()\n";
			ret ~= "\t{\n";
			ret ~= "\t\tif (!GDNativeClassBinding.destructor)\n";
			ret ~= "\t\t\tGDNativeClassBinding.destructor = _godot_api.variant_get_ptr_destructor(GDNATIVE_VARIANT_TYPE_"~name.godot.camelToSnake.toUpper ~ ");\n";
			ret ~= "\t\tGDNativeClassBinding.destructor(&_godot_object);\n";
			ret ~= "\t}\n";
		}

		//ret ~= "\t@disable new(size_t s);\n";
		
		foreach(const ref e; enums)
		{
			ret ~= e.source;
		}
		
		foreach(const ref e; missingEnums)
		{
			import std.stdio;
			writeln("Warning: The enum "~e.d~" is missing from Godot's script API; using a non-typesafe int instead.");
			ret ~= "\t/// Warning: The enum "~e.d~" is missing from Godot's script API; using a non-typesafe int instead.\n";
			ret ~= "\tdeprecated(\"The enum "~e.d~" is missing from Godot's script API; using a non-typesafe int instead.\")\n";
			string shortName = e.d[e.d.countUntil(".")+1..$];
			ret ~= "\talias " ~ shortName ~ " = int;\n";
		}
		
		if(!isBuiltinClass && constants.length)
		{
			ret ~= "\t/// \n";
			ret ~= "\tenum Constants : int\n\t{\n";
			foreach(constant; constants.sort!((a, b)=>(a.value < b.value)))
			{
				if(!constantsInEnums.canFind(constant.name)) // don't document enums here; they have their own ddoc
				{
					if(auto ptr = constant.name in ddocConstants) ret ~= "\t\t/**\n\t\t" ~ (*ptr).replace("\n", "\n\t\t") ~ "\n\t\t*/\n";
					else ret ~= "\t\t/** */\n";
				}
				ret ~= "\t\t"~constant.name.snakeToCamel.escapeD~" = "~text(constant.value)~",\n";
			}
			ret ~= "\t}\n";
		}

		foreach(const m; methods)
		{
			ret ~= m.source;
		}
		
		foreach(const p; properties)
		{
			import std.stdio : writeln;
			if(p.type.godot.canFind(',')) continue; /// FIXME: handle with common base
			
			GodotMethod getterMethod, setterMethod;
			
			foreach(GodotClass c; BaseRange(cast()this))
			{
				if(!getterMethod)
				{
					auto g = c.methods.find!(m => m.name == p.getter);
					if(!g.empty) getterMethod = g.front;
				}
				if(!setterMethod)
				{
					auto s = c.methods.find!(m => m.name == p.setter);
					if(!s.empty) setterMethod = s.front;
				}
				
				if(getterMethod && setterMethod) break;
				
				if(c.base_class is null)
				{
					if(!getterMethod) writeln("Warning: property ", name.godot, ".", p.name, " specifies a getter that doesn't exist: ", p.getter);
					if(p.setter.length && !setterMethod) writeln("Warning: property ", name.godot, ".", p.name, " specifies a setter that doesn't exist: ", p.setter);
					break;
				}
			}
			
			if(getterMethod) ret ~= p.getterSource(getterMethod);
			if(p.setter.length)
			{
				if(setterMethod) ret ~= p.setterSource(setterMethod);
			}
		}
		
		
		
		
		ret ~= "}\n";
		
		if(singleton)
		{
			ret ~= "/// Returns: the "~className~"\n";
			//ret ~= "@property @nogc nothrow pragma(inline, true)\n";
			ret ~= "@property pragma(inline, true)\n";
			ret ~= className ~ " " ~ name.d;
			ret ~= "()\n{\n";
			ret ~= "\tcheckClassBinding!"~className~"();\n";
			ret ~= "\treturn "~className~"("~className~".GDNativeClassBinding._singleton);\n";
			ret ~= "}\n";
		}
		
		return ret;
	}
	
	struct BaseRange
	{
		GodotClass front;
		BaseRange save() const { return cast()this; }
		bool empty() const { return front is null; }
		void popFront() { front = front.base_class.original; }
	}
}


