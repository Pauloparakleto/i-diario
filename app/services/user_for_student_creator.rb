class UserForStudentCreator
  def self.create!
    new.create!
  end

  def create!
    create_user
  end

  private

  def create_user
    role_id = Role.find_by(access_level: 'student')&.id

    raise 'Permissão de aluno não encontrada.' if role_id.blank?

    Student.joins('LEFT JOIN users ON users.student_id = students.id')
           .where(users: { student_id: nil })
           .find_each do |student|
      next if User.find_by(login: student.api_code, kind: RoleKind::STUDENT)
      next if User.find_by(student_id: student.id, kind: 'student')

      password = "estudante#{student.api_code}"

      user = User.create!(
        login: student.api_code,
        first_name: student.name,
        email: "#{student.api_code}@ambiente.portabilis.com.br",
        password: password,
        password_confirmation: password,
        status: 'active',
        kind: 'student',
        student_id: student.id
      )

      user_role = UserRole.create!(
        user_id: user.id,
        role_id: role_id
      )

      user.update(current_user_role_id: user_role.id)
    end
  end
end
