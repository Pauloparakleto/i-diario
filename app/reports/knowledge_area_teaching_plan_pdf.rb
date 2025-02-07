class KnowledgeAreaTeachingPlanPdf < BaseReport
  def self.build(entity_configuration, knowledge_area_teaching_plan)
    new.build(entity_configuration, knowledge_area_teaching_plan)
  end

  def build(entity_configuration, knowledge_area_teaching_plan)
    @entity_configuration = entity_configuration
    @knowledge_area_teaching_plan = knowledge_area_teaching_plan
    attributes

    if @display_header_on_all_reports_pages
      header
      body
    else
      bounding_box([0, cursor], width: bounds.width, height: bounds.height - GAP) do
        header
        body
      end
    end

    footer

    self
  end

  private

  def header
    header_cell = make_cell(
      content: Translator.t('navigation.knowledge_area_teaching_plans'),
      size: 12,
      font_style: :bold,
      background_color: 'DEDEDE',
      height: 20,
      padding: [2, 2, 4, 4],
      align: :center,
      colspan: 2
    )

    begin
      entity_logo_cell = make_cell(
        image: open(@entity_configuration.logo.url),
        fit: [50, 50],
        width: 70,
        rowspan: 4,
        position: :center,
        vposition: :center
      )
    rescue
      entity_logo_cell = make_cell(content: '', width: 70, rowspan: 4)
    end

    entity_name = @entity_configuration ? @entity_configuration.entity_name : ''
    organ_name = @entity_configuration ? @entity_configuration.organ_name : ''

    entity_organ_and_unity_cell = make_cell(
      content: "#{entity_name}\n#{organ_name}\n#{teaching_plan.unity.name}",
      size: 12,
      leading: 1.5,
      align: :center,
      valign: :center,
      rowspan: 4,
      padding: [6, 0, 8, 0]
    )

    table_data = [
      [header_cell],
      [
        entity_logo_cell,
        entity_organ_and_unity_cell
      ]
    ]

    page_header do
      table(table_data, width: bounds.width) do
        cells.border_width = 0.25
        row(0).border_top_width = 0.25
        row(-1).border_bottom_width = 0.25
        column(0).border_left_width = 0.25
        column(-1).border_right_width = 0.25
      end
    end
  end

  def attributes
    @general_information_header_cell = make_cell(
      content: 'Identificação',
      size: 12,
      font_style: :bold,
      background_color: 'DEDEDE',
      height: 20,
      padding: [2, 2, 4, 4],
      align: :center,
      colspan: 7
    )

    @class_plan_header_cell = make_cell(
      content: Translator.t('navigation.teaching_plans_menu'),
      size: 12,
      font_style: :bold,
      background_color: 'DEDEDE',
      height: 20,
      padding: [2, 2, 4, 4],
      align: :center,
      colspan: 4
    )
    knowledge_area_lesson_plans_knowledge_areas = KnowledgeAreaTeachingPlanKnowledgeArea.where knowledge_area_teaching_plan_id: @knowledge_area_teaching_plan.id
    knowledge_area_ids = []

    knowledge_area_lesson_plans_knowledge_areas.each do |knowledge_area_lesson_plans_knowledge_area|
      knowledge_area_ids << knowledge_area_lesson_plans_knowledge_area.knowledge_area_id
    end

    knowledge_areas = KnowledgeArea.where id: [knowledge_area_ids]

    knowledge_area_descriptions = (knowledge_areas.map { |descriptions| descriptions}.join(", "))

    @unity_header = make_cell(content: 'Unidade', size: 8, font_style: :bold, borders: [:left, :right, :top], padding: [2, 2, 4, 4], colspan: 7)
    @unity_cell = make_cell(content: teaching_plan.unity.name, size: 10, borders: [:bottom, :left, :right], padding: [0, 2, 4, 4], colspan: 7)

    @knowledge_area_header = make_cell(content: 'Áreas de conhecimento', size: 8, font_style: :bold, borders: [:top, :left, :right], padding: [2, 2, 4, 4], colspan: 3)
    @knowledge_area_cell = make_cell(content: knowledge_area_descriptions, size: 10, borders: [:bottom, :left, :right], padding: [0, 2, 4, 4], colspan: 3)

    @classroom_header = make_cell(content: 'Série', size: 8, font_style: :bold, borders: [:left, :right, :top], padding: [2, 2, 4, 4], colspan: 4)
    @classroom_cell = make_cell(content: teaching_plan.grade.description, size: 10, borders: [:bottom, :left, :right], padding: [0, 2, 4, 4], colspan: 4)

    @teacher_header = make_cell(content: 'Professor', size: 8, font_style: :bold, borders: [:left, :right, :top], padding: [2, 2, 4, 4], colspan: 3)
    @teacher_cell = make_cell(content: teaching_plan.teacher.name, size: 10, borders: [:bottom, :left, :right], padding: [0, 2, 4, 4], colspan: 3)

    @year_header = make_cell(content: 'Ano', size: 8, font_style: :bold, borders: [:left, :right, :top], padding: [2, 2, 4, 4], colspan: 2)
    @year_cell = make_cell(content: teaching_plan.year.to_s, size: 10, borders: [:bottom, :left, :right], padding: [0, 2, 4, 4], colspan: 2)

    @period_header = make_cell(content: 'Período escolar', size: 8, font_style: :bold, borders: [:left, :right, :top], padding: [2, 2, 4, 4], colspan: 2)
    @period_cell = make_cell(content: (teaching_plan.yearly? ? teaching_plan.school_term_type.to_s : teaching_plan.school_term_type_step_humanize), size: 10, borders: [:bottom, :left, :right], padding: [0, 2, 4, 4], colspan: 2)
  end

  def general_information
    general_information_table_data = [
      [@general_information_header_cell],
      [@unity_header],
      [@unity_cell],
      [@knowledge_area_header, @classroom_header],
      [@knowledge_area_cell, @classroom_cell],
      [@teacher_header, @year_header, @period_header],
      [@teacher_cell, @year_cell, @period_cell]
    ]

    table(general_information_table_data, width: bounds.width) do
      cells.border_width = 0.25
      row(0).border_top_width = 0.25
      row(-1).border_bottom_width = 0.25
      column(0).border_left_width = 0.25
      column(-1).border_right_width = 0.25
    end

    move_down GAP
  end

  def class_plan
    class_plan_table_data = [
      [@class_plan_header_cell]
    ]

    table(class_plan_table_data, width: bounds.width, cell_style: { inline_format: true }) do
      cells.border_width = 0.25
      row(0).border_top_width = 0.25
      row(-1).border_bottom_width = 0.25
      column(0).border_left_width = 0.25
      column(-1).border_right_width = 0.25
    end

    experience_fields = @knowledge_area_teaching_plan.experience_fields.presence
    content = teaching_plan.present? ? teaching_plan.contents_ordered.map(&:to_s).join("\n ") : '-'
    objectives = teaching_plan.objectives.present? ? teaching_plan.objectives_ordered.map(&:to_s).join("\n ") : '-'
    methodology = teaching_plan.methodology || '-'
    evaluation = teaching_plan.evaluation || '-'
    references = teaching_plan.references || '-'

    experience_fields_label = Translator.t('activerecord.attributes.knowledge_area_teaching_plan.experience_fields')
    contents_label = Translator.t('activerecord.attributes.knowledge_area_teaching_plan.contents')
    objectives_label = Translator.t('activerecord.attributes.discipline_teaching_plan.objectives')
    text_box_truncate(experience_fields_label, experience_fields) if experience_fields
    text_box_truncate(contents_label, content)
    text_box_truncate(objectives_label, objectives)
    text_box_truncate('Metodologia', methodology)
    text_box_truncate('Avaliação', evaluation)
    text_box_truncate('Referências', references)
  end

  def teaching_plan
    @teaching_plan ||= @knowledge_area_teaching_plan.teaching_plan
  end

  def body
    page_content do
      general_information
      class_plan
    end
  end
end
