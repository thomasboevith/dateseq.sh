#!/bin/bash
version="0.1"
function usage {
echo "dateseq.sh $version -- print a sequence of dates and times"
echo " "
echo "Usage: dateseq.sh [OPTION]... LAST"
echo "       dateseq.sh [OPTION]... FIRST LAST"
echo "       dateseq.sh [OPTION]... FIRST INCREMENT LAST"
echo " "
echo "Options:"
echo "    -f    OUTFORMAT [default: %Y%m%d%H%M]"
echo "    -i    INCREMENT <value><unit> (y, M, w, m, d, h, m, s) [default: 1d]"
echo "    -v    VERBOSE"
echo " "
echo "FIRST/LAST is a datetime with date in the format YYYYMMDD or YYYY-MM-DD"
echo "and time in the format HMS, HM, H:M, or H:M:S (if used)."
echo "Date and time must be separated by a whitespace."
echo "If FIRST is omitted, it defaults to todays date at midnight."
echo "If INCREMENT is omitted, it defaults to 1 day (1d). INCREMENT is always"
echo "positive even if FIRST is smaller than LAST."
echo "FORMAT is in the GNU date format and defaults to %Y%m%d%H%M."
echo "INCREMENT supports: 2y 4M 2w 1d 6h 15m 30s, for year, month, week, day,"
echo "hour, minute, or second."
echo " "
echo "Examples:"
echo "    ./dateseq.sh 20160916"
echo "    ./dateseq.sh 20160916 20161010"
echo "    ./dateseq.sh -f %Y-%m-%d\ %H:%M:%S 20160916\ 0730 30m 20160916\ 1230"
echo "    ./dateseq.sh -f %s 20160916\ 0730 2m 20160916\ 0830"
}

# Print usage if no arguments
if test "$1" == ""; then usage; exit 1; fi

# Get options
FIRST=""
INCREMENT=""
VERBOSE=0
while getopts ":f:i:v" opt; do
  case $opt in
    f)
      FORMAT="$OPTARG"
      ;;
    i)
      INCREMENT="$OPTARG"
      ;;
    v)
      VERBOSE=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))" # Shift off the options and optional --.

# Get arguments
args=("$@")
numargs=${#args[@]}
case $numargs in
    3)
        FIRST=${args[0]}
        INCREMENT=${args[1]}
        LAST=${args[2]}
        ;;
    2)
        FIRST=${args[0]}
        LAST=${args[1]}
        ;;
    1)
        LAST=${args[0]}
        ;;
esac

# Defaults
if test "$INCREMENT" == ""; then INCREMENT="1d"; fi
if test "$FIRST" == ""; then FIRST=$(date --utc "+$FORMAT"); fi
if test "$FORMAT" == ""; then FORMAT="%Y%m%d%H%M"; fi

if test $VERBOSE -eq 1; then
    echo "OPTIONS:" >&2
    echo "FIRST      =$FIRST" >&2
    echo "LAST       =$LAST" >&2
    echo "INCREMENT  =$INCREMENT" >&2
    echo "FORMAT     =$FORMAT" >&2
    echo "VERBOSE    =$VERBOSE" >&2
    echo "ARGUMENTS:" >&2
    for arg in ${args[@]}; do
        echo "    $arg" >&2
    done
fi

# Make GNU date increments
gnuincrement=""
value=$(echo "$INCREMENT" | grep -Eo '[0-9]*')
unit=$(echo "$INCREMENT" | grep -Eo '[a-Z]*')
case $unit in
    "Y")
        gnuincrement=${value}years
        ;;
    "y")
        gnuincrement=${value}years
        ;;
    "M")
        gnuincrement=${value}months
        ;;
    "w")
        gnuincrement=${value}weeks
        ;;
    "d")
        gnuincrement=${value}days
        ;;
    "h")
        gnuincrement=${value}hours
        ;;
    "m")
        gnuincrement=${value}minutes
        ;;
    "s")
        gnuincrement=${value}seconds
        ;;
esac

if test "$gnuincrement" == ""; then
    echo "ERROR: INCREMENT not recognized: $INCREMENT" >&2
    exit 1
fi

# Print sequence
startepoch=$(date --utc --date="$FIRST" +%s)
if test "$?" -ne 0; then
    echo "ERROR: FIRST not valid date: $FIRST"  >&2
    exit 1
fi
endepoch=$(date --utc --date="$LAST" +%s)
if test "$?" -ne 0; then
    echo "ERROR: LAST not valid date: $LAST"  >&2
    exit 1
fi

if test "$startepoch" -le "$endepoch"; then
    direction="+"
else
    direction="-"
fi

if test $VERBOSE -eq 1; then
    echo "gnuincrement=$gnuincrement" >&2
    echo "startepoch=$startepoch" >&2
    echo "endepoch=$endepoch" >&2
    echo "direction=$direction" >&2
fi

currentepoch=$startepoch
if test "$direction" == "+"; then
    while test "$currentepoch" -le "$endepoch"; do
        date --utc -d"$(LC_TIME=C date -d@$currentepoch)" "+$FORMAT"
        currentepoch=$(date --utc -d"$(LC_TIME=C date -d@$currentepoch) $direction$gnuincrement" "+%s")
    done
fi

if test "$direction" == "-"; then
    while test "$currentepoch" -ge "$endepoch"; do
        date --utc -d"$(LC_TIME=C date -d@$currentepoch)" "+$FORMAT"
        currentepoch=$(date --utc -d"$(LC_TIME=C date -d@$currentepoch) $direction$gnuincrement" "+%s")
    done
fi
