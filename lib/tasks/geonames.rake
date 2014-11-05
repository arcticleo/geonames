namespace :geonames do

  require 'net/http'
  require 'zipruby'
  require 'csv'

  class String
    def sanitize
      self.blank? ? nil : self.force_encoding("utf-8")
    end
  end

  desc "Download and populate postal codes for a particular country."
  task :postal_codes, [:country_code] => [:environment] do |t, args|
    if args.country_code.to_s.length == 2
      url = "http://download.geonames.org/export/zip/#{args.country_code.upcase}.zip"
      data = { "some-bizarre-params" => "which-are-needed" }
      begin
        response = Net::HTTP.post_form(URI.parse(url), data)
        case response
        when Net::HTTPOK
          zipbytes = response.body
          Zip::Archive.open_buffer(zipbytes) do |zf|
            n = zf.num_files
            n.times do |i|
              file_name = zf.get_name(i)
              if file_name == [args.country_code.upcase, ".txt"].join
                zf.fopen(file_name) do |f|
                  content = f.read
                  csv = CSV.new(content, col_sep: "\t")
                  csv.each do |row|
                    print "."
                    if row.count == 12
                      PostalCode.find_or_create_by(
                        country_code: row[0],
                        postal_code: row[1],
                        place_name: row[2],
                        admin1_name: row[3],
                        admin1_code: row[4],
                        admin2_name: row[5],
                        admin2_code: row[6],
                        admin3_name: row[7],
                        admin3_code: row[8],
                        latitude: row[9],
                        longitude: row[10],
                        accuracy: row[11]
                      )
                    end
                  end
                  puts
                end
              end
            end
          end
        when Net::HTTPClientError,
              Net::HTTPInternalServerError
          puts "Could not access postal codes for country code #{args.country_code}./n/n"
          false 
        else
          puts "Unexpected error.\n\n"
        end
      rescue Timeout::Error => error
        puts "Request timed out./n/n"
        false
      end
    else
      puts "You must provide a valid two character country code. Example: rake geonames:postal_codes[US]\n"
    end
  end 
  
  def download_zip_and_return_tsv_rows url
    tsv_rows = []
    data = { "some-bizarre-params" => "which-are-needed" }
    begin
      puts "Downloading: " + url
      response = Net::HTTP.post_form(URI.parse(url), data)
      case response
      when Net::HTTPOK
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

  desc "Download and import cities with a population > 1000."
  task :cities => [:environment] do
    url = "http://download.geonames.org/export/dump/cities1000.zip"
    parsed_data = download_zip_and_return_tsv_rows url
    puts parsed_data.count
    parsed_data.each_with_index do |data, index|
      if data.count == 19
        puts "#{index + 1} - #{data[2].to_s.sanitize}, #{data[8]}"
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
