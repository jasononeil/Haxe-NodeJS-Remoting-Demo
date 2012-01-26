package haxe.remoting;
#if macro
typedef SType = Type;

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;

using StringTools;


class MacroUtil
{
	/**
	  * Create a class type constant from a class name.
	  */
	public static function createClassConstant (className :String, pos :Position) :Expr
	{
		var pathTokens = className.split(".");
		
		if (pathTokens.length == 1) {
			return {expr: EConst(CType(className)), pos: pos};
		}
		
		var pathExpr = null;
		
		while (pathTokens.length > 1) {
			if (pathExpr == null) {
				pathExpr = {expr: EConst(CIdent(pathTokens.shift())), pos: pos};
			} else {
				pathExpr = {expr: EField(pathExpr, pathTokens.shift()), pos: pos};
			}
		}
		
		return {
			expr: EType(pathExpr, pathTokens.shift()),
			pos: pos
		}
	}
	
	/**
	  * If the class has class metadata @remoteId("someId") then "someId" will be used as 
	  * the remote id on the client and server.  Otherwise, the base class name will be used.
	  */
	public static function getRemotingIdFromManagerClassName (managerClassName :String) :String
	{
		// var pos = Context.currentPos();
		var remotingId = managerClassName.replace("Manager", "").replace("Service", "") + "Service";
		return remotingId.substr(0, 1).toLowerCase() + remotingId.substr(1);
		// var managerType = haxe.macro.Context.getType(managerClassName);
		
		// var remotingId = managerClassName.split(".")[managerClassName.split(".").length - 1]; 
		// switch (managerType) {
		// 	case TInst(t, params):
		// 		var metaAccess = t.get().meta;
		// 		var metaData = t.get().meta.get();
		// 		if (metaData != null) {
		// 			for (classMeta in metaData) {
		// 				// Context.warning("classMeta=" + classMeta, pos);
		// 				if (classMeta.name == "remoteId") {
		// 					for (metaParam in classMeta.params) {
		// 						// Context.warning("metaParam=" + metaParam, pos);
		// 						switch(metaParam.expr) {
		// 							case EConst(c):
		// 								switch(c) {
		// 									case CString(s): remotingId = s;
		// 									default: Context.warning(SType.enumConstructor(c) + " not handled", pos);
		// 								}
		// 							default: Context.warning(SType.enumConstructor(metaParam.expr) + " not handled", pos);
		// 						}
		// 					}
		// 				}
		// 			}
		// 		}
		// 	default: Context.warning(SType.enumConstructor(managerType) + " not handled", pos);
		// }
		// return remotingId;
	}
	
	/**
	  * If the class has class metadata @remoteId("fooService") then "FooService" will be used as 
	  * the remote id on the client and server.  Otherwise, the base class name will be used, 
	  * ending with "Service" if it doesn't already.
	  */
	public static function getRemotingInterfaceNameFromClassName (managerClassName :String) :String
	{
		var remoteId = managerClassName;//getRemotingIdFromClassDef(managerClassName);
		var tokens = remoteId.split(".");
		remoteId = tokens[tokens.length - 1];
		remoteId = remoteId.substr(0, 1).toUpperCase() + remoteId.substr(1);
		// if (!remoteId.endsWith("Service")) {
			remoteId += "Service";
		// }
		tokens[tokens.length - 1] = remoteId;
		return tokens.join('.'); 
	}
	
	public static function createNewFunctionBlock (remotingId :String, pos :haxe.macro.Position) :Field
	{
		var exprStr = '_conn = c.resolve("' + remotingId + '")';
			
		var func :haxe.macro.Function = {
			ret: null,
			params: [],
			//The expression contains the call to the context
			expr: {expr: ExprDef.EBlock([haxe.macro.Context.parse(exprStr, pos)]), pos:pos},
			args: [{value:null, opt:false, name:"c", type:ComplexType.TPath({sub:null, params:[], pack:["haxe", "remoting"], name:"AsyncConnection"})}] //<FunctionArg>
		}
		
		return {
			name : "new", 
			doc : null, 
			meta : [],
			access : [Access.APublic],
			kind : FieldType.FFun(func),
			pos : pos 
		}
	}
	
	public static function createConnectionField (pos :Position) :Field
	{
		// Add "var _conn :haxe.remoting.AsyncConnection;"
		return {
			name : "_conn", 
			doc : null, 
			meta : [], 
			access : [Access.APrivate], 
			kind : FVar(TPath({ pack : ["haxe", "remoting"], name : "AsyncConnection", params : [], sub : null }), null), 
			pos : pos 
		};
	}
	
	
	public static function getClassNameFromClassExpr (classNameExpr :Expr) :String
	{
		// Context.warning("classNameExpr=" + classNameExpr, Context.currentPos());
		var drillIntoEField = null;
		var className = "";
		drillIntoEField = function (e :Expr) :String {
			switch(e.expr) {
				case EField(e2, field):
					return drillIntoEField(e2) + "." + field;
				case EConst(c):
					switch(c) {
						case CIdent(s):
							// Context.warning("CIdent=" + s, Context.currentPos());
							return s;
						case CString(s):
							// Context.warning("CString=" + s, Context.currentPos());
							return s;
						default:Context.warning(SType.enumConstructor(c) + " not handled", Context.currentPos());
							return "";
					}
				default: Context.warning(SType.enumConstructor(e.expr) + " not handled", Context.currentPos());
					return "";
			}
		}
		
		switch(classNameExpr.expr) {
			case EType(e1, field):
				className = field;
				// Context.warning(className, Context.currentPos());
				switch(e1.expr) {
					case EField(e2, field):
						className = drillIntoEField(e1) + "." + className;
					case EConst(c):
						switch(c) {
							case CIdent(s):
								className = s + "." + className;
							case CString(s):
								className = s + "." + className;
							default:Context.warning(SType.enumConstructor(c) + " not handled", Context.currentPos());
						}
					default: Context.warning(SType.enumConstructor(e1.expr) + " not handled", Context.currentPos());
				}
			case EConst(c):
				switch(c) {
					case CIdent(s):
						// Context.warning(s, Context.currentPos());
						className = s;
					case CString(s):
						// Context.warning(s, Context.currentPos());
						className = s;
					case CType(s):
						// Context.warning(s, Context.currentPos());
						className = s;
					default:Context.warning(SType.enumConstructor(c) + " not handled", Context.currentPos());
				}
			default: Context.warning(SType.enumConstructor(classNameExpr.expr) + " not handled", Context.currentPos());
		}
		return className;
	}
	
	public static function isInterfaceExpr (typeExpr :Expr) :Bool
	{
		switch(typeExpr.expr) {
			case EType(e1, field):
				switch(Context.typeof(typeExpr)) {
					case TType(t, params):
						return true;
					default: 
						return false;
				}
			default: return false;
		}
	}
	
	public static function getProxyRemoteClassName(className : String) :String
	{
		return className + "Proxy";
	}
}
#end
