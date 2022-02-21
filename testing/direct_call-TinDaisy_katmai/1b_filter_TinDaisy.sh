OUTD="/results"
mkdir -p $OUTD

#Usage:
#  bash filter_vcf.sh [options] input.vcf
#
#Options:
#-h: Print this help message
#-d: Dry run - output commands but do not execute them
#-v: print filter debug information
#-o OUT_VCF : Output VCF filename.  Default: write to stdout
#-B: bypass this filter, i.e., do not remove any calls
#-I include_list: Retain only calls with given caller(s); comma-separated list
#-X exclude_list: Exclude all calls with given caller(s); comma-separated list
#-R: remove filtered variants.  Default is to retain filtered variants with filter name in VCF FILTER field

INPUT="$OUTD/merged.vcf"

OUT="$OUTD/merged-filtered.vcf"

#   1313 set=mutect
#     29 set=mutect-strelka
#    266 set=pindel
#      2 set=pindel-sindel
#     82 set=sindel
#     40 set=strelka
#    147 set=varindel
#      1 set=varindel-pindel
#     10 set=varindel-pindel-sindel
#     13 set=varindel-sindel
#    276 set=varscan
#     47 set=varscan-mutect
#    141 set=varscan-mutect-strelka
#     11 set=varscan-strelka

EXCLUDE="-X strelka,varscan,mutect,sindel,varindel,pindel"

CMD="bash ../../src/filter_vcf.sh $@ -o $OUT $EXCLUDE $INPUT"

>&2 echo Running $CMD
eval $CMD

