/* Tests from parse.t.html */

package hxUri;

import hxUri.Uri;
import utest.Assert;


class TestParse {
	
	public function new() { }
	
    public function testParse() {
		// Test that we pull apart components correctly.
		uri_ok("http://www.example.com/foo/bar?page=1#baz",
				   "http", "www.example.com", "/foo/bar", "page=1", "baz");
		uri_ok("?page=1", "", "", "", "page=1");
		uri_ok("#foo", "", "", "", "", "foo");
		uri_ok("//example.com/foo/bar", "", "example.com", "/foo/bar");
		uri_ok("http:", "http");
		uri_ok("");
    }

	// An additional test helper.
    function uri_ok(str:String, scheme:String = "", authority:String = "", path:String = "", query:String = "", fragment:String = "") {
		var u = new Uri(str);
		Assert.equals(scheme,    u.getScheme(),    'Scheme of "$str": expected "$scheme" but it is "${u.getScheme()}"');
		Assert.equals(authority, u.getAuthority(), 'Authority of "$str": expected "$authority" but it is "${u.getAuthority()}"');
		Assert.equals(path,      u.getPath(),      'Path of "$str": expected "$path" but it is "${u.getPath()}"');
		Assert.equals(query,     u.getQuery(),     'Query of "$str": expected "$query" but it is "${u.getQuery()}"');
		Assert.equals(fragment,  u.getFragment(),  'Fragment of "$str": expected "$fragment" but it is "${u.getFragment()}"');
    }
}
