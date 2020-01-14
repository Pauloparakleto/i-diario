class RemoveDuplicatedDailyFrequencies < ActiveRecord::Migration
  def change
    daily_frequencies = DailyFrequency.joins(:classroom).group(
      :classroom_id, :frequency_date, :discipline_id, :class_number
    ).where.not(
      classrooms: { period: Periods::FULL }
    ).having(
      'COUNT(1) > 1'
    ).pluck(
      'MAX(daily_frequencies.id)', :classroom_id, :frequency_date, :discipline_id, :class_number
    )

    daily_frequencies.each do |correct_id, classroom_id, frequency_date, discipline_id, class_number|
      DailyFrequencyStudent.where.not(daily_frequency_id: correct_id).delete_all

      DailyFrequency.where(classroom_id: classroom_id, frequency_date: frequency_date)
                    .where(<<-SQL, discipline_id, class_number)
                        COALESCE(discipline_id, 0) = COALESCE(?, 0) AND
                        COALESCE(class_number, 0) = COALESCE(?, 0)
                    SQL
                    .where.not(id: correct_id)
                    .delete_all
    end
  end
end
