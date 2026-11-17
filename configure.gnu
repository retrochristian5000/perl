#! /bin/sh
#
# GNU configure-like front end to metaconfig's Configure.
#
# Written by Andy Dougherty <doughera@lafayette.edu>
# and Matthew Green <mrg@mame.mu.oz.au>.
#
# Reformatted and modified for inclusion in the dist-3.0 package by
# Raphael Manfredi <ram@hptnos02.grenoble.hp.com>.
#
# This script belongs to the public domain and may be freely redistributed.
#
# The remaining of this leading shell comment may be removed if you
# include this script in your own package.
#
# $Log: configure,v $
# Revision 3.0.1.1  1995/07/25  14:16:21  ram
# patch56: created
#

(exit $?0) || exec sh $0 $argv:q

case "$0" in
*configure)
    if cmp "$0" "${0%configure}Configure" >/dev/null; then
	printf '%s\n' "Your configure and Configure scripts seem to be identical."
	printf '%s\n' "This can happen on filesystems that aren't fully case sensitive."
	printf '%s\n' "You'll have to explicitly extract Configure and run that."
	exit 1
    fi
    ;;
esac

# Keep the original argument count while appending translated options to
# "$@". This is POSIX sh and does not reinterpret user input through eval.
verbose=''
create='-e'
show_version=''
remaining=$#
while test "$remaining" -gt 0; do
    option=$1
    shift
    remaining=$((remaining - 1))
    case "$option" in
    --help)
        cat <<EOM
Usage: configure.gnu [options]
This is a GNU configure-like front end for a metaconfig-generated Configure.
It emulates the following GNU configure options (must be fully spelled out):
    --help
    --no-create
    --prefix=PREFIX
    --cache-file=FILE  (ignored)
    --quiet
    --silent
    --verbose
    --version

And it honours these environment variables: CC, CFLAGS, DEFS and LDFLAGS.
EOM
        exit 0
        ;;
    --no-create)
        create='-E'
        ;;
    --prefix=*|--prefix)
        case "$option" in
            --prefix=*) prefix=${option#--prefix=} ;;
            --prefix)
                if test "$remaining" -eq 0; then
                    printf '%s\n' 'configure.gnu: --prefix requires a value' >&2
                    exit 2
                fi
                prefix=$1
                shift
                remaining=$((remaining - 1))
                ;;
        esac
        case "$prefix" in
            ''|--*)
                printf '%s\n' 'configure.gnu: --prefix requires a nonempty value' >&2
                exit 2 ;;
        esac
        set -- "$@" "-Dprefix=$prefix"
        ;;
    --cache-file=*)
        : # Metaconfig does not have a corresponding cache option.
        ;;
    --cache-file)
        if test "$remaining" -eq 0; then
            printf '%s\n' 'configure.gnu: --cache-file requires a value' >&2
            exit 2
        fi
        case "$1" in
            ''|--*)
                printf '%s\n' 'configure.gnu: --cache-file requires a value' >&2
                exit 2 ;;
        esac
        shift
        remaining=$((remaining - 1))
        ;;
    --quiet|--silent)
        exec >/dev/null 2>&1
        ;;
    --verbose)
        verbose=true
        ;;
    --version)
        show_version=true
        ;;
    --*)
        printf 'configure.gnu: unsupported option: %s\n' "$option" >&2
        exit 1
        ;;
    *)
        set -- "$@" "$option"
        ;;
    esac
done

# Append native Configure assignments as *single arguments*, including values
# with spaces, quotes, semicolons, and shell substitutions.
if test -n "${CC:-}"; then
    set -- "$@" "-Dcc=$CC"
fi
ccflags=${DEFS:-}
if test -n "${CFLAGS:-}"; then
    ccflags="${ccflags:+$ccflags }$CFLAGS"
fi
if test -n "$ccflags"; then
    set -- "$@" "-Dccflags=$ccflags"
fi
if test -n "${LDFLAGS:-}"; then
    set -- "$@" "-Dldflags=$LDFLAGS"
fi

if test -n "$verbose"; then
    set -- -d "$create" "$@"
else
    set -- -ds "$create" "$@"
fi
if test -n "$show_version"; then
    set -- -V "$@"
fi
set -- sh Configure "$@"
printf '%s\n' "$*"
exec "$@"
