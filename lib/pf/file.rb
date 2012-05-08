module Pf
    class PfFile
        def initialize(file)
            open(file)
        end
        def open(file)
            puts "Open " + file + " here"
        end
    end
end
