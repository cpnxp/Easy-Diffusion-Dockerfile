FROM debian:bookworm

LABEL Author="CPNXP"

ENV EASYDIFFUSION_VERSION=v3.0.9

RUN apt-get update && apt-get install -y \
	ca-certificates \
	curl \
	python3 \
	unzip \
	libgl1 \
	libglib2.0-0 \
	bzip2 \
	entr \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir /opt/easy-diffusion/ \
	&& mkdir /opt/easy-diffusion/models/ \
	&& mkdir /opt/easy-diffusion/output/ \
	&& mkdir /opt/easy-diffusion/config-backup/

ADD "https://github.com/easydiffusion/easydiffusion/releases/download/${EASYDIFFUSION_VERSION}/Easy-Diffusion-Linux.zip" /opt
COPY ./config.yaml /opt/easy-diffusion/
COPY ./docker-entrypoint.sh /usr/local/bin/

ENV HOME=/home/eduser

RUN useradd --create-home --home-dir $HOME eduser \
	&& chown -R eduser:eduser $HOME \
	&& chown -R eduser:eduser /opt \
	&& chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR $HOME
USER eduser

ENV LANG=C.UTF-8

RUN cd /opt \
    && unzip /opt/Easy-Diffusion-Linux.zip -d /opt \
	&& rm /opt/Easy-Diffusion-Linux.zip \
	&& cd /opt/easy-diffusion \
	&& sed -i '$d' ./scripts/on_env_start.sh \
	&& bash start.sh

ENV PATH="/opt/easy-diffusion/installer_files/env/bin:$PATH"
ENV PYTHONNOUSERSITE=y
ENV PYTHONPATH=/opt/easy-diffusion/installer_files/env/lib/python3.8/site-packages:/opt/easy-diffusion/stable-diffusion/env/lib/python3.8/site-packages
ENV update_branch="main"

RUN cd /opt/easy-diffusion \
	&& sed -i '$d' ./scripts/on_sd_start.sh \
	&& sed -i 's/python scripts\/check_modules.py --launch-uvicorn/python scripts\/check_modules.py/g' /opt/easy-diffusion/scripts/on_sd_start.sh \
	&& bash ./scripts/on_sd_start.sh \
	&& cp ./sd-ui-files/scripts/on_sd_start.sh ./scripts/ \
	&& python -m pip install --upgrade torch==2.0.1+cu118 torchvision==0.15.2+cu118 xformers==0.0.22 --extra-index-url https://download.pytorch.org/whl/cu118

VOLUME /opt/easy-diffusion/models
VOLUME /opt/easy-diffusion/config-backup
VOLUME /opt/easy-diffusion/output

EXPOSE 9000/tcp

ENTRYPOINT ["docker-entrypoint.sh","/opt/easy-diffusion/start.sh"]