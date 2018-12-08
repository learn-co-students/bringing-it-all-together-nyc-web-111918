require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def self.create_table
    DB[:conn].execute('
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        );')
  end

  def self.drop_table
    DB[:conn].execute('
      DROP TABLE dogs')
  end

  def save
    if self.id != nil
      self.update
    else
      DB[:conn].execute('
      INSERT INTO dogs (name, breed) VALUES (?,?)', self.name, self.breed)
      @id = DB[:conn].execute('
      SELECT last_insert_rowid() FROM dogs')[0][0]
    end
    self
  end

  def self.create(attributes)
    new_dog = Dog.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    row = DB[:conn].execute('
    SELECT * FROM dogs WHERE id = ?', id)[0]
    new_instance = Dog.new({})
    new_instance.id = row[0]
    new_instance.breed = row[1]
    new_instance.name = row[2]
    new_instance
  end

  def self.find_or_create_by(name:, breed:)
    dog_data = DB[:conn].execute('
    SELECT * FROM dogs WHERE name = ? AND breed = ?', name, breed)[0]
    if dog_data != nil
      # binding.pry
      dog = Dog.new({})
      dog.id = dog_data[0]
      dog.name = dog_data[1]
      dog.breed = dog_data[2]
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    new_instance = Dog.new({})
    new_instance.id = row[0]
    new_instance.name = row[1]
    new_instance.breed = row[2]
    new_instance
  end

  def self.find_by_name(name)
    row = DB[:conn].execute('
    SELECT * FROM dogs WHERE name = ?', name)[0]
    new_instance = Dog.new({})
    new_instance.id = row[0]
    new_instance.name = row[1]
    new_instance.breed = row[2]
    new_instance
  end

  def update
    DB[:conn].execute('
    UPDATE dogs SET id = ?, name = ?, breed = ?', self.id, self.name, self.breed)
  end

end

# #
# binding.pry
# # #
# "asdfs"
