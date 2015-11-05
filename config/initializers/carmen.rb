# Cacheing these arrays here... better place to put it?
CARMEN_COUNTRY_OPTIONS = ::Carmen::Country.all.sort_by(&:name).map { |c| [c.name, c.code] }
