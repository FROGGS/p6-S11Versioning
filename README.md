# What this is:

This is an attempt to support http://perlcabal.org/syn/S11.html where you can install, locate and
load Perl6 modules. The interesting part is, that one should be able to install and use several versions
of the "same" module, or install and use it from different authors/authorities.

For this to happen I decided to wrap the current ModuleLoader, and delegate to it for the library
paths that are currently known to the compiler.
The Idea is that once panda knows about other module loaders (or rather their installation handlers),
it would use them to install and register modules, which would then be picked up, if the constraints
of the use-statement allow that.

That follows that the currently known library search paths are treated like for developement purposes:
A module from these paths is picked up if a file of that module name (split by '::', plus '.pm' extension) is found.

# Current state:

Currently our module database is designed as a MANIFEST file (or several of them), that contain information
about an installed module, example:

```json
[
    {
        "id" : "1",
        "name" : "Foo::Bar",
        "ver" : "1.0.1",
        "description" : "The most useful module evar!!",
        "auth" : "Kevin Flynn <kevin@EN.COM>",
        "modules" : {
            "Foo::Bar" : "Foo/Bar-1.pm",
            "Foo::Bar::Constants" : "Foo/Bar/Constants.pm"
        },
        "files" : [
            "Foo/Bar-1.pod"
        ]
    }
]
```

The following code just works with a current racudo:

```perl
use CompUnitRepo;

use Foo::Bar;
use Foo::Bar:ver<1.0.1>;
use Foo::Bar:ver(v0.9.7..*);
use Foo::Bar:auth({ .substr(*-6) eq 'EN.COM' });
use Foo::Bar:auth(/Flynn/);
...
```

# installing distributions:

```
user@host:~$ panda install Foo::Bar
Searching for 'Foo::Bar'...
Found:
  Foo::Bar  v1.0.4  by Kevin Flynn  GPL2  SHA1 da39a3ee-5e6b4b0d-3255bfef-95601890-afd80709
Missing dependencies detected:
  XML::Awesome  v0.97  by XML Inc.  Artistic  SHA1 2fd4e1c6-7a2d28fc-ed849ee1-bb76e739-1b93eb12
0 to update, 2 to be installed, 0 to remove and 0 not to update.
We need to download 4.802 kiB.
After this operation 8.192 B diskspace will be used additionally.
Do you wanna do this [Y/n]?
Installing #1 /usr/lib/perl6/rakudo-1.0/Foo/Bar.pm
Installing #1 /usr/lib/perl6/rakudo-1.0/Foo/Bar.pod
Installing #1 /usr/lib/perl6/rakudo-1.0/Foo/Bar/Constans.pm
Updating /usr/lib/perl6/rakudo-1.0/MANIFEST
`----> 1    Foo::Bar      1.0.4  Kevin Flynn <kevin@EN.COM>                     da39a3ee-5e6b4b0d-3255bfef-95601890-afd80709 # signatur of the distribution
  |--> 1.1  Foo::Bar             /usr/lib/perl6/rakudo-1.0/Foo/Bar.pm           sdkjfhsd-sdfsdfw4-f4zezd65-ed6ze56z-de6zz6zd # checksum of the file
  |--> 1.2  Foo::Bar             /usr/lib/perl6/rakudo-1.0/Foo/Bar.pod          ajkhefkz-ugkuztzu-fgsdjg4l-a8fjbba3-6ia2glof
  `--> 1.3  Foo::Bar::Constants  /usr/lib/perl6/rakudo-1.0/Foo/Bar/Constans.pm  khdlfkhg-lskjdhfg-lshdflkg-jhsdkhgr-uhgdksu4
Installing #2 /usr/lib/perl6/rakudo-1.0/XML/Awesome.pm
Installing #2 /usr/lib/perl6/rakudo-1.0/XML/Awesome.pod
Installing #2 /usr/lib/perl6/rakudo-1.0/bin/xml2json.pl
`----> 2    XML::Awesome  0.97   XML Inc. https/github.com/XMLInc               2fd4e1c6-7a2d28fc-ed849ee1-bb76e739-1b93eb12
  |--> 2.1  XML::Awesome         /usr/lib/perl6/rakudo-1.0/XML/Awesome.pm       oiajcpm4-ruawmp04-8zrx78we-6z4xr874-ewtrxit7
  |--> 2.2  XML::Awesome         /usr/lib/perl6/rakudo-1.0/XML/Awesome.pod      iuhwroiz-3pw89rza-oih3oez7-8wt3eiug-w3ro87ot
  `--> 2.3  XML::Awesome         /usr/lib/perl6/rakudo-1.0/bin/xml2json.pl      sdkjfhsd-sdfsdfw4-f4zezd65-ed6ze56z-de6zz6zd
Done.
```

```
user@host:~$ panda install -dev Foo::Bar
Found:
  Foo::Bar  v1.0.5-dev  by Kevin Flynn  GPL2  SHA1 2fd4e1c6-7a2d28fc-ed849ee1-bb76e739-1b93eb12
1 to update, 0 to be installed, 0 to remove and 0 not to update.
We need to download 1.534 kiB.
After this operation 752 B diskspace will be used additionally.
Do you wanna do this [Y/n]?
Installing #3 /usr/lib/perl6/rakudo-1.0/Foo/Bar-3.pm
Installing #3 /usr/lib/perl6/rakudo-1.0/Foo/Bar-3.pod
Skipping   #3 /usr/lib/perl6/rakudo-1.0/Foo/Bar/Constans.pm
Updating /usr/lib/perl6/rakudo-1.0/MANIFEST
`----> 3    Foo::Bar      1.0.5-dev  Kevin Flynn <kevin@EN.COM>    2fd4e1c6-7a2d28fc-ed849ee1-bb76e739-1b93eb12
  |--> 3.1  /usr/lib/perl6/rakudo-1.0/Foo/Bar-3.pm                 q7z8d746-98hd6h96-d02d3640-hd26349h-8734h69d
  |--> 3.2  /usr/lib/perl6/rakudo-1.0/Foo/Bar-3.pod                81072273-j7ih2k4z-uztztu34-2zifihg3-5434ztfz
  `--> 3.3  /usr/lib/perl6/rakudo-1.0/Foo/Bar/Constans.pm          khdlfkhg-lskjdhfg-lshdflkg-jhsdkhgr-uhgdksu4 # this one is already there, no duplicates!
Done.
```

# Note
After that the Foo::Bar-1.0.4 is still the default one that will be used if you just do: `use Foo::Bar;`.

I believe there is no proper way to mark a specific (lower) version as the default. Since when you do that
in your home directory, there still might be a higher version in site, vendor or perl that will be picked up.

# searching for distributions:
`use Foo::Bar<v1.0.5>` ==> lookup Foo/Bar.pm in INC, reading MANIFESTS from: home, site, vendor and perl.
The @*INC should be empty by default, but if there is the `PERL6LIB` environment variable then its
directories (separated by colons) are used. One can prepend directories to `@*INC` by adding
`use lib 'PATH';` to his code.

When searching for a module (or class or role) then we check first if there is a matching file in
`@*INC`. If there is one, then this is our only candidate, even if it maybe have a lower version then
we are searching for (or a wrong auth). This feature is ment for module developement, so that you
don't have to install your just-written module to be able to test it.

If there was no matching file in `@*INC`, we are grabbing the MANIFEST files from home, site, vendor
and perl. The module with the highest version that matches the given auth+version of the "use"-statements wins.
BTW, the home, site, vendor and perl directories are already accessable via `%*CUSTOM_LIB`.

The good thing with the method above is that you really don't have to bother if you can sudo or not
when installing modules. If you can, stuff will be installed to site. If not, it will end up in your
home. But in the end, the "best" module will win, wether it is in your home or site or whereever.

# Notes:
1) Since we use the module-, class- or rolename as filename, and names in Perl are UTF-8 (Unicode)
and we must care of ASCII-filesystems there will be a translation step. If it is easy to for panda
to get the capabilities of the filesystem it can decide that it only tries to translate the names
if the filesystem does not support Unicode.

Example: A class called 北亰 will end up as BeiJing.pm on non-Unicode-able filesystems. For this
feature we need a mapping table like Perl 5's unicore/Name.pl.

If we don't have such a mapping table or a character can not be translated, it will be presented as
its Unicode codepoint. 北亰 = x5317x4EB0.pm

2) The author field should be made mandatory: https://github.com/perl6/ecosystem/blob/master/spec.pod

3) The filename structure within the downloadable distribution has to agree with the namespaces the dist provides.
For example, if the dist provides a class called Foo::北亰, there must be the file "lib/Foo/北亰.pm" or "lib/Foo/北亰.pm6".
If the dist author will provide Unicode classnames but has no Unicode-able filesystem, he has to extend the META.info in the following way:
```
{
    "name" : "Foo::北亰",
    [...]
    "provides": {
        "Foo::北亰" : "lib/Foo/BejJing.pm"
    }
}
```
