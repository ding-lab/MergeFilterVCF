OUTD="/results/merge_results_direct"
mkdir -p $OUTD

# /diskmnt/Datasets/Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa
REF="/Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

# remap ambiguity codes
REMAP_ARG="-N"

# maps to /data
# DATAD="/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/TinJasmine.cwl/b50a25fa-ee76-40dd-9abf-4abcca8157ea"
IND="/data/VLD_FilterVCF.out"

IN_VCF=" \
/data/call-vld_filter_gatk_indel/execution/VLD_FilterVCF_output.vcf \
/data/call-vld_filter_gatk_snp/execution/VLD_FilterVCF_output.vcf \
/data/call-vld_filter_pindel/execution/VLD_FilterVCF_output.vcf \
/data/call-vld_filter_varscan_indel/execution/VLD_FilterVCF_output.vcf \
/data/call-vld_filter_varscan_snp/execution/VLD_FilterVCF_output.vcf"

OUT="$OUTD/merged.vcf"

# Usage: merge_vcf.sh [options] GATK_indel GATK_snv pindel_indel varscan_indel varscan_snv
CMD="bash ../../src/merge_vcf_TinJasmine.sh $@ $REMAP_ARG -o $OUT -R $REF $IN_VCF"

>&2 echo Running $CMD
eval $CMD

