#!./perl -w
# SPDX-License-Identifier: Artistic-1.0-Perl OR GPL-1.0-or-later
# Guard C library probes embedded in the generated Configure script.
# No external libraries, compiler or additional Perl modules are required.

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
}
use strict;
use warnings;
require './test.pl';

plan(5);

open my $fh, '<', '../Configure' or die "Cannot read ../Configure: $!";
my $configure = do { local $/; <$fh> };
close $fh or die "Cannot close ../Configure: $!";

ok($configure =~ /main_buffer == NULL \|\| strlen\(main_buffer\)/,
   'getenv(PATH) is checked before strlen');

ok($configure =~ /name_len >= sizeof\(alternate\)/,
   'oversized locale names are rejected before copying');

ok($configure =~ /memcpy\(alternate, locale_name, name_len \+ 1\)/,
   'bounded locale copy includes the trailing NUL');

ok($configure !~ /strncpy\(alternate, locale_name, sizeof\(alternate\)\)/,
   'unbounded-termination strncpy probe is not reintroduced');

ok($configure !~ /strlcpy\(alternate, locale_name/,
   'probe retains ISO C89 libc dependencies, not BSD-only strlcpy');
