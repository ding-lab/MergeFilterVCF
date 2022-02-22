source ../../docker/docker_image.sh
IMAGE=$IMAGE_FILTER

#DATAD="/home/mwyczalk_test/Projects/GermlineCaller/C3L-00001"
DATAD="/home/mwyczalk_test/Projects/TinDaisy/testing/C3L-00908-data/dat"
OUTD="./results"

INPUT="/results/merged.vcf"
OUT="/results/merged-filtered.vcf"

PROCESS="/opt/MergeFilterVCF/src/filter_vcf.sh"
EXCLUDE="-X strelka,varscan,mutect,sindel,varindel,pindel"

CMD="bash $PROCESS $@ -o $OUT $EXCLUDE $INPUT"

ARGS="-M docker -l"
DCMD="../../docker/WUDocker/start_docker.sh $@ $ARGS -I $IMAGE -c \"$CMD\" $DATAD:/data $OUTD:/results"
>&2 echo Running: $DCMD
eval $DCMD

