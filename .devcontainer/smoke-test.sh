#!/usr/bin/env bash
set -euo pipefail

conda run --no-capture-output -n scbio python -c \
    'import anndata, scanpy, numpy, pandas, matplotlib, seaborn; print("Python analysis imports OK")'

conda run --no-capture-output -n scbio Rscript -e \
    'for (pkg in c("Seurat", "dplyr", "ggplot2", "languageserver", "IRkernel")) stopifnot(requireNamespace(pkg, quietly = TRUE)); cat("R analysis imports OK\n")'

conda run --no-capture-output -n scbio python -c \
    'from jupyter_client.kernelspec import KernelSpecManager; kernels = KernelSpecManager().find_kernel_specs(); assert {"scbio-python", "scbio-r"} <= kernels.keys(), kernels; print("Python and R kernels registered")'
