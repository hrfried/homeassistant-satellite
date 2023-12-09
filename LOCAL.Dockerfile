# dev: docker build . -t homeassistant_satellite && docker run --rm -ti homeassistant_satellite:latest --host <HOST> --token <TOKEN>
FROM python:3.11-bookworm

LABEL org.opencontainers.image.title homeassistant-satellite
LABEL org.opencontainers.image.licenses MIT
LABEL org.opencontainers.image.source https://github.com/synesthesiam/homeassistant-satellite

WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get install --no-install-recommends -y ffmpeg alsa-utils && \
    apt-get autoclean -y && \
    apt-get autopurge -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/log/apt/* /var/log/dpkg.log

COPY requirements_extra.txt requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY ./ ./

RUN pip install --no-cache-dir .[webrtc]

# silerovad can not be build on armv7l
RUN uname -m | grep armv7l || pip install --no-cache-dir --find-links https://synesthesiam.github.io/prebuilt-apps/ .[silerovad]

#******************************
#Holden adds 2023-12-09
#******************************
RUN apt install libpulse0
RUN pip install .[pulseaudio]
#RUN pip install --find-links https://synesthesiam.github.io/prebuilt-apps/ .[silverovad]
RUN pip install .[wyoming]
#COPY secrets/token.txt ./
#******************************
#End
#******************************

ENTRYPOINT [ "python", "-m", "homeassistant_satellite" ]
