#!/usr/bin/env bash

set -e

HERE=$(dirname "$(realpath "$0")");

docker compose down;
docker compose up -d;

(
    cd $HERE/noir_circuits &&
    bash $HERE/noir_circuits/export-verifier-contract.sh
)
(
    cd $HERE/contracts &&
    bash $HERE/contracts/run-deploy.sh
)
(cd $HERE/webapp && yarn dev)
