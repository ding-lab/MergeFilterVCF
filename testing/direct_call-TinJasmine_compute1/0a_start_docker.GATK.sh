
DATAD="/scratch1/fs1/dinglab/m.wyczalkowski/cromwell-data/cromwell-workdir/cromwell-executions/TinJasmine.cwl/b50a25fa-ee76-40dd-9abf-4abcca8157ea"
REFD="/storage1/fs1/dinglab/Active/Resources/References"

# changing directories so entire project directory is mapped by default
cd ../..
OUTD="testing-output"  
mkdir -p $OUTD

source docker/docker_image.sh
IMAGE=$IMAGE_GATK

CMD="bash docker/WUDocker/start_docker.sh $@ -M compute1 -I $IMAGE $DATAD:/data $REFD:/Reference $OUTD:/results"

>&2 echo Running: $CMD
eval $CMD


