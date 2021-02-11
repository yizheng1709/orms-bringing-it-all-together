class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name 
        @breed = breed 
    end 

    def self.create_table 
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end 

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end 

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        
        sql2 = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL

        row = DB[:conn].execute(sql2, self.name, self.breed)[0]
        self.id = row[0]
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end 

    def self.create(hash)
        dog = self.new(id: hash[:id], name: hash[:name], breed: hash[:breed])
        dog.save
        dog
    end 

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end 

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL

        row = DB[:conn].execute(sql, id)[0]
        self.new(id: row[0], name: row[1], breed: row[2])
    end 

    def self.find_or_create_by(hash)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])[0]
        if dog
            dog = self.new_from_db(dog)
        else 
            dog = self.create(hash)
        end 
        dog 
    end 

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        if dog
            dog = self.new_from_db(dog)
        end 
        dog 
    end 

    def update
        if self.id
            sql = <<-SQL 
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
            SQL
        
            DB[:conn].execute(sql, self.name, self.breed, self.id)
        
        end 
    end 

end 