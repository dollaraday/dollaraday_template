namespace :controller do

  desc "Output a list of each controller's filters (CONTROLLER=ClassName for specific controller)."
  task :filters => %w(environment) do
    # Development mode has autoload turned on, so specifically require each controller,
    Dir.new(Rails.root.join("app", "controllers")).entries.each do |c|
      path = Rails.root.join("app", "controllers", c)
      require path unless File.directory?(path)
    end
    Dir.new(Rails.root.join("app", "controllers", "admin")).entries.each do |c|
      path = Rails.root.join("app", "controllers", "admin", c)
      require path unless File.directory?(path)
    end

    output_filter = ->(f) do
      puts "    #{f.filter} #{" -- " + (f.raw_filter.source_location || f.raw_filter.class).to_s if f.filter =~ /^_callback_/}"
      f.options.slice(:except,:unless,:only,:if).each_pair do |k,v|
        puts "      #{k} => #{v.inspect}" unless v.blank?
      end
    end

    output_all_filters = ->(klass) do
      puts klass.to_s

      befores = klass._process_action_callbacks.find_all { |c| c.kind == :before }
      unless befores.blank?
        puts "  Before:"
        befores.each(&output_filter)
      end

      arounds = klass._process_action_callbacks.find_all { |c| c.kind == :around }
      unless arounds.blank?
        puts "  Around:"
        arounds.each(&output_filter)
      end

      afters = klass._process_action_callbacks.find_all { |c| c.kind == :after }
      unless afters.blank?
        puts "  After:"
        afters.each(&output_filter)
      end
    end

    if ENV['CONTROLLER']
      output_all_filters.call(ENV['CONTROLLER'].constantize)
    else
      ApplicationController.descendants.each(&output_all_filters)
    end
  end
end

