
module Firebase

  # This needs to be synchronized with the polymer code for Oj.utils.clean_firebase_key

  # Added ~ since we use it as an escape, Also '/' but we don't worry about that
  INVALID_CHARS       = '~.$#[]'
  INVALID_CHARS_REGEX = /[#{Regexp.escape(INVALID_CHARS)}]/

  def self.clean_key(key)
    key.to_s.gsub(INVALID_CHARS_REGEX) { |c| "~#{c.ord.to_s(16)}" }
  end


end