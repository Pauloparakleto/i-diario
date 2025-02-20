class ClassroomsController < ApplicationController
  respond_to :json

  def index
    if params[:find_by_current_teacher]
      teacher_id = current_teacher.try(:id)
      return unless teacher_id
    end
    if params[:find_by_current_year]
      year = current_school_calendar.try(:year)
    end
    score_type = params[:score_type]

    (params[:filter] || []).delete(:by_grade) if params.dig(:filter, :by_grade).blank?

    @classrooms = apply_scopes(Classroom).ordered
    if params[:include_unity]
      @classrooms = @classrooms.includes(:unity)
    end
    @classrooms = @classrooms.by_teacher_id(teacher_id) if teacher_id
    @classrooms = @classrooms.by_score_type(ScoreTypes.value_for(score_type.upcase)) if score_type
    @classrooms = @classrooms.by_year(year) if year
    @classrooms = @classrooms.ordered.uniq
  end

  def multi_grade
    render json: current_user_classroom.multi_grade?
  end

  def show
    return unless teacher_id = current_teacher.try(:id)
    id = params[:id]

    @classroom = Classroom.find_by_id(id)
  end
end
