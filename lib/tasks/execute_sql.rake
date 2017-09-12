namespace :execute_sql do
  desc 'Execute select to return result'
  task :select, [:select] => :environment do |t, args|
    args.with_defaults(select: 'select * from users')

    Entity.all.each do |entity|
      entity.using_connection do
        ActiveRecord::Base.connection.select_rows(args[:select]).each do |item|
          puts entity.id.to_s + "-" + entity.name + ": " + item.join(' - ')
        end
      end
    end
  end
end
