namespace :ieducar_api do
  desc 'I-Educar API synchronization'
  task :synchronize, [:full_synchronization, :last_two_years] => :environment do |_task, args|
    args.with_defaults(
      full_synchronization: true,
      last_two_years: true
    )

    full_synchronization = ActiveRecord::Type::Boolean.new.type_cast_from_user(args.full_synchronization)
    last_two_years = ActiveRecord::Type::Boolean.new.type_cast_from_user(args.last_two_years)

    IeducarSynchronizerWorker.perform_async(nil, nil, full_synchronization, last_two_years)
  end

  desc 'Cancela envio de notas travados há 1 dia ou mais'
  task cancel: :environment do
    Entity.to_sync.each do |entity|
      entity.using_connection do
        postings = IeducarApiExamPosting.where(status: :started)
                                        .where('created_at < ?', 1.day.ago)

        postings.each do |posting|
          posting.add_error!(
            I18n.t('ieducar_api.error.messages.sync_error'),
            'Processo parado pelo sistema pois estava travado.'
          )
          posting.mark_as_error!
        end
      end
    end
  end
end
