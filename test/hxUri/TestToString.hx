/* Tests from toString.t.html */

package hxUri;

import hxUri.Uri;
import utest.Assert;


class TestToString {
	
	public function new() { }
	
    public function testToString() {
		var uri = new Uri("http://www.example.com/foo/bar?page=1#baz");
		Assert.equals("http://www.example.com/foo/bar?page=1#baz", uri.toString());
    }
}
