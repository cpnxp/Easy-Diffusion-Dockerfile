# Easy-Diffusion-Dockerfile
Dockerfile for Easy-Diffusion with volume support for models, output and config backup

This is just the containerization of Easy-Diffusion please see: https://github.com/easydiffusion/easydiffusion for the original project.

I am not affiliated with Easy-Diffusion

I created this container so I could have all of my AI workloads running containerized in my homelab.

## Requirements
You need to have your docker environment setup for GPU use.

## Building
From inside the git project run the following command
```shell
docker build -t your/taghere .
```

## Usage
Deploy the container using a command similar to this one, I have not pushed this to docker hub
```shell
docker run -d -v ed-models:/opt/easy-diffusion/models -v ed-config:/opt/easy-diffusion/config-backup -v ed-output:/opt/easy-diffusion/output -p 9000:9000 --gpus=all --name easy-diffusion --restart always your/taghere
```
You can customize the config.yaml for your use before building the container or pre-populate the ed-config volume with your config.yaml

Due to the way the installer / start.sh works, stopping and restarting the container will trigger a check for updates so be aware 
the app may update within the container on a container restart.  This shouldn't pose any issues unless the installer process changes.
