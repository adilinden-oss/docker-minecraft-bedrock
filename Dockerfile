FROM ubuntu:18.04

ENV BEDROCK_VERSION="1.14.60.5"
ARG BEDROCK_URL="https://minecraft.azureedge.net/bin-linux/bedrock-server-"

ENV BEDROCK_DATA="/bedrock-data"
ENV BEDROCK_INSTALL="/bedrock-install"

RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        ca-certificates \
        wget \
        curl \
        libcurl4 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${BEDROCK_DATA}

WORKDIR ${BEDROCK_INSTALL}
RUN wget -nv ${BEDROCK_URL}${BEDROCK_VERSION}.zip -O /tmp/bedrock.zip \
    && unzip -q /tmp/bedrock.zip -d /${BEDROCK_INSTALL} \
    && rm -f /tmp/bedrock.zip

WORKDIR /
COPY bedrock-entry.sh /bedrock-entry.sh

ENTRYPOINT ["/bin/bash", "/bedrock-entry.sh"]
CMD ["start_bedrock"]
