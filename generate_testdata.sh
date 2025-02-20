#!/usr/bin/env bash
set -ex
# Check if jq is available
type jq >/dev/null 2>&1 || { echo >&2 "The jq utility is required for this script to run."; exit 1; }

# Check if aws cli is available
type aws >/dev/null 2>&1 || { echo >&2 "The aws cli is required for this script to run."; exit 1; }

export SUPPORTED_AWS_REGIONS="us\-east\-1|us\-west\-1|us\-west\-2|us\-east\-2"

#if [[ -z "${AWS_ACCOUNT}" ]]; then
#    echo "AWS Account Id [0-9]:"
#    read AWS_ACCOUNT
#fi

export AWS_ACCOUNT=$1

#if [[ -z "${AWS_REGION}" ]]; then
#    echo "AWS Region:"
#    read AWS_REGION
#fi

export AWS_REGION=$2

if ! sh -c "echo $AWS_REGION | grep -q -E '^(${SUPPORTED_AWS_REGIONS})$'" ; then
    echo "Unsupported AWS region: ${AWS_REGION}"
    exit 1
fi

#if [[ -z "${STACK_NAME}" ]]; then
#    echo "Stack name [a-z0-9]:"
#    read STACK_NAME
#fi

export STACK_NAME=$3

#if [[ -z "${VARIANT}" ]]; then
#    echo "Database variant (DynamoDB):"
#    read VARIANT
#fi
export VARIANT=$4

#echo "Populate the database with test data (yes|no):"
#read USE_DATAGEN

export USE_DATAGEN=$5

if ! sh -c "echo $VARIANT | grep -q -E '^(DynamoDB|Aerospike)$'" ; then
    echo "Unsupported database variant: ${VARIANT}"
    exit 1
fi

#echo "Deploy the load generator (yes|no):"
#read USE_LOAD_GENERATOR

export USE_LOAD_GENERATOR=$6

if ! sh -c "echo $USE_LOAD_GENERATOR | grep -q -E '^(yes|no)$'" ; then
    echo "Invalid input: ${USE_LOAD_GENERATOR} instead of (yes|no)"
    exit 1
fi


if ! sh -c "echo $USE_DATAGEN | grep -q -E '^(yes|no)$'" ; then
    echo "Invalid input: ${USE_DATAGEN} instead of (yes|no)"
    exit 1
fi
export UNID=$7
export DYNAMODB_TABLENAME_PREFIX="${STACK_NAME}_${UNID}_"

if sh -c "echo $VARIANT | grep -q -E '^(Aerospike)$'" ; then
    echo "[Setup] Deploying the Aerospike cluster"
    make eks@provision-nvme
    make aerospike@deploy AEROSPIKE_VARIANT="benchmark"
    make aerospike@wait
fi
echo "[Setup] Granting access to the EKS cluster..."
make eks@grant-access EKS_ACCESS_ROLE_ARN=${EKS_ACCESS_ROLE_ARN} EKS_WORKER_ROLE_ARN=${EKS_WORKER_ROLE_ARN}

echo "[Setup] Login to the ECR registries..."
make ecr@login

kubectl delete jobs --field-selector status.successful=1
kubectl delete jobs --field-selector status.successful=0

if sh -c "echo $USE_DATAGEN | grep -q -E '^(yes)$'" ; then
    echo "[Setup] Populating the database with testing data..."
    make datagen@image IMAGE_PREFIX="${STACK_NAME}-"
    # make datagen@push IMAGE_PREFIX="${STACK_NAME}-"
    if sh -c "echo $VARIANT | grep -q -E '^(Aerospike)$'" ; then
       echo "Datagen on Aerospike has been disabled"
       make aerospike@datagen DATAGEN_CONCURRENCY=32 DATAGEN_ITEMS_PER_JOB=10000  DATAGEN_DEVICES_ITEMS_PER_JOB=100000 DATAGEN_DEVICES_PARALLELISM=30 STACK_NAME=${STACK_NAME} UNIQUEID=${UNID}
    else
      make dynamodb@datagen DATAGEN_CONCURRENCY=1 DATAGEN_ITEMS_PER_JOB=1000  DATAGEN_DEVICES_ITEMS_PER_JOB=1000 DATAGEN_DEVICES_PARALLELISM=1 STACK_NAME=${STACK_NAME} UNIQUEID=${UNID}
    fi
fi