namespace :firebase do
  desc "TODO"
  task :sync => :environment do
    FirebaseClient.delete("/")
    Annotation.root_annotations.each{|a| a.push_to_firebase}
  end
end
