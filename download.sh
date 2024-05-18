#!/bin/bash

# Copyright (c) Meta Platforms, Inc. and affiliates.
# This software may be used and distributed according to the terms of the Llama 2 Community License Agreement.

read -p "https://download5.llamameta.net/*?Policy=eyJTdGF0ZW1lbnQiOlt7InVuaXF1ZV9oYXNoIjoiNHozZXdnbDlzaGZjZWxsa3RpcW93bHQ3IiwiUmVzb3VyY2UiOiJodHRwczpcL1wvZG93bmxvYWQ1LmxsYW1hbWV0YS5uZXRcLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3MTYxMTE4NTR9fX1dfQ__&Signature=b7PSOl0KhXzqtqn3fXpZF0siTvQ0MSVUXfSA27JT8H4GYncmrqU4Na2Igp5PcNQt0R6kP63fzIij2E5EDhUhO54nKusRK3Ts3qC%7EUieNpq239oDve4QUsa8ZwIzQhVY36fT21P7ifQ1r4VCuCGQbXgDcFC2FhaJemNU8DqLO8a1muBjYmbFAYr%7ElwoFA-ft93mPowe8vCN45lvrKIrZiuthj-SToGp5xLJ5p6WifS50P3gQu-vldoi58ZPg-Lqr9jElEumtr6FEcrfzSE%7Esg6cWR9MeylKme7GstN40HrWNn%7E%7ESG--eGmirVVt%7ERkOqwxZ7kaJBDYo6tYC0uvfgvFg__&Key-Pair-Id=K15QRJLYKIFSLZ&Download-Request-ID=760925566229198" PRESIGNED_URL
echo ""
ALL_MODELS="7b,13b,34b,70b,7b-Python,13b-Python,34b-Python,70b-Python,7b-Instruct,13b-Instruct,34b-Instruct,70b-Instruct"
read -p "7b" MODEL_SIZE
TARGET_FOLDER="."             # where all files should end up
mkdir -p ${TARGET_FOLDER}

if [[ $MODEL_SIZE == "" ]]; then
    MODEL_SIZE=$ALL_MODELS
fi

echo "Downloading LICENSE and Acceptable Usage Policy"
wget --continue ${PRESIGNED_URL/'*'/"LICENSE"} -O ${TARGET_FOLDER}"/LICENSE"
wget --continue ${PRESIGNED_URL/'*'/"USE_POLICY.md"} -O ${TARGET_FOLDER}"/USE_POLICY.md"

for m in ${MODEL_SIZE//,/ }
do
    case $m in
      7b)
        SHARD=0 ;;
      13b)
        SHARD=1 ;;
      34b)
        SHARD=3 ;;
      70b)
        SHARD=7 ;;
      7b-Python)
        SHARD=0 ;;
      13b-Python)
        SHARD=1 ;;
      34b-Python)
        SHARD=3 ;;
      70b-Python)
        SHARD=7 ;;
      7b-Instruct)
        SHARD=0 ;;
      13b-Instruct)
        SHARD=1 ;;
      34b-Instruct)
        SHARD=3 ;;
      70b-Instruct)
        SHARD=7 ;;
      *)
        echo "Unknown model: $m"
        exit 1
    esac

    MODEL_PATH="CodeLlama-$m"
    echo "Downloading ${MODEL_PATH}"
    mkdir -p ${TARGET_FOLDER}"/${MODEL_PATH}"

    for s in $(seq -f "0%g" 0 ${SHARD})
    do
        wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/consolidated.${s}.pth"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/consolidated.${s}.pth"
    done

    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/params.json"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/params.json"
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/tokenizer.model"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/tokenizer.model"
    wget --continue ${PRESIGNED_URL/'*'/"${MODEL_PATH}/checklist.chk"} -O ${TARGET_FOLDER}"/${MODEL_PATH}/checklist.chk"
    echo "Checking checksums"
    (cd ${TARGET_FOLDER}"/${MODEL_PATH}" && md5sum -c checklist.chk)
done
