source docker_image.sh

cd ..
docker build -t $IMAGE_FILTER -f docker/Dockerfile.filter .
