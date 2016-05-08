# FROM ruby:2.3.1
# RUN mkdir /website
# ADD ./

FROM ubuntu:latest
# update packages
RUN apt-get update
RUN apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

# Expose port 3000 (Ruby app server)
EXPOSE 3000

# install rbenv
RUN git clone git://github.com/sstephenson/rbenv.git /.rbenv

# install rbenv plugins
RUN git clone git://github.com/sstephenson/ruby-build.git /.rbenv/plugins/ruby-build

# setup rbenv PATH
ENV PATH="/root/.rbenv/shims:/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH"
# RUN export PATH="/root/.rbenv/shims:/.rbenv/bin:/.rbenv/plugins/ruby-build/bin:$PATH"

# run rbenv at least once.
RUN eval "$(rbenv init -)"

# install Ruby
RUN rbenv install -v 2.3.1
RUN rbenv global 2.3.1

# init Ruby profile - doesn't work.
RUN touch /etc/profile.d/01-rbenv.sh
RUN chmod +x /etc/profile.d/01-rbenv.sh
RUN echo 'export PATH="/root/.rbenv/shims:/.rbenv/bin:/.rbenv/plugins/ruby-build/bin:$PATH"' >> /etc/profile.d/01-rbenv.sh
RUN echo 'eval "$(rbenv init -)"' >> /etc/profile.d/01-rbenv.sh

# install bundler
RUN gem install bundler --no-ri --no-rdoc

# install application
RUN mkdir /website
ADD ./ /website
RUN cd /website
WORKDIR /website
RUN bundle install

# command to run Ruby application
CMD ["/website/website"]
