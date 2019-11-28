module ColumnsLockable
  extend ActiveSupport::Concern

  attr_accessor :current_user, :not_validate_columns, :validation_type

  included do
    validate :can_update?, on: :update
  end

  module ClassMethods
    attr_reader :not_updatable_columns

    private

    def not_updatable(columns)
      @not_updatable_columns = [columns[:only]].flatten
    end
  end

  private

  def can_update?
    return if validation_type == :destroy || not_validate_columns

    self.class.not_updatable_columns.each do |not_updatable_column|
      next if self.send(not_updatable_column) == current_user.send("current_#{not_updatable_column}")

      errors.add(not_updatable_column, :not_selected_in_profile)
    end
  end
end
