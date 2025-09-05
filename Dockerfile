# Use the specified NVIDIA CUDA image based on UBI 9
FROM nvcr.io/nvidia/cuda:12.9.1-devel-ubi9

# Install system dependencies and then install uv.
# We also create a symlink for python -> python3.
# We clean up the dnf cache in the same layer to minimize image size.
RUN dnf install -y --setopt=install_weak_deps=0 wget nano \
    && dnf clean all \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv's installation directory to the system's PATH
# The install script places the binary in /root/.local/bin by default in this environment.
ENV PATH="/root/.local/bin:${PATH}"

# Set the working directory inside the container
WORKDIR /app

# --- Dependency Layer ---
# First, copy only the requirements file.
COPY requirements.txt ./

# Install the Python dependencies using uv. This layer is now cached.
# It will only be rebuilt if requirements.txt changes.
RUN uv pip install --no-cache --system -r requirements.txt