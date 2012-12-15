
use v6;
use Test;

shell('mkdir deps') unless 'deps'.IO ~~ :d;

shell('git clone git://github.com/moritz/json.git deps/JSON-Tiny') unless 'deps/JSON-Tiny'.IO ~~ :d;

ok 'deps/JSON-Tiny/.git/'.IO ~~ :d, 'got JSON-Tiny in deps/';

done();
