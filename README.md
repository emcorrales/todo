# README

A simple TODO API built using Ruby on Rails.

Setup
-----

Install depencies.
```bash
bundle install
```
Run migrations.
```bash
bundle exec rails db:migrate
```
Configuration
----
You need a **config/master.key**.
Maybe just delete and recreate **config/credentials.yml.enc**
```bash
rm config/credentials.yml.enc
```

then recreate the security credentials.
```bash
EDITOR=vim bin/rails credentials:edit
```


How to run the test suite
-----
Run all test except the performance test.
```bash
bundle exec rspec
```

Run performance test.
```bash
PERF=1 bundle exec rspec spec/requests/performance_spec.rb
```
