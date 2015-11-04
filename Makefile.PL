use strict;
use warnings;

use ExtUtils::MakeMaker;

my $readme = 'podselect lib/WebService/Aria2/RPC/JSON.pod > README.pod';

WriteMakefile 
(

  NAME          => "WebService::Aria2::RPC::JSON",
  AUTHOR        => "Danny Warren <danny\@dannywarren.com>",
  LICENSE       => "perl",
  VERSION_FROM  => "lib/WebService/Aria2/RPC/JSON.pm",
  ABSTRACT_FROM => "lib/WebService/Aria2/RPC/JSON.pod",

  PREREQ_PM =>
  {
    'WebService::Aria2::RPC' => "0.01",
    'JSON::RPC::Common'      => "0.11",
    'Moose'                  => "2.1603",
    'URI'                    => "1.67",
    'LWP'                    => '6.13',
  },

  TEST_REQUIRES => 
  {
    'Test::More' => "0.98",
  },

  META_MERGE =>
  {
    resources => 
    {
      homepage   => "https://github.com/dannywarren/WebService-Aria2-RPC-JSON",
      repository => "https://github.com/dannywarren/WebService-Aria2-RPC-JSON",
    },
  },

  dist => 
  {
    PREOP => $readme,
  },

);
