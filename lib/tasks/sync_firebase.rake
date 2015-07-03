namespace :firebase do

  desc 'Clear objects in Firebase (this includes (dev, test & prod data)'
  task :clear => :environment do
    FirebaseClient.delete("/")
  end

  desc 'Update objects in Firebase (without removing old data)'
  task :update => :environment do
    Paper.all.each { |p| FirebaseClient.delete p.firebase_key }
    Annotation.root_annotations.each{|a| a.push_to_firebase}
  end

  # desc 'Clear and then update Firebase data'
  # task :sync => [:update, :clear]

end
