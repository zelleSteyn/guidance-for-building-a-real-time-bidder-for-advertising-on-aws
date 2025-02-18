include $(dir $(lastword $(MAKEFILE_LIST)))/../../config.mk

# NVME_PROVISIONER_IMAGE = $(AWS_PUBLIC_ECR_REGISTRY)/$(AWS_PUBLIC_IMAGE_PREFIX)nvme-provisioner
NVME_PROVISIONER_IMAGE = ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_NVME}
NVME_PROVISIONER_TAG = latest
IMAGE_REPO := https://github.com/docker/buildx/releases/download/v0.3.0/buildx-v0.3.0.linux-arm-v6
#need to update IMAGE_REPO to AWS ECR public.ecr.aws/s0g1m5a8/buildx-multiarch:latest

IMAGE_TAG := latest

buildx@install:
	docker --version
	mkdir -vp ~/.docker/cli-plugins/
	curl --silent -L "$(IMAGE_REPO)" > ~/.docker/cli-plugins/docker-buildx
	chmod a+x ~/.docker/cli-plugins/docker-buildx

.PHONY: build
nvme-provisioner@build:
	cd tools/nvme-provisioner; \
	pwd; ls; \
	docker build -t nvme-provisioner --push --platform linux/amd64,linux/arm64 --build-arg BASE_IMAGE=public.ecr.aws/s0g1m5a8/buildx-multiarch:latest .

.PHONY: push
#	cd tools/nvme-provisioner; \
#	pwd; ls; \
#	docker buildx create --name multiarch --use; \
#	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(NVME_PROVISIONER_IMAGE):$(NVME_PROVISIONER_TAG) .

nvme-provisioner@push:
#	docker tag $(NVME_PROVISIONER_TAG) $(NVME_PROVISIONER_IMAGE):$(NVME_PROVISIONER_TAG)
#	docker push $(NVME_PROVISIONER_IMAGE):$(NVME_PROVISIONER_TAG)
	docker push nvme-provisioner