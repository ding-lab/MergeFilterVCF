#/bin/bash

read -r -d '' USAGE <<'EOF'
Filter and merge varscan, pindel, and GATK VCFs using GATK CombineVariants

Usage: merge_vcf.sh [options] gatk_indel gatk_snv pindel varscan_indel varscan_snv

Options:
-h: Print this help message
-d: Dry run - output commands but do not execute them
-o OUT_VCF : Output VCF filename.  Default: output/merged.vcf
-R REF : Reference, required
-P: merge all variants regardless of FILTER status
-N: remap IUPAC Ambiguity Codes to N
-p TMPD : specify output directory of filtered VCFs.  Default is same directory as files are in
-X XARGS : additional arguments passed to CombineVariants

Combine VCF files from several callers into one
The following files are combined:
* GATK indel          ("gatk_indel")
* GATK SNV            ("gatk_snv")
* pindel indel        ("pindel")
* varscan indel       ("varscan_indel")
* varscan SNV         ("varscan_snv")

priority: gatk_snv,varscan_snv,gatk_indel,varscan_indel,pindel

Two types of filtering can be done to input data: 
* retain only FILTER=PASS calls
    Only variants with FILTER value of PASS or . are retained for merging
    unless -P flag is set.  Given input A.vcf, intermediate files filtered.A.vcf are created
* remap any ambiguity codes in REF (not ACGTN) to N.
    Optionally remap IUPAC Ambiguity Codes to N for the reference allele, to avoid errors like,
        unparsable vcf record with allele R
    This generates intermediate files remap_ref.A.vcf.  Because these take up space and this
    problem is rarely seen unless -P is defined, by default we do not do this remapping
    See https://droog.gs.washington.edu/parc/images/iupac.html  Remapping to N suggested by Chris Miller
EOF

source /opt/MergeFilterVCF/src/utils.sh
SCRIPT=$(basename $0)

JAVA="/usr/bin/java"
JAR="/usr/GenomeAnalysisTK.jar"

OUT_VCF="output/merged.vcf"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdC:R:S:L:l:o:Pp:X:N" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    d)  # binary argument
      DRYRUN=1
      ;;
    o) # value argument
      OUT_VCF="$OPTARG"
      ;;
    R) # value argument
      REF="$OPTARG"
      ;;
    P) # value argument
      NO_PASS_FILTER=1
      ;;
    N) # value argument
      REF_REMAP=1
      ;;
    p) # value argument
      TMPD="$OPTARG"
      ;;
    X) # value argument
      XARGS="$OPTARG"
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

if [ "$#" -ne 5 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo "$USAGE"
    exit 1
fi

function pass_filter {
	INVCF=$1

	if [ -z $TMPD ]; then
		TMPD_L=$(dirname $INVCF)
	else
		TMPD_L=$TMPD
	fi
	mkdir -p $TMPD_L
	test_exit_status

	FN=$(basename $INVCF)
	OUT="$TMPD_L/filtered.$FN"
	
	CMD="awk 'BEGIN{FS=\"\\t\";OFS=\"\\t\"}{if (\$0 ~ /^#/) print; else if (\$7 == \"PASS\" || \$7 == \".\") print}' $INVCF > $OUT"
	run_cmd "$CMD" $DRYRUN
	echo $OUT
}

function remap_ref {
	INVCF=$1

	if [ -z $TMPD ]; then
		TMPD_L=$(dirname $INVCF)
	else
		TMPD_L=$TMPD
	fi
	mkdir -p $TMPD_L
	test_exit_status

	FN=$(basename $INVCF)
	OUT="$TMPD_L/remap_ref.$FN"
	
	CMD="awk 'BEGIN{FS=\"\\t\";OFS=\"\\t\"}{if (\$0 ~ /^#/) print; else if (\$4 !~ /[ACGTN]/) \$4 = \"N\"; print}' $INVCF > $OUT"

	run_cmd "$CMD" $DRYRUN
	echo $OUT
}

GATK_INDEL=$1 && confirm $GATK_INDEL
GATK_SNV=$2 && confirm $GATK_SNV
PINDEL=$3 && confirm $PINDEL
VARSCAN_INDEL=$4 && confirm $VARSCAN_INDEL
VARSCAN_SNV=$5 && confirm $VARSCAN_SNV

if [ -z $REF ]; then
    >&2 echo ERROR: Reference not defined \[ -R \]
    >&2 echo "$USAGE"
    exit 1
fi
confirm $REF

# Skipping the pass filter results in a wide variety of set values.  See 
# https://gatkforums.broadinstitute.org/gatk/discussion/53/combining-variants-from-different-files-into-one
# Example counts of set values with -P:
# 945302 FilteredInAll
#    422 filterIngatk_indel-filterInvarscan_indel-pindel
#     35 filterIngatk_indel-pindel
#     84 filterIngatk_indel-varscan_indel
#      2 filterIngatk_indel-varscan_indel-filterInpindel
#     35 filterIngatk_indel-varscan_indel-pindel
#   3037 filterIngatk_snv-varscan_snv
#      1 filterInpindel-pindel
#     25 filterInvarscan_indel-pindel
#   2102 gatk_indel
#     22 gatk_indel-filterInpindel
#      1 gatk_indel-filterInpindel-pindel
#   2292 gatk_indel-filterInvarscan_indel
#     95 gatk_indel-filterInvarscan_indel-filterInpindel
#    372 gatk_indel-filterInvarscan_indel-pindel
#    365 gatk_indel-pindel
#      2 gatk_indel-pindel-filterInpindel
#   3721 gatk_indel-varscan_indel
#     37 gatk_indel-varscan_indel-filterInpindel
#   2971 gatk_indel-varscan_indel-pindel
#      4 gatk_indel-varscan_indel-pindel-filterInpindel
#  17138 gatk_snv
#  13456 gatk_snv-filterInvarscan_snv
#  91226 gatk_snv-varscan_snv
#    265 pindel
#      2 pindel-filterInpindel
#    267 varscan_indel
#      1 varscan_indel-filterInpindel
#     37 varscan_indel-pindel
#   3401 varscan_snv

# -filteredRecordsMergeType argument determines how CombineVariants handles
# sites where a record is present in multiple VCFs, but it is filtered in some
# and unfiltered in others, as described in the tool documentation page linked
# above.
# To keep things simple, by default we retain only PASS variants

if [ -z $NO_PASS_FILTER ]; then
	GATK_INDEL=$( pass_filter $GATK_INDEL ) ; test_exit_status
	GATK_SNV=$( pass_filter $GATK_SNV ) ; test_exit_status
	PINDEL=$( pass_filter $PINDEL ) ; test_exit_status
	VARSCAN_INDEL=$( pass_filter $VARSCAN_INDEL ) ; test_exit_status
	VARSCAN_SNV=$( pass_filter $VARSCAN_SNV ) ; test_exit_status
fi

if [ "$REF_REMAP" ]; then
	GATK_INDEL=$( remap_ref $GATK_INDEL ) ; test_exit_status
	GATK_SNV=$( remap_ref $GATK_SNV ) ; test_exit_status
	PINDEL=$( remap_ref $PINDEL ) ; test_exit_status
	VARSCAN_INDEL=$( remap_ref $VARSCAN_INDEL ) ; test_exit_status
	VARSCAN_SNV=$( remap_ref $VARSCAN_SNV ) ; test_exit_status
fi

OUTD=$(dirname $OUT_VCF)
mkdir -p $OUTD
test_exit_status

JAVA_OPTS="-Xmx2g"
PRIORITY="gatk_snv,varscan_snv,gatk_indel,varscan_indel,pindel"
ARGS="-genotypeMergeOptions PRIORITIZE -U ALLOW_SEQ_DICT_INCOMPATIBILITY $XARGS"
VARIANTS="  --variant:gatk_snv $GATK_SNV \\
            --variant:gatk_indel $GATK_INDEL \\
            --variant:varscan_snv $VARSCAN_SNV \\
            --variant:varscan_indel $VARSCAN_INDEL \\
            --variant:pindel $PINDEL "

CMD="$JAVA $JAVA_OPTS -jar $JAR -R $REF -T CombineVariants -o $OUT_VCF $VARIANTS -priority $PRIORITY $ARGS "

run_cmd "$CMD" $DRYRUN
 
>&2 echo Merged unfiltered VCF written to $OUT_VCF

