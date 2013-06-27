#!/usr/bin/env ruby
require 'rubygems' # Unless you install from the tarball or zip.
basepath = File.dirname(__FILE__) + '/../../../../'
require basepath + 'config/boot'
require basepath + 'config/environment'
require 'date'
require 'active_support'

d = Date.yesterday
while d.strftime('%a') == 'Sat' || d.strftime('%a') == 'Sun' do
d = d-1
end

sql = "SELECT u.id, u.firstname, u.lastname, mail,(SELECT SUM(hours) FROM time_entries t WHERE t.user_id = u.id AND spent_on='#{d.strftime('%Y-%m-%d')}') AS hours FROM users u JOIN groups_users g ON g.user_id = u.id WHERE 
 g.group_id=480"

results = ActiveRecord::Base.connection.select_all( sql )

json = ActiveSupport::JSON

print json.encode( results )
