# The page has one admin user only

puts "** Cleaning the database **"

Message.delete_all
Chatroom.delete_all
User.delete_all

puts "** Creating admin **"

admin = User.new(
  email: "admin@admin.com",
  password: "rmKv*ysa^5wvvYUdeax2HFP4&Qq@W^bCgE&jkeBBYSDrzxe!Yw"
)
admin.save!

puts "** Created user: admin **"
