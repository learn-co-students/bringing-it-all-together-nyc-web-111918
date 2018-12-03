require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(attribute = {})
    attribute.each do |key, value|
      self.send(("#{key}="), value)
    end
  end

  def self.create_table
    sql =" CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY,  name TEXT, grade INTEGER)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs(name, breed) VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.breed)
      sql_id = "SELECT last_insert_rowid() FROM dogs"
      @id = DB[:conn].execute(sql_id).first.first
    end
    self
  end

  def self.create(attribute)
    self.new(attribute).save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    data = DB[:conn].execute(sql, id).first
    new_dog = Dog.new({id: data[0], name: data[1], breed: data[2]})
  end

  def self.find_or_create_by(attribute)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", attribute[:name], attribute[:breed]).first

    unless dog.nil?
      dog_data = {id: dog[0], name: dog[1], breed: dog[2]}
      Dog.new(dog_data)
    else
      self.create(attribute)
    end
  end

  def self.new_from_db(attribute)
    Dog.new({id: attribute[0], name: attribute[1], breed: attribute[2]})
  end

  def self.find_by_name(name)
      sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
      data = DB[:conn].execute(sql, name).first
      Dog.new({id: data[0], name: data[1], breed: data[2]})
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end #<--end of DOG class
