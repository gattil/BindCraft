FROM condaforge/miniforge3:latest
#FROM continuumio/miniconda3:latest
WORKDIR /app
COPY example/ example/
COPY functions/ functions/
COPY notebooks/ notebooks/
COPY settings_advanced/ settings_advanced/
COPY settings_filters/ settings_filters/
COPY settings_target/ settings_target/
COPY bindcraft.py .
#COPY install_bindcraft.sh .
#RUN chmod +x install_bindcraft.sh; bash ./install_bindcraft.sh --cuda '12.4' --pkg_manager 'conda'

ENV PARAMS_DIR="params"
ENV PARAMS_FILE="alphafold_params_2022-12-06.tar"
ENV CONDA_OVERRIDE_CUDA=12.4
##ENV CONDA_DEFAULT_ENV="BindCraft"
RUN conda info
RUN conda install -c conda-forge -c nvidia --channel https://conda.graylab.jhu.edu -y \
    python=3.10 \
    pip  \
    pandas  \
    matplotlib  \
    numpy"<2.0.0"  \
    biopython  \
    scipy  \
    pdbfixer  \
    seaborn  \
    libgfortran5  \
    tqdm  \
    jupyter  \
    ffmpeg  \
    pyrosetta  \
    fsspec  \
    py3dmol  \
    chex  \
    dm-haiku  \
    flax"<0.10.0"  \
    dm-tree  \
    joblib \
    ml-collections  \
    immutabledict  \
    optax  \
    jaxlib=*=*cuda*  \
    jax  \
    cuda-nvcc  \
    cudnn

RUN conda clean -a -y

  # install ColabDesign
RUN pip3 install git+https://github.com/sokrypton/ColabDesign.git --no-deps
RUN python -c "import colabdesign" >/dev/null 2>&1

# AlphaFold2 weights
RUN echo -e "Downloading AlphaFold2 model weights \n"
RUN mkdir -p "${PARAMS_DIR}" && wget -O "${PARAMS_DIR}/${PARAMS_FILE}" "https://storage.googleapis.com/alphafold/${PARAMS_FILE}" && [ -s "${PARAMS_DIR}/${PARAMS_FILE}" ]

# extract AF2 weights
RUN tar tf "${PARAMS_DIR}/${PARAMS_FILE}" >/dev/null 2>&1 &&  \
    tar -xvf "${PARAMS_DIR}/${PARAMS_FILE}" -C "${PARAMS_DIR}" &&  \
    [ -f "${PARAMS_DIR}/params_model_5_ptm.npz" ] &&  \
    rm "${PARAMS_DIR}/${PARAMS_FILE}"

# chmod executables
RUN chmod +x "functions/dssp" && chmod +x "functions/DAlphaBall.gcc"

