require 'csv'
require 'mysql'

my = Mysql::init()
# You can do any SSL stuff before the real_connect
# args: hostname, username, password, database
my.real_connect("localhost", "root", "123465", "zw09-csv")

#my.query("DELETE FROM resistor_configs")

CSV.foreach('./import.db', 'r') do |row|
  # No escaping here, because I trust the input file. You may not
  my.query("INSERT INTO posts" +
                   "(title, body, author, school, district, date, type)" +
           "VALUES (#{row[0]}, #{row[1]}, #{row[6]}, #{row[5]}, #{row[3]}, #{row[4]}, #{row[7]})")
            
end
