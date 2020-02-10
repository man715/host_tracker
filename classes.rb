require 'data_mapper'
require 'dm-migrations'


# Initialize the Master DB
DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db/master.db")

class ManagedHosts
  include DataMapper::Resource

  property :id, Serial
  property :report_id, String, length: 30
  property :ip, String
  property :hostname, String
  property :os, String
  property :port, String
  property :findings, String, length: 400
  property :admin_accounts, String
  property :other_accounts, String
  property :discovered, String
  property :other_notes, String, length: 400
end

DataMapper.finalize

DataMapper.auto_upgrade!
