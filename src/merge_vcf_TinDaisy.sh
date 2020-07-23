#/bin/bash
read -r -d '' USAGE <<'EOF'
Filter and merge varscan, pindel, strelka, and mutect VCFs using GATK CombineVariants

Usage: merge_vcf_TinDaisy.sh [options] strelka sindel varscan varindel mutect pindel

Options:
-h: Print this help message
-d: Dry run - output commands but do not execute them
-o OUT_VCF : Output VCF filename.  Default: output/merged.vcf
-R REF : Reference, required
-P: merge all variants regardless of FILTER status
-N: remap IUPAC Ambiguity Codes to N
-p TMPD : specify output directory of intermediate filtered VCFs.  Default is same directory as input files
-X XARGS : additional arguments passed to CombineVariants

Combine VCF files from several callers into one
The following files are combined:
* strelka SNV         ("strelka")
* strelka indel       ("sindel")
* varscan SNV         ("varscan")
* varscan indel       ("varindel")
* mutect SNV          ("mutect")
* pindel indel        ("pindel")

priority: varscan,mutect,strelka,varindel,pindel,sindel

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

if [ "$#" -ne 6 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo "$USAGE"
    exit 1
fi

function pass_filter {
    TMP_ID=$1     # Unique identifier so names don't clash
	INVCF=$2

	if [ -z $TMPD ]; then
		TMPD_L=$(dirname $INVCF)
	else
		TMPD_L=$TMPD
	fi
	mkdir -p $TMPD_L
	test_exit_status

	FN=$(basename $INVCF)
	OUT="$TMPD_L/pass_filter.${TMP_ID}.$FN"
    >&2 echo Writing pass_filter to file $OUT

	CMD="awk 'BEGIN{FS=\"\\t\";OFS=\"\\t\"}{if (\$0 ~ /^#/) print; else if (\$7 == \"PASS\" || \$7 == \".\") print}' $INVCF > $OUT"
	run_cmd "$CMD" $DRYRUN
	echo $OUT
}

function remap_ref {
    TMP_ID=$1     # Unique identifier so names don't clash
	INVCF=$2

	if [ -z $TMPD ]; then
		TMPD_L=$(dirname $INVCF)
	else
		TMPD_L=$TMPD
	fi
	mkdir -p $TMPD_L
	test_exit_status

	FN=$(basename $INVCF)
	OUT="$TMPD_L/remap_ref.${TMP_ID}.$FN"
	
	CMD="awk 'BEGIN{FS=\"\\t\";OFS=\"\\t\"}{if (\$0 ~ /^#/) print; else if (\$4 !~ /[ACGTN]/) \$4 = \"N\"; print}' $INVCF > $OUT"

	run_cmd "$CMD" $DRYRUN
	echo $OUT
}

STRELKA_SNV=$1 && confirm $STRELKA_SNV
STRELKA_INDEL=$2 && confirm $STRELKA_INDEL
VARSCAN_SNV=$3 && confirm $VARSCAN_SNV
VARSCAN_INDEL=$4 && confirm $VARSCAN_INDEL
MUTECT=$5 && confirm $MUTECT
PINDEL=$6 && confirm $PINDEL

#* strelka SNV         ("strelka")
#* strelka indel       ("sindel")
#* varscan SNV         ("varscan")
#* varscan indel       ("varindel")
#* mutect SNV          ("mutect")
#* pindel indel        ("pindel")

if [ -z $REF ]; then
    >&2 echo ERROR: Reference not defined \[ -R \]
    >&2 echo "$USAGE"
    exit 1
fi
confirm $REF

# Skipping the pass filter (-P) results in a wide variety of set values.  See 
# https://gatkforums.broadinstitute.org/gatk/discussion/53/combining-variants-from-different-files-into-one

# -filteredRecordsMergeType argument determines how CombineVariants handles
# sites where a record is present in multiple VCFs, but it is filtered in some
# and unfiltered in others, as described in the tool documentation page linked
# above.
# To keep things simple, by default we retain only PASS variants

if [ -z $NO_PASS_FILTER ]; then
    STRELKA_SNV=$( pass_filter strelka_snv $STRELKA_SNV ) ; test_exit_status
    STRELKA_INDEL=$( pass_filter strelka_indel $STRELKA_INDEL ) ; test_exit_status
    VARSCAN_SNV=$( pass_filter varscan_snv $VARSCAN_SNV ) ; test_exit_status
    VARSCAN_INDEL=$( pass_filter varscan_indel $VARSCAN_INDEL ) ; test_exit_status
    MUTECT=$( pass_filter mutect $MUTECT ) ; test_exit_status
    PINDEL=$( pass_filter pindel $PINDEL ) ; test_exit_status
fi

if [ "$REF_REMAP" ]; then
    STRELKA_SNV=$( remap_ref strelka_snv $STRELKA_SNV ) ; test_exit_status
    STRELKA_INDEL=$( remap_ref strelka_indel $STRELKA_INDEL ) ; test_exit_status
    VARSCAN_SNV=$( remap_ref varscan_snv $VARSCAN_SNV ) ; test_exit_status
    VARSCAN_INDEL=$( remap_ref varscan_indel $VARSCAN_INDEL ) ; test_exit_status
    MUTECT=$( remap_ref mutect $MUTECT ) ; test_exit_status
    PINDEL=$( remap_ref pindel $PINDEL ) ; test_exit_status
fi

OUTD=$(dirname $OUT_VCF)
mkdir -p $OUTD
test_exit_status

JAVA_OPTS="-Xmx2g"
PRIORITY="varscan,mutect,strelka,varindel,pindel,sindel"
ARGS="-genotypeMergeOptions PRIORITIZE -U ALLOW_SEQ_DICT_INCOMPATIBILITY $XARGS"

VARIANTS="  --variant:strelka $STRELKA_SNV \\
            --variant:sindel $STRELKA_INDEL \\
            --variant:varscan $VARSCAN_SNV \\
            --variant:varindel $VARSCAN_INDEL \\
            --variant:mutect $MUTECT \\
            --variant:pindel $PINDEL "

CMD="$JAVA $JAVA_OPTS -jar $JAR -R $REF -T CombineVariants -o $OUT_VCF $VARIANTS -priority $PRIORITY $ARGS "

run_cmd "$CMD" $DRYRUN
 
>&2 echo Merged unfiltered VCF written to $OUT_VCF

