class DollarADayJob < Struct
  def self.new(*args)
    args << :noop if args.empty?
    super *args
  end

  def self.create(*args, options)
    new(*args).save(options)
  end

  def self.count
    Delayed::Job.count
  end

  def save(options={})
    Delayed::Job.enqueue(
      payload_object: self,
      queue: self.class.queue,
      priority: self.class.priority,
      run_at: options[:run_at]
    )
  end

  def self.priority; @priority || 3 end
  def self.queue; @queue || 'default' end
  def self.default_priority; @default_priority ||= 3 end
  def self.destroy_failed_jobs; false end
  def self.max_run_time; @max_run_time ||= 8.hours end
  def self.max_attempts; @max_attempts ||= 100 end
end

# Handy for the console
DJ = Delayed::Job
