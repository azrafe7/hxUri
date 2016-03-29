/* Tests from resolve.t.html and http://skew.org/uri/uri_tests.html */

package hxUri;

import hxUri.Uri;
import utest.Assert;


typedef UriTest = {
	var num:Int;
	var ref:String;
	var base:String;
	var expected:Array<String>;
}


class TestResolve {
	
	public function new() { }
	
    public function testResolveSkew() {
		for (test in testsSkew) {
			var ref = test.ref;
			var base = test.base;
			var expected = test.expected;
			
			var result = Uri.fromString(ref).resolve(base).toString();
			
			var expectedJoin = expected.join('" or "');
			var errorMsg = '[test ${test.num}]: expected "$expectedJoin" but it is "$result"';
			
			if (expected.length == 1) {
				Assert.equals(expected[0], result, errorMsg);
			} else {
				Assert.allows(expected, result, errorMsg);
			}
		}
		
		var passed = Assert.results.filter(function(a) { return a.match(Success(_)); }).length;
		Assert.warn('hxUri resolve (skew.org tests): $passed of ${Assert.results.length} passed');
    }

    public function testResolve() {
		for (i in 0...resolve_tests.length) {
			var test = resolve_tests[i];
			var ref = test[0];
			var base = this.base;
			var expected = test[1];
			
			var result = Uri.fromString(ref).resolve(base).toString();
			
			var errorMsg = '[test ${i + 1}]: expected "$expected" but it is "$result"';
			
			Assert.equals(expected, result, errorMsg);
		}
		
		var passed = Assert.results.filter(function(a) { return a.match(Success(_)); }).length;
		Assert.warn('hxUri resolve (js-uri tests): $passed of ${Assert.results.length} passed');
    }

	
	// from resolve.t.html
	var base = new Uri("http://a/b/c/d;p?q");
	var resolve_tests:Array<Array<String>> = [
		// Normal examples.
		["g:h",     "g:h"],
		["g",       "http://a/b/c/g"],
		["./g",     "http://a/b/c/g"],
		["g/",      "http://a/b/c/g/"],
		["/g",      "http://a/g"],
		["//g",     "http://g"],
		["?y",      "http://a/b/c/d;p?y"],
		["g?y",     "http://a/b/c/g?y"],
		["#s",      "http://a/b/c/d;p?q#s"],
		["g#s",     "http://a/b/c/g#s"],
		["g?y#s",   "http://a/b/c/g?y#s"],
		[";x",      "http://a/b/c/;x"],
		["g;x",     "http://a/b/c/g;x"],
		["g;x?y#s", "http://a/b/c/g;x?y#s"],
		["",        "http://a/b/c/d;p?q"],
		[".",       "http://a/b/c/"],
		["./",      "http://a/b/c/"],
		["..",      "http://a/b/"],
		["../",     "http://a/b/"],
		["../g",    "http://a/b/g"],
		["../..",   "http://a/"],
		["../../",  "http://a/"],
		["../../g", "http://a/g"],

		// Abnormal examples.
		// 1. Going up further than is possible.
		["../../../g",    "http://a/g"],
		["../../../../g", "http://a/g"],

		// 2. Not matching dot boundaries correctly.
		["/./g",  "http://a/g"],
		["/../g", "http://a/g"],
		["g.",    "http://a/b/c/g."],
		[".g",    "http://a/b/c/.g"],
		["g..",   "http://a/b/c/g.."],
		["..g",   "http://a/b/c/..g"],

		// 3. Nonsensical path segments.
		["./../g",     "http://a/b/g"],
		["./g/.",      "http://a/b/c/g/"],
		["g/./h",      "http://a/b/c/g/h"],
		["g/../h",     "http://a/b/c/h"],
		["g;x=1/./y",  "http://a/b/c/g;x=1/y"],
		["g;x=1/../y", "http://a/b/c/y"],

		// 4. Paths in the query string should be ignored.
		["g?y/./x",  "http://a/b/c/g?y/./x"],
		["g?y/../x", "http://a/b/c/g?y/../x"],
		["g#s/./x",  "http://a/b/c/g#s/./x"],
		["g#s/../x", "http://a/b/c/g#s/../x"],

		// 5. Backwards compatibility
		["http:g", "http:g"]
	];
	
	
	// from resolve.t.html
	var testsSkew:Array<UriTest> = [
		{ num: 1, ref: "", base: "/web/20150519075506/http://example.com/path?query#frag", expected: ["/web/20150519075506/http://example.com/path?query"] },
		{ num: 2, ref: "../c", base: "foo:a/b", expected: ["foo:c"] },
		{ num: 3, ref: "foo:.", base: "foo:a", expected: ["foo:"] },
		{ num: 4, ref: "/foo/../../../bar", base: "zz:abc", expected: ["zz:/bar"] },
		{ num: 5, ref: "/foo/../bar", base: "zz:abc", expected: ["zz:/bar"] },
		{ num: 6, ref: "foo/../../../bar", base: "zz:abc", expected: ["zz:bar"] },
		{ num: 7, ref: "foo/../bar", base: "zz:abc", expected: ["zz:bar"] },
		{ num: 8, ref: "zz:.", base: "zz:abc", expected: ["zz:"] },
		{ num: 9, ref: "/.", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/"] },
		{ num: 10, ref: "/.foo", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/.foo"] },
		{ num: 11, ref: ".foo", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/.foo"] },
		{ num: 12, ref: "g:h", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["g:h"] },
		{ num: 13, ref: "g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g"] },
		{ num: 14, ref: "./g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g"] },
		{ num: 15, ref: "g/", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g/"] },
		{ num: 16, ref: "/g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/g"] },
		{ num: 17, ref: "//g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://g"] },
		{ num: 18, ref: "?y", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/d;p?y"] },
		{ num: 19, ref: "g?y", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g?y"] },
		{ num: 20, ref: "#s", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/d;p?q#s"] },
		{ num: 21, ref: "g#s", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g#s"] },
		{ num: 22, ref: "g?y#s", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g?y#s"] },
		{ num: 23, ref: ";x", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/;x"] },
		{ num: 24, ref: "g;x", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g;x"] },
		{ num: 25, ref: "g;x?y#s", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g;x?y#s"] },
		{ num: 26, ref: "", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/d;p?q"] },
		{ num: 27, ref: ".", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/"] },
		{ num: 28, ref: "./", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/"] },
		{ num: 29, ref: "..", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/"] },
		{ num: 30, ref: "../", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/"] },
		{ num: 31, ref: "../g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/g"] },
		{ num: 32, ref: "../..", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/"] },
		{ num: 33, ref: "../../", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/"] },
		{ num: 34, ref: "../../g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/g"] },
		{ num: 35, ref: "../../../g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/../g", "/web/20150519075506/http://a/g"] },
		{ num: 36, ref: "../../../../g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/../../g", "/web/20150519075506/http://a/g"] },
		{ num: 37, ref: "/./g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/g"] },
		{ num: 38, ref: "/../g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/g"] },
		{ num: 39, ref: "g.", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g."] },
		{ num: 40, ref: ".g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/.g"] },
		{ num: 41, ref: "g..", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g.."] },
		{ num: 42, ref: "..g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/..g"] },
		{ num: 43, ref: "./../g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/g"] },
		{ num: 44, ref: "./g/.", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g/"] },
		{ num: 45, ref: "g/./h", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g/h"] },
		{ num: 46, ref: "g/../h", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/h"] },
		{ num: 47, ref: "g;x=1/./y", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g;x=1/y"] },
		{ num: 48, ref: "g;x=1/../y", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/y"] },
		{ num: 49, ref: "g?y/./x", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g?y/./x"] },
		{ num: 50, ref: "g?y/../x", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g?y/../x"] },
		{ num: 51, ref: "g#s/./x", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g#s/./x"] },
		{ num: 52, ref: "g#s/../x", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/b/c/g#s/../x"] },
		{ num: 53, ref: "http:g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["http:g", "/web/20150519075506/http://a/b/c/g"] },
		{ num: 54, ref: "http:", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["http:", "/web/20150519075506/http://a/b/c/d;p?q"] },
		{ num: 55, ref: "/a/b/c/./../../g", base: "/web/20150519075506/http://a/b/c/d;p?q", expected: ["/web/20150519075506/http://a/a/g"] },
		{ num: 56, ref: "g", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g"] },
		{ num: 57, ref: "./g", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g"] },
		{ num: 58, ref: "g/", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g/"] },
		{ num: 59, ref: "/g", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/g"] },
		{ num: 60, ref: "//g", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://g"] },
		{ num: 61, ref: "?y", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/d;p?y"] },
		{ num: 62, ref: "g?y", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g?y"] },
		{ num: 63, ref: "g?y/./x", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g?y/./x"] },
		{ num: 64, ref: "g?y/../x", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g?y/../x"] },
		{ num: 65, ref: "g#s", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g#s"] },
		{ num: 66, ref: "g#s/./x", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g#s/./x"] },
		{ num: 67, ref: "g#s/../x", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/g#s/../x"] },
		{ num: 68, ref: "./", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/c/"] },
		{ num: 69, ref: "../", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/"] },
		{ num: 70, ref: "../g", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/b/g"] },
		{ num: 71, ref: "../../", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/"] },
		{ num: 72, ref: "../../g", base: "/web/20150519075506/http://a/b/c/d;p?q=1/2", expected: ["/web/20150519075506/http://a/g"] },
		{ num: 73, ref: "g", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/g"] },
		{ num: 74, ref: "./g", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/g"] },
		{ num: 75, ref: "g/", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/g/"] },
		{ num: 76, ref: "g?y", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/g?y"] },
		{ num: 77, ref: ";x", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/;x"] },
		{ num: 78, ref: "g;x", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/g;x"] },
		{ num: 79, ref: "g;x=1/./y", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/g;x=1/y"] },
		{ num: 80, ref: "g;x=1/../y", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/y"] },
		{ num: 81, ref: "./", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/d;p=1/"] },
		{ num: 82, ref: "../", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/"] },
		{ num: 83, ref: "../g", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/c/g"] },
		{ num: 84, ref: "../../", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/"] },
		{ num: 85, ref: "../../g", base: "/web/20150519075506/http://a/b/c/d;p=1/2?q", expected: ["/web/20150519075506/http://a/b/g"] },
		{ num: 86, ref: "g:h", base: "fred:///s//a/b/c", expected: ["g:h"] },
		{ num: 87, ref: "g", base: "fred:///s//a/b/c", expected: ["fred:///s//a/b/g"] },
		{ num: 88, ref: "./g", base: "fred:///s//a/b/c", expected: ["fred:///s//a/b/g"] },
		{ num: 89, ref: "g/", base: "fred:///s//a/b/c", expected: ["fred:///s//a/b/g/"] },
		{ num: 90, ref: "/g", base: "fred:///s//a/b/c", expected: ["fred:///g"] },
		{ num: 91, ref: "//g", base: "fred:///s//a/b/c", expected: ["fred://g"] },
		{ num: 92, ref: "//g/x", base: "fred:///s//a/b/c", expected: ["fred://g/x"] },
		{ num: 93, ref: "///g", base: "fred:///s//a/b/c", expected: ["fred:///g"] },
		{ num: 94, ref: "./", base: "fred:///s//a/b/c", expected: ["fred:///s//a/b/"] },
		{ num: 95, ref: "../", base: "fred:///s//a/b/c", expected: ["fred:///s//a/"] },
		{ num: 96, ref: "../g", base: "fred:///s//a/b/c", expected: ["fred:///s//a/g"] },
		{ num: 97, ref: "../../", base: "fred:///s//a/b/c", expected: ["fred:///s//"] },
		{ num: 98, ref: "../../g", base: "fred:///s//a/b/c", expected: ["fred:///s//g"] },
		{ num: 99, ref: "../../../g", base: "fred:///s//a/b/c", expected: ["fred:///s/g"] },
		{ num: 100, ref: "../../../../g", base: "fred:///s//a/b/c", expected: ["fred:///g"] },
		{ num: 101, ref: "g:h", base: "http:///s//a/b/c", expected: ["g:h"] },
		{ num: 102, ref: "g", base: "http:///s//a/b/c", expected: ["http:///s//a/b/g"] },
		{ num: 103, ref: "./g", base: "http:///s//a/b/c", expected: ["http:///s//a/b/g"] },
		{ num: 104, ref: "g/", base: "http:///s//a/b/c", expected: ["http:///s//a/b/g/"] },
		{ num: 105, ref: "/g", base: "http:///s//a/b/c", expected: ["http:///g"] },
		{ num: 106, ref: "//g", base: "http:///s//a/b/c", expected: ["/web/20150519075506/http://g"] },
		{ num: 107, ref: "//g/x", base: "http:///s//a/b/c", expected: ["/web/20150519075506/http://g/x"] },
		{ num: 108, ref: "///g", base: "http:///s//a/b/c", expected: ["http:///g"] },
		{ num: 109, ref: "./", base: "http:///s//a/b/c", expected: ["http:///s//a/b/"] },
		{ num: 110, ref: "../", base: "http:///s//a/b/c", expected: ["http:///s//a/"] },
		{ num: 111, ref: "../g", base: "http:///s//a/b/c", expected: ["http:///s//a/g"] },
		{ num: 112, ref: "../../", base: "http:///s//a/b/c", expected: ["http:///s//"] },
		{ num: 113, ref: "../../g", base: "http:///s//a/b/c", expected: ["http:///s//g"] },
		{ num: 114, ref: "../../../g", base: "http:///s//a/b/c", expected: ["http:///s/g"] },
		{ num: 115, ref: "../../../../g", base: "http:///s//a/b/c", expected: ["http:///g"] },
		{ num: 116, ref: "bar:abc", base: "foo:xyz", expected: ["bar:abc"] },
		{ num: 117, ref: "../abc", base: "/web/20150519075506/http://example/x/y/z", expected: ["/web/20150519075506/http://example/x/abc"] },
		{ num: 118, ref: "/web/20150519075506/http://example/x/abc", base: "/web/20150519075506/http://example2/x/y/z", expected: ["/web/20150519075506/http://example/x/abc"] },
		{ num: 119, ref: "../r", base: "/web/20150519075506/http://ex/x/y/z", expected: ["/web/20150519075506/http://ex/x/r"] },
		{ num: 120, ref: "q/r", base: "/web/20150519075506/http://ex/x/y", expected: ["/web/20150519075506/http://ex/x/q/r"] },
		{ num: 121, ref: "q/r#s", base: "/web/20150519075506/http://ex/x/y", expected: ["/web/20150519075506/http://ex/x/q/r#s"] },
		{ num: 122, ref: "q/r#s/t", base: "/web/20150519075506/http://ex/x/y", expected: ["/web/20150519075506/http://ex/x/q/r#s/t"] },
		{ num: 123, ref: "ftp://ex/x/q/r", base: "/web/20150519075506/http://ex/x/y", expected: ["ftp://ex/x/q/r"] },
		{ num: 124, ref: "", base: "/web/20150519075506/http://ex/x/y", expected: ["/web/20150519075506/http://ex/x/y"] },
		{ num: 125, ref: "", base: "/web/20150519075506/http://ex/x/y/", expected: ["/web/20150519075506/http://ex/x/y/"] },
		{ num: 126, ref: "", base: "/web/20150519075506/http://ex/x/y/pdq", expected: ["/web/20150519075506/http://ex/x/y/pdq"] },
		{ num: 127, ref: "z/", base: "/web/20150519075506/http://ex/x/y/", expected: ["/web/20150519075506/http://ex/x/y/z/"] },
		{ num: 128, ref: "#Animal", base: "file:/swap/test/animal.rdf", expected: ["file:/swap/test/animal.rdf#Animal"] },
		{ num: 129, ref: "../abc", base: "file:/e/x/y/z", expected: ["file:/e/x/abc"] },
		{ num: 130, ref: "/example/x/abc", base: "file:/example2/x/y/z", expected: ["file:/example/x/abc"] },
		{ num: 131, ref: "../r", base: "file:/ex/x/y/z", expected: ["file:/ex/x/r"] },
		{ num: 132, ref: "/r", base: "file:/ex/x/y/z", expected: ["file:/r"] },
		{ num: 133, ref: "q/r", base: "file:/ex/x/y", expected: ["file:/ex/x/q/r"] },
		{ num: 134, ref: "q/r#s", base: "file:/ex/x/y", expected: ["file:/ex/x/q/r#s"] },
		{ num: 135, ref: "q/r#", base: "file:/ex/x/y", expected: ["file:/ex/x/q/r#"] },
		{ num: 136, ref: "q/r#s/t", base: "file:/ex/x/y", expected: ["file:/ex/x/q/r#s/t"] },
		{ num: 137, ref: "ftp://ex/x/q/r", base: "file:/ex/x/y", expected: ["ftp://ex/x/q/r"] },
		{ num: 138, ref: "", base: "file:/ex/x/y", expected: ["file:/ex/x/y"] },
		{ num: 139, ref: "", base: "file:/ex/x/y/", expected: ["file:/ex/x/y/"] },
		{ num: 140, ref: "", base: "file:/ex/x/y/pdq", expected: ["file:/ex/x/y/pdq"] },
		{ num: 141, ref: "z/", base: "file:/ex/x/y/", expected: ["file:/ex/x/y/z/"] },
		{ num: 142, ref: "file://meetings.example.com/cal#m1", base: "file:/devel/WWW/2000/10/swap/test/reluri-1.n3", expected: ["file://meetings.example.com/cal#m1"] },
		{ num: 143, ref: "file://meetings.example.com/cal#m1", base: "file:/home/connolly/w3ccvs/WWW/2000/10/swap/test/reluri-1.n3", expected: ["file://meetings.example.com/cal#m1"] },
		{ num: 144, ref: "./#blort", base: "file:/some/dir/foo", expected: ["file:/some/dir/#blort"] },
		{ num: 145, ref: "./#", base: "file:/some/dir/foo", expected: ["file:/some/dir/#"] },
		{ num: 146, ref: "./", base: "/web/20150519075506/http://example/x/abc.efg", expected: ["/web/20150519075506/http://example/x/"] },
		{ num: 147, ref: "//example/x/abc", base: "/web/20150519075506/http://example2/x/y/z", expected: ["/web/20150519075506/http://example/x/abc"] },
		{ num: 148, ref: "/r", base: "/web/20150519075506/http://ex/x/y/z", expected: ["/web/20150519075506/http://ex/r"] },
		{ num: 149, ref: "./q:r", base: "/web/20150519075506/http://ex/x/y", expected: ["/web/20150519075506/http://ex/x/q:r"] },
		{ num: 150, ref: "./p=q:r", base: "/web/20150519075506/http://ex/x/y", expected: ["/web/20150519075506/http://ex/x/p=q:r"] },
		{ num: 151, ref: "?pp/rr", base: "/web/20150519075506/http://ex/x/y?pp/qq", expected: ["/web/20150519075506/http://ex/x/y?pp/rr"] },
		{ num: 152, ref: "y/z", base: "/web/20150519075506/http://ex/x/y?pp/qq", expected: ["/web/20150519075506/http://ex/x/y/z"] },
		{ num: 153, ref: "local/qual@domain.org#frag", base: "mailto:local", expected: ["mailto:local/qual@domain.org#frag"] },
		{ num: 154, ref: "more/qual2@domain2.org#frag", base: "mailto:local/qual1@domain1.org", expected: ["mailto:local/more/qual2@domain2.org#frag"] },
		{ num: 155, ref: "y?q", base: "/web/20150519075506/http://ex/x/y?q", expected: ["/web/20150519075506/http://ex/x/y?q"] },
		{ num: 156, ref: "/x/y?q", base: "/web/20150519075506/http://ex?p", expected: ["/web/20150519075506/http://ex/x/y?q"] },
		{ num: 157, ref: "c/d", base: "foo:a/b", expected: ["foo:a/c/d"] },
		{ num: 158, ref: "/c/d", base: "foo:a/b", expected: ["foo:/c/d"] },
		{ num: 159, ref: "", base: "foo:a/b?c#d", expected: ["foo:a/b?c"] },
		{ num: 160, ref: "b/c", base: "foo:a", expected: ["foo:b/c"] },
		{ num: 161, ref: "../b/c", base: "foo:/a/y/z", expected: ["foo:/a/b/c"] },
		{ num: 162, ref: "./b/c", base: "foo:a", expected: ["foo:b/c"] },
		{ num: 163, ref: "/./b/c", base: "foo:a", expected: ["foo:/b/c"] },
		{ num: 164, ref: "../../d", base: "foo://a//b/c", expected: ["foo://a/d"] },
		{ num: 165, ref: ".", base: "foo:a", expected: ["foo:"] },
		{ num: 166, ref: "..", base: "foo:a", expected: ["foo:"] },
		{ num: 167, ref: "abc", base: "/web/20150519075506/http://example/x/y%2Fz", expected: ["/web/20150519075506/http://example/x/abc"] },
		{ num: 168, ref: "../../x%2Fabc", base: "/web/20150519075506/http://example/a/x/y/z", expected: ["/web/20150519075506/http://example/a/x%2Fabc"] },
		{ num: 169, ref: "../x%2Fabc", base: "/web/20150519075506/http://example/a/x/y%2Fz", expected: ["/web/20150519075506/http://example/a/x%2Fabc"] },
		{ num: 170, ref: "abc", base: "/web/20150519075506/http://example/x%2Fy/z", expected: ["/web/20150519075506/http://example/x%2Fy/abc"] },
		{ num: 171, ref: "q%3Ar", base: "/web/20150519075506/http://ex/x/y", expected: ["/web/20150519075506/http://ex/x/q%3Ar"] },
		{ num: 172, ref: "/x%2Fabc", base: "/web/20150519075506/http://example/x/y%2Fz", expected: ["/web/20150519075506/http://example/x%2Fabc"] },
		{ num: 173, ref: "/x%2Fabc", base: "/web/20150519075506/http://example/x/y/z", expected: ["/web/20150519075506/http://example/x%2Fabc"] },
		{ num: 174, ref: "local2@domain2", base: "mailto:local1@domain1?query1", expected: ["mailto:local2@domain2"] },
		{ num: 175, ref: "local2@domain2?query2", base: "mailto:local1@domain1", expected: ["mailto:local2@domain2?query2"] },
		{ num: 176, ref: "local2@domain2?query2", base: "mailto:local1@domain1?query1", expected: ["mailto:local2@domain2?query2"] },
		{ num: 177, ref: "?query2", base: "mailto:local@domain?query1", expected: ["mailto:local@domain?query2"] },
		{ num: 178, ref: "local@domain?query2", base: "mailto:?query1", expected: ["mailto:local@domain?query2"] },
		{ num: 179, ref: "?query2", base: "mailto:local@domain?query1", expected: ["mailto:local@domain?query2"] },
		{ num: 180, ref: "/web/20150519075506/http://example/a/b?c/../d", base: "foo:bar", expected: ["/web/20150519075506/http://example/a/b?c/../d"] },
		{ num: 181, ref: "/web/20150519075506/http://example/a/b#c/../d", base: "foo:bar", expected: ["/web/20150519075506/http://example/a/b#c/../d"] },
		{ num: 182, ref: "http:this", base: "/web/20150519075506/http://example.org/base/uri", expected: ["http:this"] },
		{ num: 183, ref: "http:this", base: "http:base", expected: ["http:this"] },
		{ num: 184, ref: ".//g", base: "f:/a", expected: ["f://g"] },
		{ num: 185, ref: "b/c//d/e", base: "f://example.org/base/a", expected: ["f://example.org/base/b/c//d/e"] },
		{ num: 186, ref: "m2@example.ord/c2@example.org", base: "mid:m@example.ord/c@example.org", expected: ["mid:m@example.ord/m2@example.ord/c2@example.org"] },
		{ num: 187, ref: "mini1.xml", base: "file:///C:/DEV/Haskell/lib/HXmlToolbox-3.01/examples/", expected: ["file:///C:/DEV/Haskell/lib/HXmlToolbox-3.01/examples/mini1.xml"] },
		{ num: 188, ref: "../b/c", base: "foo:a/y/z", expected: ["foo:a/b/c"] },
		{ num: 189, ref: "b", base: "foo:", expected: ["foo:b"] },
		{ num: 190, ref: "b", base: "foo://a", expected: ["foo://a/b"] },
		{ num: 191, ref: "b", base: "foo://a?q", expected: ["foo://a/b"] },
		{ num: 192, ref: "b?q", base: "foo://a", expected: ["foo://a/b?q"] },
		{ num: 193, ref: "b?q", base: "foo://a?r", expected: ["foo://a/b?q"] },
	];
}
