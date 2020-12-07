task :schedule_check_ins => :environment do
  CheckInSchedulerJob.perform_later
end

# task :schedule_check_in_summary_job => :environment do
#   CheckInSummaryJob.perform_later
# end