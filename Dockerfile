FROM alpine:3.14
ENV TRYTON_DATABASE=health
ENV POSTGRES_HOSTNAME=db
ENV GNUHEALTH_VERSION=3.8.0
RUN apk add --no-cache bash freetype tesseract-ocr python3 py3-numpy py3-pip py3-defusedxml jpeg-dev libarchive-tools && \
    pip3 install --upgrade pip setuptools wheel && \
    apk add --no-cache --virtual .build-deps pkgconfig libxml2-dev libxslt-dev python3-dev postgresql-dev gcc g++ zlib-dev make python3-dev py3-numpy-dev libpng-dev jpeg-dev freetype-dev musl-dev linux-headers libffi-dev patch
RUN adduser -D gnuhealth
SHELL ["/bin/bash", "-c"]
USER gnuhealth
WORKDIR /home/gnuhealth
RUN wget https://ftp.gnu.org/gnu/health/gnuhealth-${GNUHEALTH_VERSION}.tar.gz && tar xzf gnuhealth-${GNUHEALTH_VERSION}.tar.gz
WORKDIR gnuhealth-${GNUHEALTH_VERSION}/
RUN sed -i "s/\/localhost/\/${POSTGRES_HOSTNAME}/g" config/trytond.conf
RUN sed -i "s/ln \-si/ln -s/g" gnuhealth-setup
RUN bash ./gnuhealth-setup install
USER root
RUN apk del .build-deps
USER gnuhealth
WORKDIR /home/gnuhealth
ENTRYPOINT bash -ic 'sleep 5; source .gnuhealthrc; cdexe && python3 ./trytond-admin --all --database=${TRYTON_DATABASE}' && ./start_gnuhealth.sh