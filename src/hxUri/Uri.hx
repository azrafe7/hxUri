/*
 * Copyright © 2007 Dominic Mitchell
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


/**
 * An URI datatype.  Based upon examples in RFC3986.
 * 
 * 
 * This is a port of js-uri (by azrafe7). Adapted from https://code.google.com/archive/p/js-uri/
 * 
 * NOTES:
 * 
 *  - implemented as abstract
 *  - fluent interface for Uri setters
 *  - using an OrderedMap for params
 *  - printing params retains the order of insertion (they are not sorted as in the original impl.)
 *  - added getParams(key) to get the array of values associated with key
 *  - init uri fields to "" (empty string), instead of null
 *  - to/from String
 */

@:forward
@:allow(hxUri.UriData)
@:allow(hxUri.UriQuery)
abstract Uri(UriData) from UriData to UriData {

	inline public function new(uri:String = "") {
		this = new UriData(uri);
	}
	
	@:to public function toString():String {
		return this.toString();
	}
	
	@:from static public function fromString(str:String):Uri {
		return new Uri(str);
	}
	
	
	//// HELPER FUNCTIONS /////
  
    // TODO: Make these do something
    static function escape(source) {
        return source;
    }

    static function unescape(source) {
        return source;
    }

    // RFC3986 §5.2.3 (Merge Paths)
    static function merge(base:Uri, relPath:String) {
        var dirName = ~/^(.*)\//;
        if (!Tools.isNullOrEmpty(base.authority) && Tools.isNullOrEmpty(base.path)) {
            return "/" + relPath;
        }
        else {
			var basePath = (dirName.match(base.getPath())) ? Tools.matchAll(dirName, base.getPath())[0] : "";
			return basePath + relPath;
        }
    }

	// Based on the regex in RFC2396 Appendix B.
	static var parser = ~/^(?:([^:\/?#]+):)?(?:\/\/([^\/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?/;
        
    // Match two path segments, where the second is ".." and the first must
    // not be "..".
    static var doubleDot:EReg = ~/\/((?!\.\.\/)[^\/]*)\/\.\.\//;

	
    static function removeDotSegments(path:String):String {
        if (Tools.isNullOrEmpty(path)) {
            return "";
        }
        // Remove any single dots
        var newPath = ~/\/\.\//g.replace(path, '/');
        // Remove any trailing single dots.
        newPath = ~/\/\.$/.replace(newPath, '/');
        // Remove any double dots and the path previous.  NB: We can't use
        // the "g", modifier because we are changing the string that we're
        // matching over.
        while (doubleDot.match(newPath)) {
            newPath = doubleDot.replace(newPath, '/');
        }
        // Remove any trailing double dots.
        newPath = ~/\/([^\/]*)\/\.\.$/.replace(newPath, '/');
        // If there are any remaining double dot bits, then they're wrong
        // and must be nuked.  Again, we can't use the g modifier.
        while (~/\/\.\.\//.match(newPath)) {
            newPath = ~/\/\.\.\//.replace(newPath, '/');
        }
        return newPath;
    }
}    


@:allow(hxUri.Uri)
class UriData {
	
	var scheme:String    = "";
	var authority:String = "";
	var path:String      = "";
	var query:String     = "";
	var fragment:String  = "";
	
	
    //// URI CLASS /////

    // Constructor for the URI object.  Parse a string into its components.
	public function new(uri:String = "") {
		
		var result = Tools.matchAll(Uri.parser, uri);
        
        // Keep the results in private variables.
		for (i in 0...6) if (result[i] == null) result[i] = "";
        scheme    = result[1];
        authority = result[2];
        path      = result[3];
        query     = result[4];
        fragment  = result[5];
	}
	
	// Accessors.
	
	public function getScheme():String {
		return scheme;
	}
	
	public function setScheme(scheme:String):Uri {
		this.scheme = scheme;
		return this;
	}
	
	public function getAuthority():String {
		return authority;
	}
	
	public function setAuthority(authority:String):Uri {
		this.authority = authority;
		return this;
	}
	
	public function getPath():String {
		return path;
	}
	
	public function setPath(path:String):Uri {
		this.path = path;
		return this;
	}
	
	public function getQuery():String {
		return query;
	}
	
	public function setQuery(query:String):Uri {
		this.query = query;
		return this;
	}
	
	public function getFragment():String {
		return fragment;
	}
	
	public function setFragment(fragment:String):Uri {
		this.fragment = fragment;
		return this;
	}
	
	
    // Restore the URI to it's stringy glory.
    public function toString():String {
        var str = "";
        if (!Tools.isNullOrEmpty(this.getScheme())) {
            str += this.getScheme() + ":";
        }
        if (!Tools.isNullOrEmpty(this.getAuthority())) {
            str += "//" + this.getAuthority();
        }
        if (!Tools.isNullOrEmpty(this.getPath())) {
            str += this.getPath();
        }
        if (!Tools.isNullOrEmpty(this.getQuery())) {
            str += "?" + this.getQuery();
        }
        if (!Tools.isNullOrEmpty(this.getFragment())) {
            str += "#" + this.getFragment();
        }
        return str;
    }

    // RFC3986 §5.2.2. Transform References;
    public function resolve(base:Uri):Uri {
        var target = new Uri();
        if (!Tools.isNullOrEmpty(this.getScheme())) {
            target
				.setScheme(this.getScheme())
				.setAuthority(this.getAuthority())
				.setPath(Uri.removeDotSegments(this.getPath()))
				.setQuery(this.getQuery());
        }
        else {
            if (!Tools.isNullOrEmpty(this.getAuthority())) {
                target
					.setAuthority(this.getAuthority())
					.setPath(Uri.removeDotSegments(this.getPath()))
					.setQuery(this.getQuery());
            }        
            else {
                // XXX Original spec says "if defined and empty"…;
                if (Tools.isNullOrEmpty(this.getPath())) {
                    target.setPath(base.getPath());
                    if (!Tools.isNullOrEmpty(this.getQuery())) {
                        target.setQuery(this.getQuery());
                    }
                    else {
                        target.setQuery(base.getQuery());
                    }
                }
                else {
                    if (this.getPath().charAt(0) == '/') {
                        target.setPath(Uri.removeDotSegments(this.getPath()));
                    } else {
                        target.setPath(Uri.merge(base, this.getPath()));
                        target.setPath(Uri.removeDotSegments(target.getPath()));
                    }
                    target.setQuery(this.getQuery());
                }
                target.setAuthority(base.getAuthority());
            }
            target.setScheme(base.getScheme());
        }

        target.setFragment(this.getFragment());

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
	

	public function new(separator:String = "&") { 
		this.separator = separator;
		this.params = new OrderedMap(new Map());
	}
	
    // From http://www.w3.org/TR/html401/interact/forms.html#h-17.13.4.1
    // (application/x-www-form-urlencoded).
    // 
    // NB: The user can get this.params and modify it directly.
	public function addStringParams(sourceString:String):UriQuery {
        var kvp = sourceString.split(this.separator);
        var list, key, value;
        for (i in 0...kvp.length) {
            // var [key,value] = kvp.split("=", 2) only works on >= JS 1.7
            list  = kvp[i].split("=").splice(0, 2);
            key   = Uri.unescape(~/\+/g.replace(list[0], " "));
            value = Uri.unescape(~/\+/g.replace(list[1], " "));
            if (!this.params.exists(key)) {
                this.params.set(key, []);
            }
            this.params.get(key).push(value);
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

	public function toString():String {
        var kvp = [];
        for (key in params.keys()) {
			var list = this.params.get(key);
			for (value in list) kvp.push(~/ /g.replace(key, "+") + "=" + ~/ /g.replace(value, "+"));
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


private class Tools {
	
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