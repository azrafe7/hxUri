hxUri
-----

Uri datatype with resolve functionality. Based on js-uri.

([original readme](ORIGINAL_README.txt))


This is a small library for manipulating URIs. It parses,
recreates and resolves them. For example:

```haxe  
  var some_uri = new Uri("http://www.example.com/foo/bar");

  trace(some_uri.authority); // www.example.com
  trace(some_uri);           // http://www.example.com/foo/bar

  var blah      = new Uri("blah");
  var blah_full = blah.resolve(some_uri);
  trace(blah_full);          // http://www.example.com/foo/blah
```

See the [test](test/) folder for other examples (split into scheme, path, query, etc.).

This library is BSD-licenced.  See LICENSE.txt for details.