class Stats

  METRICS = {
    total_donors: -> (start_time: nil, end_time: Date.yesterday.end_of_day) {
      Donor.where(
        'created_at <= ?', end_time
      ).count
    },

    total_new_donors: -> (start_time: Date.yesterday.beginning_of_day, end_time: Date.yesterday.end_of_day) {
      Donor.where(
        "created_at > ? AND created_at <= ?", start_time, end_time
      ).count
    },

    total_gifts: -> (start_time: nil, end_time: Date.yesterday.end_of_day) {
      Gift.where(
        "created_at <= ?", end_time
      ).count
    },

    total_new_gifts: -> (start_time: Date.yesterday.beginning_of_day, end_time: Date.yesterday.end_of_day) {
      Gift.where(
        "created_at > ? AND created_at <= ?", start_time, end_time
      ).count
    },

    total_gift_conversions: -> (start_time: nil, end_time: Date.yesterday.end_of_day) {
      Gift.converted.where(
        "created_at <= ?", end_time
      ).count
    },

    total_subscribers: -> (start_time: nil, end_time: Date.yesterday.end_of_day) {
      Subscriber.where(
        'subscribed_at <= ?', end_time
      ).where(unsubscribed_at: nil).count
    },

    total_new_subscribers: -> (start_time: Date.yesterday.beginning_of_day, end_time: Date.yesterday.end_of_day) {
      Subscriber.where(
        'subscribed_at > ? AND subscribed_at <= ?', start_time, end_time
      ).where(unsubscribed_at: nil).count
    },

    total_unsubscribers: -> (start_time: nil, end_time: Date.yesterday.end_of_day) {
      Subscriber.where(
        'unsubscribed_at <= ?', end_time
      ).count
    },

    total_new_unsubscribers: -> (start_time: Date.yesterday.beginning_of_day, end_time: Date.yesterday.end_of_day) {
      Subscriber.where(
        "unsubscribed_at > ? AND unsubscribed_at <= ?", start_time, end_time
      ).count
    },

    total_cancelled_donors: -> (start_time: nil, end_time: Date.yesterday.end_of_day) {
      Donor.where(
        'cancelled_at <= ?', end_time
      ).count
    },

    total_new_cancelled_donors: -> (start_time: Date.yesterday.beginning_of_day, end_time: Date.yesterday.end_of_day) {
      Donor.where(
        "cancelled_at > ? AND cancelled_at <= ?", start_time, end_time
      ).count
    },

    total_uncancelled_donors: -> (start_time: nil, end_time: Date.yesterday.end_of_day) {
      Donor.where(
        "uncancelled_at <= ?", end_time
      ).where.not(uncancelled_at: nil).count
    },

    total_new_uncancelled_donors: -> (start_time: Date.yesterday.beginning_of_day, end_time: Date.yesterday.end_of_day) {
      Donor.where(
        "uncancelled_at > ? AND uncancelled_at <= ?", start_time, end_time
      ).count
    }
  }

  def self.persist
    METRICS.each do |name, block|
      Metric.create(key: name, value: block.call)
    end
  end

  def initialize(options = {})
    @options = options.with_indifferent_access
  end

  def collection
    hash = {}.with_indifferent_access

    metrics = Metric.where(
      'created_at >= ? AND created_at <= ?', start_date.beginning_of_day, end_date.end_of_day
    ).group_by {|metric|
      metric.created_at.to_date.to_s
    }

    dates.each_with_index do |date, i|
      METRICS.keys.each do |name|
        (hash[name] ||= [])[i] = [ date.beginning_of_day.to_i * 1000, 0 ]
      end

      if day_metrics = metrics[date.to_s]
        day_metrics.each do |metric|
          hash[metric.key][i] = [ date.beginning_of_day.to_i * 1000, metric.value ]
        end
      end
    end

    hash
  end

  def dates
    start_date..end_date
  end

  def start_date
    @start_date ||= Date.parse(
      options.fetch(:start_date, 30.days.ago.to_date.to_s)
    )
  end

  def end_date
    @end_date ||= Date.parse(
      options.fetch(:end_date, Date.today.to_s)
    )
  end

  protected

  attr_reader :options

end
