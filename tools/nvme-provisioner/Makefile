include $(dir $(lastword $(MAKEFILE_LIST)))/../../config.mk

# NVME_PROVISIONER_IMAGE = $(AWS_PUBLIC_ECR_REGISTRY)/$(AWS_PUBLIC_IMAGE_PREFIX)nvme-provisioner
NVME_PROVISIONER_IMAGE = ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${AWS_ECR_NVME}
NVME_PROVISIONER_TAG = latest
IMAGE_REPO := public.ecr.aws/s0g1m5a8/buildx-multiarch:latest
#need to update IMAGE_REPO to AWS ECR public.ecr.aws/s0g1m5a8/buildx-multiarch:latest
IMAGE_TAG := latest

buildx@install:
	docker --version
	mkdir -vp ~/.docker/cli-plugins/
	aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
	TOKEN=$(aws ecr-public get-authorization-token --region us-east-1 --output=text --query 'authorizationData.authorizationToken')
	curl -i -H "Authorization: Bearer $TOKEN" ${IMAGE_REPO}
nvme-provisioner@build:
	docker buildx create --name multiarch --use; \
	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(NVME_PROVISIONER_IMAGE):$(NVME_PROVISIONER_TAG) .
#	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(AWS_PUBLIC_ECR_REGISTRY)
#	docker build -t ${AWS_ECR_NVME} .

nvme-provisioner@push:
	docker tag ${AWS_ECR_NVME}:${NVME_PROVISIONER_TAG} ${NVME_PROVISIONER_IMAGE}:${NVME_PROVISIONER_TAG}
	docker push $(NVME_PROVISIONER_IMAGE):$(NVME_PROVISIONER_TAG)