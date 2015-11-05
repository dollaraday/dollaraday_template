class String

  # Stupid simple way to split a name
  # EX: "James Von Something".split_name -> ["James", "Von Something"]
  def split_name
    first, last = self.split(' ', 2)
  end

  # Gets the given name, or full name if starts with GIVEN_NAME_PREFIXES
  GIVEN_NAME_PREFIXES = %w(The A An)
  def given_name
    return self if self.blank?
    names = self.squish.split(" ")
    if names.size <= 1 || names.first.in?(GIVEN_NAME_PREFIXES)
      return self.squish
    else
      return names.first
    end
  end

  POSSESSIVE_APPOSTROPHE = "’"
  def possessive
    self + ("s" == self[-1,1] ? POSSESSIVE_APPOSTROPHE : POSSESSIVE_APPOSTROPHE+"s")
  end

  # Upcase the first letter, but leave others untouched
  def namecase
    self.slice(0,1).upcase + self.slice(1..-1)
  end

end
