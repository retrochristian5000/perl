#!./perl -w
# SPDX-License-Identifier: Artistic-1.0-Perl OR GPL-1.0-or-later
# Scope legacy Darwin Configure hints to the OS generations that need them.

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
}
use strict;
use warnings;
require './test.pl';

plan(6);

open my $fh, '<', '../hints/darwin.sh'
    or die "Cannot read ../hints/darwin.sh: $!";
my $hints = do { local $/; <$fh> };
close $fh or die "Cannot close Darwin hints: $!";

ok($hints =~ /case "\$osvers" in\s*1\.\*\)\s*if test -f \/usr\/include\/stdint\.h/s,
   'pre-SDK stdint workaround is Darwin 1.x only');

ok($hints =~ /case "\$osvers" in\s*\[1-8\]\.\*\)\s*if \[ "X/s,
   'obsolete no-cpp-precomp probe is gated to Darwin 1-8');

ok($hints =~ /8\.\*\)\s*dlsrc='dl_dlopen\.xs';\s*d_poll='undef';\s*i_poll='undef'/s,
   'broken poll workaround is retained for Darwin 8');

ok($hints =~ /8\.\*\).*?i_poll='undef';\s*;;\s*\*\)\s*dlsrc='dl_dlopen\.xs';\s*;;\s*esac/s,
   'modern Darwin no longer forcibly disables poll detection');

ok($hints =~ /case "\$ranlib" in\s*''\) ranlib='ranlib' ;;\s*esac/s,
   'explicit native ranlib selection is not overwritten');

ok(system('/bin/sh', '-n', '../hints/darwin.sh') == 0,
   'Darwin hints preserve POSIX shell syntax');
