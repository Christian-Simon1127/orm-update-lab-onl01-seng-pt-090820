require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  
  def initialize(name, grade, id = nil)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      age TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = <<-SQL
    DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end
  
  def update
    sql = <<-SQL
    UPDATE students SET name = ?, grade = ? 
    WHERE students.id = ?;
    SQL
    
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
  
  def save 
    if self.id
      self.update
    else
      sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
      SQL
      
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students;")[0][0]
    end
  end 
  
  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end
  
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students 
    WHERE name = ?
    SQL
    
    DB[:conn].execute(sql, name).map {|item| item}
  end
  
  def self.new_from_db(arr)
    student = Student.new(arr[1], arr[2], arr[0])
  end

end
