FROM ruby:2.6.3
RUN apt-get update -y && apt-get install -y cmake

# Set default locale for Ruby to avoid encoding errors
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /app

RUN gem update --system
RUN gem install bundler:1.17.2

COPY . .
RUN bundle install

ENTRYPOINT ["bundle exec circlemator"]
