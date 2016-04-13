hxUri
-----

Uri datatype with resolve functionality. Based on js-uri.

This is a small library for manipulating URIs. It parses,
recreates and resolves them. For example:

```haxe  
  var someUri = new Uri("http://www.example.com/foo/bar");

  trace(someUri.getAuthority()); // www.example.com
  trace(someUri);                // http://www.example.com/foo/bar

  var blah = new Uri("blah");
  var blahFull = blah.resolve(someUri);
  trace(blahFull);              // http://www.example.com/foo/blah

  var wiki = "https://www.wikipedia.org/";

  var query = new UriQuery()
    .addParam("q", "moon landing site:" + wiki);

  var searchGoogle = new Uri("https://google.com/path")
    .setPath("search")
    .setQuery(query.toString());

  trace(query.getParam("q"));    // moon landing site:https://www.wikipedia.org/
  trace(searchGoogle);           // https://google.com/search?q=moon+landing+site%3Ahttps%3A%2F%2Fwww.wikipedia.org%2F
```

Tests are taken from [js-uri](https://code.google.com/archive/p/js-uri/) and [skew.org](http://web.archive.org/web/20150518202232/https://skew.org/uri/uri_tests.html) (see the [test](test/) folder).

This library is BSD-licensed.  See LICENSE.txt for details.