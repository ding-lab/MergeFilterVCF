
#DATAD="/home/mwyczalk_test/Projects/GermlineCaller/C3L-00001"
DATAD="/home/mwyczalk_test/Projects/TinDaisy/testing/C3L-00908-data/dat"
REFD="/diskmnt/Datasets/Reference"

# changing directories so entire project directory is mapped by default
cd ../..
OUTD="testing/direct_call/results"  # output dir relative to ../..
mkdir -p $OUTD

source docker/docker_image.sh
IMAGE=$IMAGE_GATK

bash docker/WUDocker/start_docker.sh $@ -I $IMAGE $DATAD:/data $REFD:/Reference $OUTD:/results


