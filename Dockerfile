FROM condaforge/miniforge3:latest
WORKDIR /app
COPY ./* .
RUN chmod +x install_bindcraft.sh; bash ./install_bindcraft.sh --cuda '12.4' --pkg_manager 'mamba'
