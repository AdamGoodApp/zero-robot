namespace :robot_setup do

  desc "Reset system to setup state"
  task :reset  => :environment do
    puts "Resetting Database"
    Rake::Task['db:reset'].invoke
  end

end