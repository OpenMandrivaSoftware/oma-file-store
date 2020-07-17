FROM ruby:2.5.8-alpine3.11 as fstore-gems

WORKDIR /file_store
RUN apk add --no-cache libpq ca-certificates tzdata nodejs && apk add --virtual .ruby-builddeps --no-cache postgresql-dev build-base
RUN gem install bundler
RUN bundle config set clean 'true' && bundle config set deployment 'true' && \
    bundle config set without 'development test' && bundle config set no-cache 'true'
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 16
RUN apk del .ruby-builddeps && rm -rf /root/.bundle && rm -rf /file_store/vendor/bundle/ruby/2.5.0/cache

FROM scratch
COPY --from=fstore-gems / /

RUN touch /MIGRATE

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_APP_CONFIG /usr/local/bundle

ENV RAILS_ENV production
ENV DATABASE_URL postgresql://postgres@postgres/file-store

WORKDIR /file_store
COPY bin ./bin
COPY config ./config
COPY db ./db
COPY app/ ./app
COPY public ./public
COPY Rakefile config.ru entrypoint.sh ./
ENTRYPOINT ["/file_store/entrypoint.sh"]
