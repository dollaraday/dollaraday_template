class PersistStatsJob < DollarADayJob.new(:options)
  @priority = 5
  @queue    = 'default'

  def perform
    Stats.persist
  end
end
