/* Tests from param.t.html */

package hxUri;

import hxUri.Uri;
import utest.Assert;


class TestParams {
	
    // an ampersand.  This is done this way to prevent any browser
    // weirdness with embedded javascript inside a html document
    static var sep:String = String.fromCharCode(38);

    ////////////////////// parsing query string /////////////////////////

    var query:String;
    var u:Uri;
	var q:UriQuery;
	var p:UriQueryParams;
	
	public function setup() {
		// build a url
		query = "foo=xyz" + sep + "bar=baz" + sep + "bar=buz" + sep + "capt=James+T+Kirk"; 
		u = new Uri("http://2shortplanks.com/wombat?" + query + "#aardvark");
		// get query
		q = u.parseQuery();
		p = q.params;
	}
	
	public function new() { }
	
    public function testParts() {
		// check all the normal stuff working
		Assert.equals("http",              u.getScheme());
		Assert.equals("2shortplanks.com",  u.getAuthority());
		Assert.equals("/wombat",           u.getPath());
		Assert.equals(query,               u.getQuery());
		Assert.equals("aardvark",          u.getFragment());
    }

    public function testParams() {
		// check the parameters
		Assert.equals("xyz",          p.get("foo")[0]);
		Assert.equals(1,              p.get("foo").length);
		Assert.equals("baz",          p.get("bar")[0]);
		Assert.equals("buz",          p.get("bar")[1]);
		Assert.equals("2",            p.get("bar").length);
		Assert.equals("James T Kirk", p.get("capt")[0]);
		Assert.equals(1,              p.get("capt").length);

		var c = 0;
		for (key in p.keys()) c++;
		
		Assert.equals(3, c);
    }

	public function testGetParams() {
		// getting parameters
		Assert.equals("xyz",          q.getParam("foo"));
		Assert.equals("baz",          q.getParam("bar"));
		Assert.equals("James T Kirk", q.getParam("capt"));
	}
	
	public function testBuildParams() {
		Assert.equals("foo=xyz&bar=baz&bar=buz&capt=James+T+Kirk", q.toString());
		q.separator = ";";
		Assert.equals("foo=xyz;bar=baz;bar=buz;capt=James+T+Kirk", q.toString());
		var newQuery = new UriQuery().addStringParams("one=1&two=2&three=3");
		u.setQuery(newQuery.toString());
		Assert.equals("one=1&two=2&three=3", u.getQuery());
	}
}
