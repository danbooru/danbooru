# Jobs

This directory contains background jobs used by Danbooru. Jobs are used to
handle slow-running tasks that need to run in the background, such as processing
uploads or bulk update requests. They're also used for asynchronous tasks, such
as sending emails, that may temporarily fail but can be automatically retried
later.

Jobs use the Rails Active Job framework. Active Job is a common framework that
allows jobs to be run on different job runner backends.

In the production environment, jobs are run using the Good Job backend.  Jobs
are stored in the database in the `good_jobs` table. Worker processes spawned
by `bin/good_job` poll the table for new jobs to work.

In the development environment, jobs are run with an in-process thread pool.
This will run jobs in the background, but will drop jobs when the server is
restarted.

There is a very minimal admin dashboard for jobs at https://danbooru.donmai.us/jobs.

Danbooru also has periodic maintenance tasks that run in the background as cron
jobs. These are different from the jobs in this directory. See
[app/logical/danbooru_maintenance.rb](../logical/danbooru_maintenance.rb).

# Usage

Start a pool of job workers:

```
RAILS_ENV=production bin/good_job start --max-threads=4
```

# Examples

Spawn a job to be worked in the background. It will be worked as soon as a
worker is available:

```ruby
DeleteFavoritesJob.perform_later(user)
```

# See also

* [app/logical/danbooru_maintenance.rb](../logical/danbooru_maintenance.rb)
* [app/controllers/jobs_controller.rb](../controllers/jobs_controller.rb)
* [config/initializers/good_job.rb](../../config/initializers/good_job.rb)
* [test/jobs](../../test/jobs)

# External links

* https://guides.rubyonrails.org/active_job_basics.html
* https://github.com/bensheldon/good_job
* https://danbooru.donmai.us/jobs
