
use v6;
use Test;

plan 2;

shell('mkdir deps') unless 'deps'.IO ~~ :d;

shell('git clone git://github.com/moritz/json.git deps/JSON-Tiny') unless 'deps/JSON-Tiny'.IO ~~ :d;
shell('git clone git://github.com/perl6/DBIish.git deps/DBIish')   unless 'deps/DBIish'.IO    ~~ :d;

ok 'deps/JSON-Tiny/.git/'.IO ~~ :d, 'got JSON-Tiny in deps/';
ok 'deps/DBIish/.git/'.IO    ~~ :d, 'got DBIish in deps/';

done();
