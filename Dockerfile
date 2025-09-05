# Use the specified NVIDIA CUDA image based on UBI 9
FROM nvcr.io/nvidia/cuda:12.9.1-devel-ubi9

# Install system dependencies, upgrade Python to 3.12, and then install uv.
# We clean up the dnf cache in the same layer to minimize image size.
RUN dnf install -y --setopt=install_weak_deps=0 \
        libcudnn9-cuda-12 \
        python3.12 \
        python3.12-devel \
        python3.12-pip \
        wget \
        nano \
    && dnf clean all \
    # Update symlinks to make python3.12 the default python and python3
    && ln -sf /usr/bin/python3.12 /usr/bin/python \
    && ln -sf /usr/bin/python3.12 /usr/bin/python3 \
    # Install the uv installer
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    # Verify the python version
    && python --version

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
# uv will now use the Python 3.12 environment we installed.
RUN uv pip install --no-cache --system -r requirements.txt --extra-index-url https://pypi.nvidia.com