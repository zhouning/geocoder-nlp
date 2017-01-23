# geocoder-nlp

This is a geocoder C++ library that uses libpostal to parse the user
request, normalize the parsed result, and search for the match in
geocoder database. 

The library includes demo program showing how to use it. Its also used
as one of the geocoders in OSM Scout Server
(https://github.com/rinigus/osmscout-server). For preparation of the
SQLite database used by the geocoder, an importer from liboscmscout
map database is provided.

When using country-based libpostal address parser and limiting number
of languages used to process the search request, it is possible to use
this geocoder on mobile platforms. The development of the geocoder is
mainly targeting Sailfish OS applications with the tests running on
Linux as well. Its expected that the geocoder would run on platforms
supported by libpostal without any major changes.

To compile, adjust Makefile. The library can be used by incorporating
source code files in `src` subdirectory and ensuring that
`thirdparty/sqlite3pp/headeronly_src` is in the compiler's include
path.

In addition to libpostal, libsqlite3 is required for the geocoder to
function. For importer, libosmscout is required in addition to the
libraries mentioned above.


## Acknowledgments

libpostal: https://github.com/openvenues/libpostal

libosmscout: http://libosmscout.sourceforge.net
