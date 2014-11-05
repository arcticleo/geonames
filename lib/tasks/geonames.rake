namespace :geonames do

  require 'net/http'
  require 'zipruby'
  require 'csv'

  class String
    def sanitize
      self.blank? ? nil : self.force_encoding("utf-8")
    end
  end

  def download_and_return_tsv_rows_for url
    tsv_rows = []
    data = { "some-bizarre-params" => "which-are-needed" }
    begin
      puts "Downloading: " + url
      response = Net::HTTP.post_form(URI.parse(url), data)
      case response
      when Net::HTTPOK
        if url.split('/').last.split('.').last.upcase == 'ZIP'
          zipbytes = response.body
          Zip::Archive.open_buffer(zipbytes) do |zf|
            n = zf.num_files
            n.times do |i|
              file_name = zf.get_name(i)
              if file_name.split('.').first.upcase == url.split('/').last.split('.').first.upcase
                puts "Parsing..."
                zf.fopen(file_name) do |f|
                  content = f.read
                  content.each_line do |row|
                    begin
                      data = CSV.new(row, col_sep: "\t", quote_char: '@', encoding: 'utf-8').to_a.first
                      tsv_rows << data
                    rescue
                      puts "ERROR PARSING: #{row}"
                    end  
                  end
                end
              end
            end
          end
        else
          content = response.body
          content.each_line do |row|
            begin
              data = CSV.new(row, col_sep: "\t", quote_char: '@', encoding: 'utf-8').to_a.first
              tsv_rows << data
            rescue
              puts "ERROR PARSING: #{row}"
            end  
          end
        end
      when Net::HTTPClientError,
            Net::HTTPInternalServerError
        puts "Could not access #{url.split('/').last}./n/n"
        false 
      else
        puts "Unexpected error.\n\n"
        false
      end
    rescue Timeout::Error => error
      puts "Request timed out./n/n"
      false
    end
    tsv_rows
  end

  desc "Download and populate feature codes."
  task :feature_codes => [:environment] do
    url = "http://download.geonames.org/export/dump/featureCodes_en.txt"
    parsed_data = download_and_return_tsv_rows_for url
    parsed_data.each_with_index do |data_row, index|
      if data_row.count == 3
        puts "#{index + 1}/#{parsed_data.count} - #{data_row[0].to_s.sanitize} #{data_row[1].to_s[0..19].sanitize}"
        @feature_code = FeatureCode.find_or_initialize_by(
          feature_class: data_row[0].to_s.split('.').first.sanitize,
          feature_code: data_row[0].to_s.split('.').last.sanitize,
        )
        @feature_code.assign_attributes({
          name: data_row[1].to_s.sanitize,
          description: data_row[2].to_s.sanitize
        })
        @feature_code.save
      end
    end
  end 

  desc "Download and populate postal codes for a particular country."
  task :postal_codes, [:country_code] => [:environment] do |t, args|
    if args.country_code.to_s.length == 2
      url = "http://download.geonames.org/export/zip/#{args.country_code.upcase}.zip"
      parsed_data = download_and_return_tsv_rows_for url
      parsed_data.each_with_index do |data_row, index|
        if data_row.count == 12
          puts "#{index + 1}/#{parsed_data.count} - #{data_row[0].to_s[0..1].sanitize} #{data_row[1].to_s[0..19].sanitize}"
          @postal_code = PostalCode.find_or_initialize_by(
            country_code: data_row[0].to_s[0..1].sanitize,
            postal_code: data_row[1].to_s[0..19].sanitize,
            admin1_name: data_row[3].to_s[0..99].sanitize,
            admin1_code: data_row[4].to_s[0..19].sanitize
          )
          @postal_code.assign_attributes({
            place_name: data_row[2].to_s[0..179].sanitize,
            admin2_name: data_row[5].to_s[0..99].sanitize,
            admin2_code: data_row[6].to_s[0..19].sanitize,
            admin3_name: data_row[7].to_s[0..99].sanitize,
            admin3_code: data_row[8].to_s[0..19].sanitize,
            latitude: data_row[9],
            longitude: data_row[10],
            accuracy: data_row[11]
          })
          @postal_code.save
        end
      end
    else
      puts "You must provide a valid two character country code. Example: rake geonames:postal_codes[US]\n"
    end
  end 

  desc "Download and import cities with a population > 1000."
  task :cities => [:environment] do
    url = "http://download.geonames.org/export/dump/cities1000.zip"
    parsed_data = download_and_return_tsv_rows_for url
    parsed_data.each_with_index do |data, index|
      if data.count == 19
        puts "#{index + 1}/#{parsed_data.count} - #{data[8]} #{data[2].to_s.sanitize}"
        @geoname = Geoname.find_or_initialize_by(id: data[0])
        @geoname.assign_attributes({
          name: data[1].to_s.sanitize,
          asciiname: data[2].to_s.sanitize,
          alternatenames: data[3].to_s.sanitize,
          latitude: data[4],
          longitude: data[5],
          feature_class: data[6],
          feature_code: data[7],
          country_code: data[8],
          cc2: data[9],
          admin1_code: data[10].to_s[0..19].sanitize,
          admin2_code: data[11].to_s[0..19].sanitize,
          admin3_code: data[12].to_s[0..19].sanitize,
          admin4_code: data[13].to_s[0..19].sanitize,
          population: data[14],
          elevation: data[15],
          dem: data[16],
          timezone: data[17],
          modification_date: data[18]
        })
        @geoname.save
      end
    end
  end

end
