include $(dir $(lastword $(MAKEFILE_LIST)))/../../config.mk

# NVME_PROVISIONER_IMAGE = $(AWS_PUBLIC_ECR_REGISTRY)/$(AWS_PUBLIC_IMAGE_PREFIX)nvme-provisioner
NVME_PROVISIONER_IMAGE = ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_NVME}
NVME_PROVISIONER_TAG = latest

nvme-provisioner@logintodocker:
#	echo $(DOCKER_TOKEN) > /tmp/password.txt 
#	cat /tmp/password.txt | docker login --username $(DOCKER_USER) --password-stdin
	aws ecr-public get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_PUBLIC_ECR_REGISTRY)

buildx@install:
	aws ecr-public get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_PUBLIC_ECR_REGISTRY)
	docker --version
	mkdir -vp ~/.docker/cli-plugins/
	curl --silent -L "https://github.com/docker/buildx/releases/download/v0.3.0/buildx-v0.3.0.linux-arm-v6" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx

nvme-provisioner@build:
	aws ecr-public get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_PUBLIC_ECR_REGISTRY)
	cd tools/nvme-provisioner; \
	pwd; ls; \
	docker buildx create --name multiarch --use; \
	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(NVME_PROVISIONER_IMAGE):$(NVME_PROVISIONER_TAG) .

nvme-provisioner@push:
	docker push $(NVME_PROVISIONER_IMAGE):$(NVME_PROVISIONER_TAG)