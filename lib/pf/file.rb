
require 'json'

module Pf
    class PfFile
            attr_accessor :quiet
        def initialize(filename, recipient, quiet)
            @recipient = recipient
            @quiet = quiet
            open filename
        end
        def open(filename)
            unwrap filename
            
            if @crypt == "gpg"
                @file = JSON(ungpg(@data))
            else
                raise "Unknown encryption module: " + crypt
            end
        end

        def get
            return @file
        end

        def set(newfile)
            @file = newfile
        end

        def generate_file(newfile)
            @file = [ { 'pff' => { 'major-version' => 0, 'minor-version' => 0, 'file-revision' => 0 }}]
            @major_version = '0'
            @minor_version = '0'
            @crypt = "gpg"
            @metadata = ""
            self.write newfile
        end

        # unwrap checks the headers for the wrapper file format and 
        # returns the encrypted data along with the wrapper headers
        def unwrap(filename)
            @major_version = 0
            @minor_version = 0
            @crypt = ""
            @metadata = ""
            @data = ""

            if !File.exist?(filename)
                self.generate_file(filename)
                puts "Generated new file. Ignore 'invalid packet' from gpg..."
            end

            file = File.open(filename)

            # Check PF Wrapper File format signature
            line = file.readline
            if line.chomp != "PFWrapperFile"
                raise "Does not appear to be a Pf Password file. Header: " + line
            end

            # Get format version, bail on major version difference
            line = file.readline
            if line =~ /^Major Version: (\d+)/
                @major_version = $1
                if @major_version > Pf::VERSION
                    raise "Pf Password file too new"
                end
            end

            line = file.readline
            if line =~ /^Minor Version: (\d+)/
                @minor_version = $1
            end

            # Plaintext name of encryption module
            line = file.readline
            if line.chomp =~ /^Encryption Module: (.*)/
                @crypt = $1
            end

            # Haven't thought through encryption beyond gpg--reserving for
            # public keys or whatever else might be involved with other
            # styles of encryption
            line = file.readline
            if line.chomp =~ /^Encryption Metadata: (.*)/
                @metadata = $1
            end

            # Check separator for sanity
            line = file.readline
            if line.chomp !~ /^--$/
                raise "Pf Password file has incorrect header"
            end

            # Everything past here should be the encrypted Pf File
            file.each { |line| @data += line }

            file.close
        end

        def wrap(filename)
            file = File.open(filename, 'w')

            file.write("PFWrapperFile\n")
            file.write("Major Version: " + @major_version + "\n")
            file.write("Minor Version: " + @minor_version + "\n")
            file.write("Encryption Module: " + @crypt + "\n")
            file.write("Encryption Metadata: " + @metadata + "\n")
            file.write("--\n")
            file.write(@data);

            file.close
        end

        def gpg(data)
            pipe = IO.popen("/usr/bin/env gpg -e -r '" + @recipient + "'", "w+") do |pipe|
                pipe.print data
                pipe.close_write
                # see witty comment in ungpg
                pipe.read
            end
        end

        # This uses gpg command to decrypt any gpg data. Should be made into
        # an independent module after encryption is modularized, probably
        # should use a lib, definitely shouldn't permahardcode the gpg path
        # (even with env)...
        def ungpg(data)
            ungpg_cmd = "/usr/bin/env gpg"
            if @quiet
                ungpg_cmd = ungpg_cmd + " -q --no-tty"
            end
            pipe = IO.popen(ungpg_cmd, "w+") do |pipe|
                pipe.print data
                pipe.close_write
                # not using return despite feeling that doing so is evil
                pipe.read
            end
        end
        def write(filename)
            @data = gpg(@file.to_json)
            wrap filename
        end
    end
end
