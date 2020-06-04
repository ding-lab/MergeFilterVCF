#/bin/bash

read -r -d '' USAGE <<'EOF'
Merge varscan, pindel, and GATK VCFs using GATK CombineVariants

Usage: merge_vcf.sh [options] GATK_indel GATK_snv pindel_indel varscan_indel varscan_snv
 
Options:
-h: Print this help message
-d: Dry run - output commands but do not execute them
-o OUT_VCF : Output VCF filename.  Default: output/merged.vcf
-R REF : Reference, required

Combine VCF files from several callers into one
The following files are combined:
* varscan SNV         ("varscan_snv")
* varscan indel       ("varscan_indel")
* pindel indel        ("pindel")
* GATK SNV            ("GATK_snv")
* GATK indel          ("GATK_indel")

priority: GATK_snv,varscan_snv,GATK_indel,varscan_indel,pindel
EOF

source /opt/MergeFilterVCF/src/utils.sh
SCRIPT=$(basename $0)

JAVA="/usr/bin/java"
JAR="/usr/GenomeAnalysisTK.jar"

OUT_VCF="output/merged.vcf"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hdC:R:S:L:l:o:" opt; do
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

OUTD=$(dirname $OUT_VCF)
mkdir -p $OUTD
test_exit_status

JAVA_OPTS="-Xmx2g"
PRIORITY="gatk_snv,varscan_snv,gatk_indel,varscan_indel,pindel"
ARGS="-genotypeMergeOptions PRIORITIZE"
# -U ALLOW_SEQ_DICT_INCOMPATIBILITY 
VARIANTS="  --variant:GATK_snv $GATK_SNV \\
            --variant:GATK_indel $GATK_INDEL \\
            --variant:varscan_snv $VARSCAN_SNV \\
            --variant:varscan_indel $VARSCAN_INDEL \\
            --variant:pindel $PINDEL "

CMD="$JAVA -jar $JAR $JAVA_OPTS -R $REF -T CombineVariants -o $OUT_VCF $VARIANTS -priority $PRIORITY $ARGS "

run_cmd "$CMD" $DRYRUN
 
>&2 echo Merged unfiltered VCF written to $OUT_VCF

