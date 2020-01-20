require 'json'
require 'csv'

module CommonLib

  module Json2csvHelper
    include LogFactory

    def json2csv input_data
      @input_data = input_data
      process_json
      format_data
      export_to_csv
    end

    def json2excel input_data
      @input_data = input_data
      process_json
      format_data
      [@headers, @constructed_array_of_rows]
    end

    # Processing json data
    def process_json
      @row_data = {}
      @building_array_of_hashes = []

      if @input_data.is_a? Array
        @input_data.each {|row| process_row row}
      elsif @input_data.is_a? Hash
        process_row(@input_data)
      end
    end

    # Inserting item
    def insert_item key, value
      @row_data[key] = value
    end

    # Inserting new line for every row
    def insert_new_line depth
      @building_array_of_hashes << @row_data
      @row_data = {}
    end

    # Processing each row and inserting item
    def process_row row
      @depth = 0
      row.each do |key, value|
        check_type key, value, key, ''
      end
    end

    # checking the type as Array or Hash or final key, value pair
    def check_type key, value, row_key, new_ar_key_prepend
      if value.is_a? Array
        array_depth = @depth
        value.each_with_index do |ele, index|
          @depth = array_depth
          new_ar_key = new_ar_key_prepend
          insert_new_line @depth if index > 0
          check_type key, ele, row_key, new_ar_key
        end
      elsif value.is_a? Hash
        value.each do |key, value|
          new_ar_key = "#{new_ar_key_prepend}__#{key}"
          check_type key, value, row_key, new_ar_key
        end
      else
        @depth = @depth + 1
        insert_item row_key + new_ar_key_prepend, value
      end
    end

    # Arranging data into rows 
    def format_data
      @building_array_of_hashes << @row_data
      @headers = []
      @building_array_of_hashes.each do |data|
        @headers = @headers | data.keys
      end
      @constructed_array_of_rows = []
      @building_array_of_hashes.each do |data|
        row = []
        @headers.each do |key|
          row << data[key] ? data[key] : ""
        end
        @constructed_array_of_rows << row
      end
    end

    # Exporting data into csv
    def export_to_csv
      CSV.open('public/report_content.csv', 'w', write_headers: true, headers: @headers) do |csv|
        @constructed_array_of_rows.each do |row|
          csv << row
        end
      end
    end
  end
end