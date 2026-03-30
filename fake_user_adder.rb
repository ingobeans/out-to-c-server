# RUN WITH: rails r fake_user_adder.rb
#
# helper script for easily creating fake users for the database

def prompt(*args)
    print(*args)
    gets.chomp
end

puts "hi!! welcome to the user adder script! lets get started!\n"

uid = prompt("enter a uid that you will use to log in with: ")
name = prompt("enter a username: ")
pfp = prompt("enter a profile picture url (optional): ")

User.new({ uid: uid, name: name, pfp: pfp }).save()

puts "done!!"
