require "pf/version"
require "pf/file.rb"

module Pf
 def Pf.generate_file(newfile)
     @filename = newfile
     PfFile.generate_file @filename
     return self
 end
 def Pf.load(newfile,recipient)
     @filename = newfile
     @pwfile = PfFile.new @filename,recipient
     return self
 end
 def Pf.print
     puts @pwfile.get
 end
 def Pf.search(item,service)
     puts ''
     @pwfile.get.each {
         | value |
         value.each {
         | name,vars |
         if name =~ /#{item}/i
             if service == vars['service'] || !service
                 puts "       -=> " + name + " <=-"
                 puts "-----=> Service: " + vars['service'] if vars['service']
                 puts "-----=> Username: " + vars['username'] if vars['username']
                 puts "-----=> Password: " + vars['password']
                 puts "-----=> Note: " + vars['note'] if vars['note']
                 puts "-----=> Description: " + vars['description'] if vars['description']
                 puts "-----=> Location: " + vars['location'] if vars['location']
                 puts "-----=> Group: " + vars['group'] if vars['group']
                 if vars['previous_password']
                     puts "-----=> Previous Passwords:"
                     puts vars['previous_password']
                 end
                 puts ''
             end
         end
        }
     }
 end
 def Pf.write
     puts @pwfile.write @filename
 end
 def Pf.add(item,args)
    if !(item && args[:password])
        puts "Need both item name and password!"
        exit 1
    end
    file = @pwfile.get

    file.each {
        | value |
        value.each {
            | name,vars |
            if (name == item) && ((!args[:service] && !vars['service']) || (args[:service] == vars['service']))
                puts "Item already exists!"
                exit 1
            end
        }
    }

    new = {}
    new[item] = {}
    new[item]['password_definition'] = true
    new[item]['password'] = args[:password]
    new[item]['note'] = args[:note] if args[:note]
    new[item]['description'] = args[:desc] if args[:desc]
    new[item]['service'] = args[:service] if args[:service]
    new[item]['location'] = args[:location] if args[:location]
    new[item]['username'] = args[:username] if args[:username]
    new[item]['group'] = args[:group] if args[:group]

    file.push(new)
    @pwfile.set file
 end

 def Pf.update(item,args)
    if !(item && args[:password])
        puts "Need both item name and password!"
        exit 1
    end

    file = @pwfile.get

    file.each {
        | value |
        value.each {
            | name,vars |
            if name == item
                if (!args[:service] && !vars['service']) || (args[:service] == vars['service'])
                    if args[:password] && args[:password] != vars['password']
                        if vars['previous_password']
                            vars['previous_password'].push vars['password']
                        else
                            vars['previous_password'] = Array.new([vars['password']])
                        end
                        vars['password'] = args[:password] if args[:password]
                    end
                    vars['note'] = args[:note] if args[:note]
                    vars['description'] = args[:desc] if args[:desc]
                    vars['service'] = args[:service] if args[:service]
                    vars['location'] = args[:location] if args[:location]
                    vars['username'] = args[:username] if args[:username]
                    vars['group'] = args[:group] if args[:group]

                    @pwfile.set file
                    if vars['service']
                        puts "Updated " + item + " / " + vars['service']
                    else
                        puts "Updated " + item
                    end

                    self.search(item, vars['service'])
                end
            end
        }
    }
 end

end
