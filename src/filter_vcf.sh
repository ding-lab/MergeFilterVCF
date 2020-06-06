# bin/bash

read -r -d '' USAGE <<'EOF'
Filter out calls based on which callers detected them

Usage:
  bash filter_vcf.sh [options] input.vcf 

Options:
-h: Print this help message
-d: Dry run - output commands but do not execute them
-v: print filter debug information
-o OUT_VCF : Output VCF filename.  Default: write to stdout
-B: bypass this filter, i.e., do not remove any calls
-I include_list: Retain only calls with given caller(s); comma-separated list
-X exclude_list: Exclude all calls with given caller(s); comma-separated list
-R: remove filtered variants.  Default is to retain filtered variants with filter name in VCF FILTER field

Arguments -I and -X are mutually exclusive, one or the other must be defined.

EOF

source /opt/MergeFilterVCF/src/utils.sh
SCRIPT=$(basename $0)
export PYTHONPATH="/opt/MergeFilterVCF/src:$PYTHONPATH"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdvo:BI:X:R" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d)  # binary argument
      DRYRUN=1
      ;;
    v)  # binary argument
      MERGE_ARG="$MERGE_ARG --debug"
      ;;
    o) # value argument
      OUT_VCF="$OPTARG"
      ;;
    B)  # binary argument
      MERGE_ARG="$MERGE_ARG --bypass"
      ;;
    I) # value argument
      INCLUDE="$OPTARG"
      ;;
    X) # value argument
      EXCLUDE="$OPTARG"
      ;;
    R)
      FILTER_ARG="--no-filtered"
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG"
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument."
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo "$USAGE"
    exit 1
fi
VCF=$1; shift
confirm $VCF

if [ "$INCLUDE" ]; then
    if  [ "$EXCLUDE" ]; then
        >&2 echo ERROR: -I INCLUDE and -X EXCLUDE are mutually exclusive
        >&2 echo "$USAGE"
        exit 1
    else
        MERGE_ARG="$MERGE_ARG --include $INCLUDE"
    fi
else
    if  [ -z "$EXCLUDE" ]; then
        >&2 echo ERROR: -I INCLUDE or -X EXCLUDE must be defined
        >&2 echo "$USAGE"
        exit 1
    fi
    MERGE_ARG="$MERGE_ARG --exclude $EXCLUDE"
fi

export PYTHONPATH="/opt/MergeFilterVCF/src:$PYTHONPATH"

MERGE_FILTER="/usr/local/bin/vcf_filter.py $FILTER_ARG --local-script merge_filter.py"  # filter module

#CMD="/usr/local/bin/python $MERGE_FILTER $VCF merge $MERGE_ARG "
# Getting errors like 
#    TypeError: startswith first arg must be bytes or a tuple of bytes, not str
CMD="cat $VCF | /usr/local/bin/python $MERGE_FILTER - merge $MERGE_ARG "

if [ "$OUT_VCF" ]; then

    OUTD=$(dirname $OUT_VCF)
    mkdir -p $OUTD
    test_exit_status

    CMD="$CMD > $OUT_VCF"
fi

run_cmd "$CMD" $DRYRUN

if [ "$OUT_VCF" ]; then
    >&2 echo Written to $OUT_VCF
fi


