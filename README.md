# Traxor [![CircleCI](https://circleci.com/gh/ketiko/traxor.svg?style=svg&circle-token=fd1e0d401eda8de60d31ca3dbb5fb066a71a9b9f)](https://circleci.com/gh/ketiko/traxor) [![Build Status](https://travis-ci.org/ketiko/traxor.svg?branch=master)](https://travis-ci.org/ketiko/traxor) [![Maintainability](https://api.codeclimate.com/v1/badges/d812a63d184fb6c88dbd/maintainability)](https://codeclimate.com/github/ketiko/traxor/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/d812a63d184fb6c88dbd/test_coverage)](https://codeclimate.com/github/ketiko/traxor/test_coverage) [![Gem Version](https://badge.fury.io/rb/traxor.svg)](https://badge.fury.io/rb/traxor)

A tool for logging ruby application performance metrics to the [Akkeris](https://github.com/akkeris) platform.

Supported Gems:

 - Rack
 - Sidekiq
 - Faraday
 - ActionController
 - ActionMailer
 - ActiveRecord
 - Rails

How does this help me?

It logs things that help you troubleshoot performance issues.  Just some of the things it can help with:

 - How much time is spent in rack middleware?
 - Are requests getting backed up in the [queue](https://devcenter.heroku.com/articles/http-routing#heroku-headers)
 - How many ActiveRecord models are loaded in a request?
 - Which sidekiq jobs are the slowest?
 - How much time is being spent in calls to external services?
 - How much time is being spent in garbage collection?
 - How many objects are being loaded into memory on a request?

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'traxor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install traxor

## Usage

If you are running a rails application, just include the gem and nothing else is required.
It will automagically set everything up.  Including the gem wires up a Rails initializer to setup Traxor for you.

Akkeris records metrics by reading them from the logs on `STDOUT`.  This can get verbose in development, so when the rails
env is development or test, they are written to `./log/traxor.log`.

To record your own metrics you can use:

```
tags = { company: 'Company Name' }
Traxor::Metric.measure('duration', '10ms', tags)
Traxor::Metric.sample('memory', 500, tags)
Traxor::Metric.count('requests', 20, tags)
```

Traxor also supports recording tags for your metrics as the final argument.

We recommend using a leading prefix for all your metrics so they don't collide with others.

Metric names we be lower cased and underscored.  Namespaces in class names will be replaced with a period.

IE:

```
module Animals
  module FlyingBird; end
end

Traxor.count(Animals::FlyingBird, 1)

Ouputs:

'count#animals.flying_bird=1'
```

### Metrics Recorded:

All measure metrics are recorded in milliseconds.  All count metrics are whole numbers.

#### Rails

Traxor records a number of metrics using [Rail Instrumentation](http://guides.rubyonrails.org/active_support_instrumentation.html).
It will also insert a rack middleware at the start of the request and another at the end right before your application code is run.
This allows us to calculate how much time was spent in the rack middleware outside of your ActionController action.

Tags:

Traxor will track and log the controller name, action, and http method as tags on each request for you:

```
tags = { controller_name: 'MyController', controller_action: 'index', controller_method: :GET }
```

These tags will be applied to any metrics recorded during that request.  So ActiveRecord metrics will
also have these tags if it occurs during the request.

Rails request:

```
count#rails.action_controller.count <- increment request count of controller action
measure#rails.action_controller.total_duration <- total duration of request inside controller action
measure#rails.action_controller.ruby.duration <- duration of time not spent in the view or db in the controller action
measure#rails.action_controller.db.duration <- duration of time spend in the db
measure#rails.action_controller.view.duration <- duration of time spend in the view layer
count#rails.action_controller.exception.count <- increment exceptions count
```

Rack request:

```
measure#rack.request.middleware.duration <- time spent in middleware outside of your rack application
measure.rack.request.duration <- total duration of the request
measure.rack.request.queue.duration <- duration of time spent from when your router received the request before your application started to process it
count.rack.request.count <- increment rack request count
```

Note that the request queue time will read the `X-Request-Start` header in the request and calculate the number.
This is optional and does not have to be set. See [request queue server configuration examples](https://docs.newrelic.com/docs/apm/applications-menu/features/request-queue-server-configuration-examples)
for examples of how to configure this in your router.

GC During a Rack request:

```
measure#ruby.gc.duration <- total time spent in garage collection in a rack request
count#ruby.gc.count <- total number of gc runs during a rack request
count#ruby.gc.major.count <- total major gc runs during a rack request
count#ruby.gc.minor.count <- total minor gc runs during a rack request
count# ruby.gc.allocated_objects.count <- total number of new objects loaded into memory during a rack request
```

Note that the GC metrics are recorded by taking a sample before and after the request then calculating the delata.
As GC stats are per process, it is not a completely accurate way of recording things strictly during that request.
Other requests are also happening and throwing off these numbers.  But it should help to give you an idea.

We also enable the `GC::Profiler` which does have a performance cost.  In the future we could make this configurable.

ActiveRecord:

```
count#rails.action_record.statements.count tag#active_record_class_name=user <- total number of sql statements run tagged by active_record_class_name
count#rails.action_record.statements.select.count tag#active_record_class_name=user <- total number of select statements run tagged by active_record_class_name
count#rails.action_record.statements.insert.count tag#active_record_class_name=user <- total number of insert statements run tagged by active_record_class_name
count#rails.action_record.statements.update.count tag#active_record_class_name=user <- total number of update statements run tagged by active_record_class_name
count#rails.action_record.statements.delete.count tag#active_record_class_name=user <- total number of delete statements run tagged by active_record_class_name
count#rails.action_record.instantiation.count tag#active_record_class_name=user <- total number of ActiveRecord objects loaded from the db tagged by active_record_class_name
```

Note that these metrics will automatically be tagged with ActionController or Sidekiq tags if run during a request or worker.

ActionMailer:

```
count#rails.action_mailer.sent.count tag#mailer=user_mailer <- number of emails sent tagged by mailer name
```

Faraday:

To instrument requests to other sites include the [instrumentation middleware](https://github.com/lostisland/faraday_middleware/wiki/Instrumentation).

```
count#faraday.request.count tag#faraday_host=www.google.com tag#farday_method=get <- increment the request count tagged with host and method
measure#faraday.request.duration tag#faraday_host=www.google.com tag#farday_method=get <- duration of request tagged with host and method
```

Sidekiq:

```
measure#sidekiq.worker.duration tag#sidekiq_worker=my_worker tag#sidekiq_queue=default <- duration worker ran for tagged by sidekiq_worker and sidekiq_queue
count#sidekiq.worker.cout tag#sidekiq_worker=my_worker tag#sidekiq_queue=default <- increment worker count tagged by sidekiq_worker and sidekiq_queue
count#sidekiq.worker.exception.count tag#sidekiq_worker=my_worker tag#sidekiq_queue=default <- increment exception count tagged by sidekiq_worker and sidekiq_queue
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ketiko/traxor.
