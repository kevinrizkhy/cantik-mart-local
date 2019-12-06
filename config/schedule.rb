env :PATH, ENV['PATH']
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :environment, 'development'
# set :output, "log/cron.log"
#

every 30.minutes do
	puts "START: " + DateTime.now.to_s
  runner "SyncData.sync_now"
  	puts "END: " + DateTime.now.to_s
  	puts "-----------------------------"

end
#