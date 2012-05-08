module Pf
    class PfFile
        def initialize(file)
            open(file)
        end
        def open(file)
            crypt, module =  unwrap file
            puts crypt + ", " + module
        end
        def unwrap
            return 'the crypt type', 'the module'
        end
    end
end
