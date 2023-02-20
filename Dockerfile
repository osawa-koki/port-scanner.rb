FROM ruby:3.2.1
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install
COPY ./app ./app
CMD ["ruby", "./app/main.rb"]
