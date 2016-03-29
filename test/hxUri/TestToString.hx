/* Tests from toString.t.html */

package hxUri;

import hxUri.Uri;
import utest.Assert;


class TestToString {
	
	public function new() { }
	
    public function testToString() {
		var uri = new Uri("http://www.example.com/foo/bar?page=1#baz");
		Assert.equals("http://www.example.com/foo/bar?page=1#baz", uri.toString());
		uri = new Uri("?page");
		Assert.equals("?page", uri.toString());
		uri = new Uri("");
		Assert.equals("", uri.toString());
    }
	
	public function testClone() {
		var u = new Uri("?foo");
		var clone = u.clone();
		Assert.equals(u.toString(), clone.toString());
		Assert.notEquals(u, clone);
		u = new Uri("http://www.example.com/foo/bar?page=1#baz");
		clone = u.clone();
		Assert.equals(u.toString(), clone.toString());
		Assert.notEquals(u, clone);
	}
}
