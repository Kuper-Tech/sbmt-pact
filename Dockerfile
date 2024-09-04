ARG RUBY_VERSION

FROM ruby:$RUBY_VERSION

ARG BUNDLER_VERSION
ARG RUBYGEMS_VERSION

ENV BUNDLE_JOBS=4 \
  BUNDLE_RETRY=3

RUN gem update --system "${RUBYGEMS_VERSION}" \
  && rm /usr/local/lib/ruby/gems/*/specifications/default/bundler*.gemspec \
  && gem install --default bundler:${BUNDLER_VERSION} \
  && gem install bundler -v ${BUNDLER_VERSION}
