require 'queue/ScheduledQueue'

Rails.application.config.active_job.queue_adapter =
  ActiveJob::QueueAdapters::ScheduledQueue.new min_threads: 1 do
    schedule :deserialize, every: 0.3.second
    schedule :cache, every: 1.second
  end
