# This seed file is good for resetting development environments.

throw "Sure you want to empty the database?" if Rails.env.production?

# CLEAR DATABASE
ActiveRecord::Base.establish_connection
ActiveRecord::Base.connection.tables.each do |table|
  unless table == "schema_migrations"
    ActiveRecord::Base.connection.execute("TRUNCATE #{table};")
  end
end

User.create!(name: "John Doe", :email => "johndoe@***.com", :password => "password", :is_admin => true)

LOREM_IPSUM = "LOREM_IPSUM, ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse non neque id elit laoreet consequat ut sed libero. Nulla aliquam nisl vestibulum neque vehicula nec mollis elit iaculis. Quisque id arcu vel metus venenatis sollicitudin. Etiam a purus eu felis congue feugiat eget bibendum lectus. Maecenas magna risus, luctus vel pharetra eget, gravida sed mi. Integer non sapien vel lacus pharetra tempus. Integer tellus LOREM_IPSUM, is_public: true, iaculis et iaculis vitae, tempus id purus. Etiam fringilla orci quis turpis tincidunt pretium ultrices est mattis. Phasellus accumsan sollicitudin ornare."

Nonprofit.create!(ein: "55-5555555", blurb: "...", featured_on: Time.now.to_date, name: "Nonprofit #1", description: LOREM_IPSUM, is_public: true)
Nonprofit.create!(ein: "56-5555555", blurb: "...", featured_on: 1.day.from_now.to_date, name: "Nonprofit #2", description: LOREM_IPSUM, is_public: true)
Nonprofit.create!(ein: "57-5555555", blurb: "...", featured_on: 2.day.from_now.to_date, name: "Nonprofit #3", description: LOREM_IPSUM, is_public: true)
