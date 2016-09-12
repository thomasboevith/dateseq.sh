# dateseq.sh

Like [seq](https://en.wikipedia.org/wiki/Seq_(Unix)) but for dates and times.

## dateseq.sh

    dateseq.sh 0.1 -- print a sequence of dates and times

    Usage: dateseq.sh [OPTION]... LAST
           dateseq.sh [OPTION]... FIRST LAST
           dateseq.sh [OPTION]... FIRST INCREMENT LAST

    Options:
        -f    FORMAT [default: %Y%m%d%H%M]
        -i    INCREMENT <value><unit> (y, M, w, m, d, h, m, s) [default: 1d]
        -v    VERBOSE

    FIRST/LAST is a datetime with date in the format YYYYMMDD or YYYY-MM-DD
    and time in the format HMS, HM, H:M, or H:M:S (if used).
    If FIRST is omitted, it defaults to todays date at midnight.
    If INCREMENT is omitted, it defaults to 1 day (1d). INCREMENT is always
    positive even if FIRST is smaller than LAST.
    FORMAT is in the GNU date format and defaults to %Y%m%d%H%M.
    INCREMENT supports: 2y 4M 2w 1d 6h 15m 30s, for year, month, week, day,
    hour, minute, or second.

    Examples:
        ./dateseq.sh 20160916
        ./dateseq.sh 20160916 20161010
        ./dateseq.sh -f %Y-%m-%d\ %H:%M:%S 20160916\ 0730 30m 20160916\ 1230
        ./dateseq.sh -f %s 20160916\ 0730 2m 20160916\ 0830

