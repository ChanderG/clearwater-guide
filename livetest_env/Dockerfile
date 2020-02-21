FROM ruby:1.9.3
MAINTAINER chanderg

RUN mkdir /clearwater-live-test
ADD clearwater-live-test  /clearwater-live-test

RUN apt-get update
RUN apt-get install -y git

RUN cd clearwater-live-test; bundle install