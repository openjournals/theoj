# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.destroy_all
Paper.destroy_all

users = []
users << User.create(uid: 1, name: "stuart", extra: "blah blah", picture: "https://pbs.twimg.com/profile_images/2392941891/anq5bkkx8rtdhn8p2i9m_bigger.png")
users << User.create(uid: 2, name: "arfon", extra: "blah blah", picture: "https://pbs.twimg.com/profile_images/2392941891/anq5bkkx8rtdhn8p2i9m_bigger.png")


10.times do |no|
  Paper.create( submitted_at: DateTime.now, title: "Paper no #{no}", location:"http://arxiv.org/abs/1405.103#{1+no}",user_id: users.sample.id )
end
