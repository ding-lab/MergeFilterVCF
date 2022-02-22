cd ../..
source docker/docker_image.sh
IMAGE=$IMAGE_FILTER

#DATD="/home/mwyczalk_test/Projects/GermlineCaller/C3L-00001"
OUTD="testing-output/merge_results_docker/docker_run_TinJasmine"  # map this to /results

INPUT="/results/merged.vcf"
OUT="/results/merged-filtered.vcf"

PROCESS="/opt/MergeFilterVCF/src/filter_vcf.sh"
EXCLUDE="-X varscan_indel,gatk_indel"

# This is the exclude filter for direct call - why the difference?
# EXCLUDE="-X varscan_indel,gatk_indel,varscan_snv,gatk_snv"

CMD="bash $PROCESS $@ -o $OUT $EXCLUDE $INPUT"

# ARGS="-M docker -l"

# testing on compute1 is easier if 
# -r - remapping of paths
# -g -K - waits until job done before returning
# no -l flag - writes to logs directory
ARGS="-M compute1 -r -g -K " # -g -K blocks bsub until done

DCMD="bash docker/WUDocker/start_docker.sh $@ $ARGS -I $IMAGE -c \"$CMD\" $OUTD:/results"
>&2 echo Running: $DCMD
eval $DCMD

