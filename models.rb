require 'bundler/setup'
Bundler.require

if development?
    ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class Content < ActiveRecord::Base
    has_secure_password

    has_many :questions
end

class Question < ActiveRecord::Base
    belongs_to :content
end