firebase_prefix = ENV['FIREBASE_PREFIX'] || Rails.env
firebase_prefix += '/' unless firebase_prefix.ends_with?('/')
Rails.configuration.firebase_uri_prefix = "https://theoj.firebaseio.com/#{firebase_prefix}"

FirebaseClient = Firebase::Client.new( Rails.configuration.firebase_uri_prefix )
