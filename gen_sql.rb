SQL_FILE = 'recs2015.sql'
INPUT_FILE =  'RECS2015.csv'
TABLE_NAME = 'RECS_2015'

def get_lines(file)
  lines = file.map do |line|
    line
  end
end

def headers(lines)
  headers = lines.first.gsub("\n", '').split(',').map do |col|
    col.gsub('"', '')
  end
end

def types(lines, headers)
  types = lines[1].split(',').map.with_index do |val, index|
    {name: headers[index], type: get_type(val)}
  end
end

def get_type(value)
  value = value.gsub('"', '')
  return "integer" if value.to_i.to_s == value
  return "double" if value.to_i.to_s != value && value.to_f.to_s == value
  return "text"
end

def create_table(sql, type_info)
  sql += "CREATE TABLE #{TABLE_NAME} (\n"
  type_info.each do |s|
    sql += "  #{s[:name]} #{s[:type]},\n"
  end

  sql.chomp!("\n")
  sql.chomp!(',')

  sql += "\n);"
end

def headers_str(headers)
  str = ""
  headers.each do |h|
    str += "#{h},"
  end
  str.chomp!(',')
end

file = File.open(INPUT_FILE)
l = get_lines(file)
h = headers(l)
t = types(l, h)

sql = create_table("", t)
sql += "\n\nCOPY #{TABLE_NAME}(#{headers_str(h)})\n"
sql += "FROM #{INPUT_FILE} DELIMITER ',' CSV HEADER;"

puts sql
File.open(SQL_FILE, 'w') { |f| f.write(sql) }
