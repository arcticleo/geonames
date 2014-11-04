namespace :geonames do

  require 'net/http'
  require 'zipruby'
  require 'csv'

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

end
