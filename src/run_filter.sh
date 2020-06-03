#/bin/bash

read -r -d '' USAGE <<'EOF'
Filter merged VCF file to include or exclude calls based on value of "set" INFO field

Usage:
  bash run_merge_filter.sh [options] input.vcf 

Options:
-h: Print this help message
-d: Dry run - output commands but do not execute them
-v: print filter debug information
-o OUT_VCF : Output VCF filename.  Default: write to stdout
-B: bypass this filter, i.e., do not remove any calls
-I include_list: Retain only calls with given caller(s); comma-separated list
-X exclude_list: Exclude all calls with given caller(s); comma-separated list

Arguments -I and -X are mutually exclusive.  If neither is defined, the default is,
-X varscan_indel,GATK_indel

EOF

source /opt/MergeFilterVCF/src/utils.sh
SCRIPT=$(basename $0)

EXCLUDE_DEFAULT="varscan_indel,GATK_indel"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdvo:BI:X:" opt; do
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
        EXCLUDE=$EXCLUDE_DEFAULT
    fi
    MERGE_ARG="$MERGE_ARG --exclude $EXCLUDE"
fi

export PYTHONPATH="/opt/MergeFilterVCF/src:$PYTHONPATH"

MERGE_FILTER="vcf_filter.py --no-filtered --local-script merge_filter.py"  # filter module

CMD="$MERGE_FILTER $VCF merge $MERGE_ARG "

if [ "$OUT_VCF" ]; then
    CMD="$CMD > $OUT_VCF"
fi

run_cmd "$CMD" $DRYRUN

if [ "$OUT_VCF" ]; then
    >&2 echo Written to $OUT_VCF
fi


