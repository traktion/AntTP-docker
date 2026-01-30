# Build SafeNetwork Docker container (inspired by DeusNexus image)
FROM alpine:3.14
LABEL version="0.24.4"
LABEL maintainer="Traktion"
LABEL release-date="2026-01-30"

# Update and install dependencies
RUN apk update
RUN apk add bash #unix shell to run install script
RUN apk add curl #cUrl to transfer data

RUN addgroup -S safe && adduser -S safe -G safe
USER safe:safe
WORKDIR /home/safe

#Make profile file with exported PATH and refresh the shell (while building)
SHELL ["/bin/bash", "--login", "-c"]
RUN echo 'export PATH=$PATH:/home/safe/.local/bin' > ~/.profile

#Set ENV PATH (after build will be used to find 'safe' and 'safenode')
ENV PATH=$PATH:/home/safe/.local/bin/

#Installation Script - MaidSafe installation script
RUN curl -sSL https://raw.githubusercontent.com/maidsafe/safeup/main/install.sh | bash

#Install anttp
COPY anttp/anttp /home/safe/.local/bin/anttp
COPY anttp/static /home/safe/static
COPY anttp/cache /home/safe/cache
COPY anttp/anttp_wrapper.sh /home/safe/.local/bin/anttp_wrapper.sh

USER root:root
RUN chown safe:safe /home/safe/cache
RUN chmod 777 /home/safe/cache
RUN chmod +x /home/safe/.local/bin/anttp
RUN chmod +x /home/safe/.local/bin/anttp_wrapper.sh
USER safe:safe

VOLUME ["/tmp"]

#todo: move cache to /tmp volume

ENTRYPOINT ["anttp_wrapper.sh"]
EXPOSE 8080
