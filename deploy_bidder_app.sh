# Deploy the bidderapp
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
export BIDDER_OVERLAY_TEMP=$(mktemp)
envsubst < deployment/infrastructure/deployment/bidder/overlay-codekit-${VARIANT,,}.yaml.tmpl >${BIDDER_OVERLAY_TEMP}
make eks@deploybidder VALUES=${BIDDER_OVERLAY_TEMP}

if sh -c "echo $USE_LOAD_GENERATOR | grep -q -E '^(yes)$'" ; then
    make load-generator@build
    # make load-generator@push
    LOAD_GENERATOR_OVERLAY_TEMP=$(mktemp)
    envsubst < deployment/infrastructure/deployment/load-generator/overlay-codekit.yaml.tmpl >${LOAD_GENERATOR_OVERLAY_TEMP}

    echo "[Setup] Deploying the load generator..."

    if sh -c "echo $VARIANT | grep -q -E '^(Aerospike)$'" ; then
      make benchmark@run TARGET="http://bidder/bidrequest" VALUES="${LOAD_GENERATOR_OVERLAY_TEMP}" RATE_PER_JOB=3000000 NUMBER_OF_JOBS=1 NUMBER_OF_DEVICES=1000000000 DURATION=30m STACK_NAME=${STACK_NAME} LOAD_GENERATOR_NODE_SELECTOR_POOL=benchmark
    else
      TARGET="http://bidder/bidrequest" VALUES="${LOAD_GENERATOR_OVERLAY_TEMP}" make benchmark@run-simple
    fi
fi
echo "[Setup] The bidder has been deployed. You can log in to the EKS cluster and access the Grafana dashboards."
