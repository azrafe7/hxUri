/*
 * Copyright © 2007 Dominic Mitchell
 * Copyright © 2016 Giuseppe Di Mauro (haxe port and improvements)
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * Neither the name of the Dominic Mitchell nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package hxUri;

import hxUri.Uri.UriQuery;
import Map;
import StringTools;

using hxUri.Uri.Tools;

/**
 * An URI datatype.  Based upon examples in RFC3986.
 * 
 * 
 * This code is based on js-uri (https://code.google.com/archive/p/js-uri/)
 * 
 * NOTES:
 * 
 *  - implemented as abstract
 *  - fluent interface for Uri setters
 *  - using an OrderedMap for params (using Sven Bergström's implementation - see below)
 *    (this means that enumerating params retains keys' insertion order (they are not sorted as in the original impl.))
 *  - added getParams(key) to get the array of values associated with key
 *  - added hasFragment, hasScheme, etc. (f.e. useful to represent/identify an empty fragment value (as in "http://www.example.com/emptyfrag#"))
 *  - getFragment(), getScheme(), etc. are guaranteed to return "" if the related field is null
 *  - to/from String
 *  
 *  @see http://web.archive.org/web/20150518202232/https://skew.org/uri/uri_tests.html for tests with various implementation
 * 
 * @author azrafe7
 */

@:forward
@:allow(hxUri.UriData)
@:allow(hxUri.UriQuery)
abstract Uri(UriData) from UriData to UriData {

	inline public function new(uri:String = "") {
		this = new UriData(uri);
	}
	
	public function clone():Uri {
		return new Uri(this.toString());
	}
	
	@:to public function toString():String {
		return this.toString();
	}
	
	@:from static public function fromString(str:String):Uri {
		return new Uri(str);
	}
	
	
	//// HELPER FUNCTIONS /////
  
    static function escape(source) {
        return StringTools.urlEncode(source);
    }

    static function unescape(source) {
        return StringTools.urlDecode(source);
    }

    // RFC3986 §5.2.3 (Merge Paths)
    static function merge(base:Uri, relPath:String) {
        var dirName = ~/^(.*)\//;
        if (!base.authority.isNullOrEmpty() && base.path == "") {
            return "/" + relPath;
        }
        else {
			var basePath = (dirName.match(base.getPath())) ? dirName.matched(0) : "";
			return basePath + relPath;
        }
    }

	// Based on the regex in RFC2396 Appendix B.
	static var parser = ~/^(?:([^:\/?#]+):)?(?:\/\/([^\/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?/;
  
    // Match two path segments, where the second is ".." and the first must
    // not be "..".
    static var doubleDot:EReg = ~/\/((?!\.\.\/)[^\/]*)\/\.\.\//;

	
    static function removeDotSegments(path:String):String {
        if (path.isNullOrEmpty()) {
            return "";
        }
        // Replace any single dots
        var newPath = ~/\/\.\//g.replace(path, '/');
        // Replace any trailing single dots.
        newPath = ~/\/\.$/.replace(newPath, '/');
        // Replace any double dots and the path previous.  NB: We can't use
        // the "g", modifier because we are changing the string that we're
        // matching over.
        while (doubleDot.match(newPath)) {
            newPath = doubleDot.replace(newPath, '/');
        }
        // Replace any trailing double dots.
        newPath = ~/\/([^\/]*)\/\.\.$/.replace(newPath, '/');
        // If there are any remaining double dot bits, then they're wrong
        // and must be nuked.  Again, we can't use the g modifier.
        while (~/\/\.\.\//.match(newPath)) {
            newPath = ~/\/\.\.\//.replace(newPath, '/');
        }
        // Remove starting dots forming complete paths (".", "..") and "./"
		newPath = ~/(^\.+$)|(^\.\/)/.replace(newPath, '');
        return newPath;
    }
}    


@:allow(hxUri.Uri)
class UriData {
	
	var scheme:String    = null;
	var authority:String = null;
	var path:String      = null;
	var query:String     = null;
	var fragment:String  = null;
	
	
	// The following return true only if the parser regex has matched the related fields
	
	var hasScheme(get, never):Bool;
	inline function get_hasScheme():Bool return scheme != null;
	
	var hasAuthority(get, never):Bool;
	inline function get_hasAuthority():Bool return authority != null;

	var hasPath(get, never):Bool;
	inline function get_hasPath():Bool return path != null;
	
	var hasQuery(get, never):Bool;
	inline function get_hasQuery():Bool return query != null;
	
	var hasFragment(get, never):Bool;
	inline function get_hasFragment():Bool return fragment != null;
	
	
    //// URI CLASS /////

    // Constructor for the URI object.  Parse a string into its components.
	public function new(uri:String = "") {
		
		var result = Uri.parser.matchAll(uri);
        
        // Keep the results in private variables.
		scheme    = result[1];
        authority = result[2];
        path      = result[3];
        query     = result[4];
        fragment  = result[5];
	}
	
	// Accessors (return "" in case the related field is null).
	
	public function getScheme():String {
		return hasScheme ? scheme : "";
	}
	
	public function setScheme(scheme:String):Uri {
		this.scheme = scheme;
		return this;
	}
	
	public function getAuthority():String {
		return hasAuthority ? authority : "";
	}
	
	public function setAuthority(authority:String):Uri {
		this.authority = authority;
		return this;
	}
	
	public function getPath():String {
		return hasPath ? path : "";
	}
	
	public function setPath(path:String):Uri {
		if (path.charAt(0) != "/") path = "/" + path;
		this.path = path;
		return this;
	}
	
	public function getQuery():String {
		return hasQuery ? query : "";
	}
	
	public function setQuery(query:String):Uri {
		this.query = query;
		return this;
	}
	
	public function getFragment():String {
		return hasFragment ? fragment : "";
	}
	
	public function setFragment(fragment:String):Uri {
		this.fragment = fragment;
		return this;
	}
	
	
    // Restore the URI to its stringy glory.
    public function toString():String {
        var str = "";
        if (hasScheme) {
            str += scheme + ":";
        }
        if (hasAuthority) {
            str += "//" + authority;
        }
        if (hasPath) {
            str += path;
        }
        if (hasQuery) {
            str += "?" + query;
        }
        if (hasFragment) {
            str += "#" + fragment;
        }
        return str;
    }

    // RFC3986 §5.2.2. Transform References;
    public function resolve(base:Uri):Uri {
        var target = new Uri();
        if (this.hasScheme) {
            target
				.setScheme(this.scheme)
				.setAuthority(this.authority)
				.setPath(Uri.removeDotSegments(this.path))
				.setQuery(this.query);
        }
        else {
            if (this.hasAuthority) {
                target
					.setAuthority(this.authority)
					.setPath(Uri.removeDotSegments(this.path))
					.setQuery(this.query);
            }        
            else {
                // XXX Original spec says "if defined and empty"…;
                if (this.path == "") {
                    target.setPath(base.path);
                    if (this.hasQuery) {
                        target.setQuery(this.query);
                    }
                    else {
                        target.setQuery(base.query);
                    }
                }
                else {
                    if (this.getPath().charAt(0) == '/') {
                        target.setPath(Uri.removeDotSegments(this.path));
                    } else {
                        target.setPath(Uri.merge(base, this.path));
                        target.setPath(Uri.removeDotSegments(target.path));
                    }
                    target.setQuery(this.query);
                }
                target.setAuthority(base.authority);
            }
            target.setScheme(base.scheme);
        }

        target.setFragment(this.fragment);

		return target;
    }
    
	
	public function parseQuery(sep:String = "&"):UriQuery {
        return UriQuery.fromString(this.getQuery(), sep);
    }
}


typedef UriQueryParams = OrderedMap<String, Array<String>>;


//// URIQuery CLASS /////

class UriQuery {
	
	public var separator:String = null;
	public var params:UriQueryParams = null;
	

	public function new(sourceString:String = "", separator:String = "&") { 
		this.separator = separator;
		this.params = new OrderedMap(new Map());
		addStringParams(sourceString);
	}
	
    // From http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.1
    // (application/x-www-form-urlencoded).
    // 
    // NB: The user can get this.params and modify it directly.
	public function addStringParams(sourceString:String):UriQuery {
        var kvp = sourceString.split(this.separator);
        var list, key, value;
        for (i in 0...kvp.length) {
            list  = kvp[i].split("=").splice(0, 2);
			if (list[1] == null) list[1] = "";
            addParam(list[0], list[1]);
        }
		
		return this;
    }
	
	public function getParam(key:String):String {
        if (this.params.exists(key)) {
            return this.params.get(key)[0];
        }
        return null;
    }

	public function getParams(key:String):Array<String> {
        if (this.params.exists(key)) {
            return this.params.get(key);
        }
        return null;
    }

	public function addParam(key:String, value:String):UriQuery {
		if (key == "") return this;
		if (!this.params.exists(key)) {
			this.params.set(key, []);
		}
		key   = Uri.unescape(~/\+/g.replace(key, " "));
		value = Uri.unescape(~/\+/g.replace(value, " "));
		this.params.get(key).push(value);
		
		return this;
    }

	public function toString():String {
        var kvp = [];
        for (key in params.keys()) {
			var list = this.params.get(key);
			key = ~/[ ]+/g.split(key).map(Uri.escape).join("+");
			for (value in list) {
				value = ~/[ ]+/g.split(value).map(Uri.escape).join("+");
				if (value != "") kvp.push(key + "=" + value);
				else kvp.push(key); // handle empty value
			}
		}
        return kvp.join(this.separator);
    }
	
	
	public static function fromString(sourceString:String, sep:String = null):UriQuery {
        var result = new UriQuery();
        if (sep != null) {
            result.separator = sep;
        }
        result.addStringParams(sourceString);
        return result;
	}
	
}


class Tools {
	
	public inline static function isNullOrEmpty(str:String):Bool {
		return str == null || str == "";
	}

	public static function matchAll(regex:EReg, str:String):Array<String> {
		var result = [];
		
		if (regex.match(str)) {
			try {
				var i = 0;
				while (true) {
					result.push(regex.matched(i++));
				}
			} catch (err:Dynamic) { }
		}
		
		return result;
	}
}


/**
 * A simple Haxe ordered Map implementation, MIT license
 * 
 * @author Sven Bergström
 * @see https://gist.github.com/underscorediscovery/84341491930a5df325e7
 * @see https://groups.google.com/forum/#!searchin/haxelang/orderedmap/haxelang/_s0EGztF9_M/_-zNeOSKLsYJ
 * 
 */

private class OrderedMapIterator<K,V> {

    var map : OrderedMap<K,V>;
    var index : Int = 0;

    public function new(omap:OrderedMap<K,V>)
        map = omap;
    public function hasNext() : Bool
        return index < map._keys.length;
    public function next() : V
        return map.get( map._keys[index++] );

} //OrderedMapIterator

class OrderedMap<K, V> implements IMap<K, V> {

    var map:Map<K, V>;
    @:allow(hxUri.OrderedMapIterator)
    var _keys:Array<K>;
    var idx = 0;

    public function new(_map) {
       _keys = [];
       map = _map;
    }

    public function set(key, value) {
        if(_keys.indexOf(key) == -1) _keys.push(key);
        map[key] = value;
    }

    public function toString() {
        var _ret = ''; var _cnt = 0; var _len = _keys.length;
        for(k in _keys) _ret += '$k => ${map.get(k)}${(_cnt++<_len-1?", ":"")}';
        return '{$_ret}';
    }

    public function iterator()          return new OrderedMapIterator<K,V>(this);
    public function remove(key)         return map.remove(key) && _keys.remove(key);
    public function exists(key)         return map.exists(key);
    public function get(key)            return map.get(key);
    public inline function keys()       return _keys.iterator();

} //OrderedMap