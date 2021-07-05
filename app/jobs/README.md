# Jobs

This directory contains background jobs used by Danbooru. Jobs are used to
handle slow-running tasks that need to run in the background, such as processing
uploads or bulk update requests. They're also used for asynchronous tasks, such
as sending emails, that may temporarily fail but can be automatically retried
later.

Jobs use the Rails Active Job framework. Active Job is a common framework that
allows jobs to be run on different job runner backends.

In the production environment, jobs are run using the Delayed Job backend.  Jobs
are stored in the database in the `delayed_job` table. Worker processes spawned
by `bin/delayed_job` poll the table for new jobs to work.

In the development environment, jobs are run with an in-process thread pool.
This will run jobs in the background, but will drop jobs when the server is
restarted.

There are two job queues, the `default` queue and the `bulk_update`. The
`bulk_update` queue handles bulk update requests. It has only one worker so that
bulk update requests are effectively processed sequentially. The `default` queue
handles everything else.

There is a very minimal admin dashboard for jobs at https://danbooru.donmai.us/delayed_jobs.

Danbooru also has periodic maintenance tasks that run in the background as cron
jobs. These are different from the jobs in this directory. See [app/logical/danbooru_maintenance.rb](../logical/danbooru_maintenance.rb).

# Usage

Start a pool of job workers:

```
RAILS_ENV=production bin/delayed_job --pool=default:8 --pool=bulk_update start
```

# Examples

Spawn a job to be worked in the background. It will be worked as soon as a
worker is available:

```ruby
DeleteFavoritesJob.perform_later(user)
```

# See also

* [app/logical/danbooru_maintenance.rb](../logical/danbooru_maintenance.rb)
* [app/controllers/delayed_jobs_controller.rb](../controllers/delayed_jobs_controller.rb)
* [config/initializers/delayed_jobs.rb](../../config/initializers/delayed_jobs.rb)
* [test/jobs](../../test/jobs)

# External links

* https://guides.rubyonrails.org/active_job_basics.html
* https://github.com/collectiveidea/delayed_job
* https://danbooru.donmai.us/delayed_jobs