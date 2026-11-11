#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="scbio"
ENV_FILE=".devcontainer/environment.yml"

if [ -d "/opt/conda/envs/$ENV_NAME/conda-meta" ]; then
    conda env update \
        -n "$ENV_NAME" \
        -f "$ENV_FILE" \
        --prune
else
    conda env create -f "$ENV_FILE"
fi

# Python Jupyter Kernel
conda run -n "$ENV_NAME" python -m ipykernel install \
    --user \
    --name scbio-python \
    --display-name "Python (scbio)"

# R Jupyter Kernel
conda run -n "$ENV_NAME" Rscript -e \
    'IRkernel::installspec(
        user = TRUE,
        name = "scbio-r",
        displayname = "R (scbio)"
    )'