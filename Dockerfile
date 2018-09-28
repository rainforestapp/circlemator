FROM ruby:2.4.2-jessie
RUN apt-get update -y && apt-get install -y cmake

# Set default locale for Ruby to avoid encoding errors
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

WORKDIR /app
COPY . .
RUN bundle install
ENTRYPOINT ["circlemator"]
