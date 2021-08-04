FROM ruby:3

ARG GID="1000"
ARG UID="1000"
RUN groupadd --gid ${GID} dev \
  && useradd --uid ${UID} --gid dev --shell /bin/bash --create-home dev
USER dev
ENV APP_ROOT /home/dev/trans-movie-bot
RUN mkdir -p ${APP_ROOT}
WORKDIR ${APP_ROOT}
RUN bundle config set path 'vendor/bundle'
