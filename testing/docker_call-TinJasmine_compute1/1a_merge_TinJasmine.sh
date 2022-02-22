source ../../docker/docker_image.sh
IMAGE=$IMAGE_GATK

cd ../..

DATAD="/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/TinJasmine.cwl/b50a25fa-ee76-40dd-9abf-4abcca8157ea"
REFD="/storage1/fs1/dinglab/Active/Resources/References"

REF="/Reference/GRCh38.d1.vd1/GRCh38.d1.vd1.fa"

PROCESS="/opt/MergeFilterVCF/src/merge_vcf_TinJasmine.sh"

# CMD="bash ../../src/merge_vcf_TinJasmine.sh $@ $REMAP_ARG -o $OUT -R $REF $IN_VCF"

OUTD="testing-output/merge_results_docker/docker_run_TinJasmine"
mkdir -p $OUTD
OUT="/results/merged.vcf"  

IN_VCF=" \
/data/call-vld_filter_gatk_indel/execution/VLD_FilterVCF_output.vcf \
/data/call-vld_filter_gatk_snp/execution/VLD_FilterVCF_output.vcf \
/data/call-vld_filter_pindel/execution/VLD_FilterVCF_output.vcf \
/data/call-vld_filter_varscan_indel/execution/VLD_FilterVCF_output.vcf \
/data/call-vld_filter_varscan_snp/execution/VLD_FilterVCF_output.vcf"

# -N does the ref_remap
CMD="bash $PROCESS $@ -N -o $OUT -R $REF $IN_VCF"
VOLUME_MAPPING="$DATAD:/data $REFD:/Reference $OUTD:/results"

# testing on compute1 is easier if 
# -r - remapping of paths
# -g -K - waits until job done before returning
# no -l flag - writes to logs directory
ARGS="-M compute1 -r -g -K " # -g -K blocks bsub until done

DCMD="bash docker/WUDocker/start_docker.sh $@ $ARGS -I $IMAGE -c \"$CMD\" $VOLUME_MAPPING"

>&2 echo Running: $DCMD
eval $DCMD

