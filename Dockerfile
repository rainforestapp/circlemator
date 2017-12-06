FROM ruby:2.4.2-jessie
RUN apt-get update -y && apt-get install -y cmake
WORKDIR /app
COPY . .
RUN bundle install
ENTRYPOINT ["circlemator"]
