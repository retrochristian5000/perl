#!./perl -w
# SPDX-License-Identifier: Artistic-1.0-Perl OR GPL-1.0-or-later
# Detect shell conditional and argument-loop regressions in Perl configuration.

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
}
use strict;
use warnings;
require './test.pl';

plan(11);

open my $fh, '<', '../configure.gnu' or die "Cannot read configure.gnu: $!";
my $gnu = do { local $/; <$fh> };
close $fh or die "Cannot close configure.gnu: $!";

open $fh, '<', '../Configure' or die "Cannot read Configure: $!";
my $configure = do { local $/; <$fh> };
close $fh or die "Cannot close Configure: $!";

ok($gnu =~ /remaining=\$\#\s+while test "\$remaining" -gt 0; do/,
   'GNU option while-loop terminates after original arguments');
ok($gnu =~ /--prefix\)\s+if test "\$remaining" -eq 0; then/s,
   'bare --prefix rejects a missing value');
ok($gnu =~ /--cache-file\)\s+if test "\$remaining" -eq 0; then/s,
   'bare --cache-file rejects a missing value');
ok($gnu =~ /set -- "\$@" "-Dprefix=\$prefix"/,
   'prefix assignment stays a single shell argument');
ok($gnu !~ /\beval\s+"set\s/,
   'GNU Configure frontend never re-evaluates user-supplied arguments');
ok($configure =~ /mkdir UU \|\| \{\s+printf .*?exit 1/s,
   'Configure aborts when it cannot create UU');
ok($configure =~ /cd UU \|\| \{\s+printf .*?exit 1/s,
   'Configure aborts when it cannot enter UU');
ok($configure =~ m{rm -f \./\* \|\| \{\s+printf .*?exit 1}s,
   'Configure aborts when UU cannot be cleaned');
ok($configure =~ /for file in \$loclist \$trylist; do\s+\#.*?if \$grep "\^\$file=" UU\/optdef\.sh .*?continue/s,
   'portable-mode for-loop preserves explicitly selected tools');
ok(system('/bin/sh', '-n', '../Configure') == 0,
   'generated Configure preserves POSIX shell syntax');
ok(system('/bin/sh', '-n', '../configure.gnu') == 0,
   'GNU Configure frontend preserves POSIX shell syntax');
