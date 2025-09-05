# Use the specified NVIDIA CUDA image based on UBI 9 as the foundation
FROM nvcr.io/nvidia/cuda:12.9.1-devel-ubi9

# Install Python, pip, common system dependencies, and uv.
# Everything is done in a single layer to minimize image size.
RUN dnf install -y --setopt=install_weak_deps=0 wget nano curl python3 python3-pip \
    && dnf clean all \
    && curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv's installation directory to the system's PATH so it's available
# to subsequent build stages or containers.
# The install script places the binary in /root/.local/bin by default.
ENV PATH="/root/.local/bin:${PATH}"

# --- Dependency Layer ---
# First, copy only the requirements file.
COPY requirements.txt ./

# Install the Python dependencies using uv. This layer is now cached.
# It will only be rebuilt if requirements.txt changes.
RUN uv pip install --no-cache -r requirements.txt