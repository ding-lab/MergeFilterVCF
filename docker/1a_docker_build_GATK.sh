source docker_image.sh

cd ..
docker build -t $IMAGE_GATK -f docker/Dockerfile.GATK .
