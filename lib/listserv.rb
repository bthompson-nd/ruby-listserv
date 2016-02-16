class Listserv

  def initialize(*args)
    if args.size < 1
      @title = ''
      return self
    else
      self.load args[0]
      return self
    end
  end

  def load(filename)
    @properties = Hash.new
    offset = 11
    length = 100
    file = filename

    @title = IO.read(file, length, offset += length, mode:'rb')
    @title = @title.strip[2..-1]

    while line = IO.read(file, length, offset += length, mode: 'rb')
      property = line.scan(/\* (\S+)= (.+)/)
      if property.size == 2
        key = property[0]
        if @properties[key] == nil
          @properties[key] = Array.new
        end
        property[1].split(',').each do |val|
          @propertes[key].push val
        end
      end
      if key == 'PW'
        break
      end
    end

    @members = Array.new
    while line = IO.read(file, length, offset += length, mode: 'rb')
      member_matches = line.scan(/(.{1,80})[\S]{12}\/\/\/\/    /)
      if member_matches.count > 0
        member_matches.flatten.each {|match| @members.push match.strip }
      end
    end
    return self
  end

  def title
    @title
  end

  def properties
    @properties
  end

  def members
    @members
  end


  private

  def get_emails(matches)
    matches.flatten! #Flattens the match array in case the original contained any arrays (it probably didn't)
    matches.map! {|m| m.split(',')} #Split any elements of the match array if they are comma-delimited
    matches.flatten! #Flatten the split comma-delimited elements back down so this is a 1-D array again
    output = [] #The output variable
    matches.each do |match|
      #Find any email addresses in a match
      emails = match.downcase.scan(/[a-z'0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,5}/)
      emails.each do |email|
        output.push email #Put those email addresses into the output variable
      end
    end
    return output #Return a flat array of email addresses.
  end

  def build_settings_hash
    matches = @text.scan(/\* (\S+)= (.{0,100})\*/)
    @properties = Hash.new

    matches.each do |m|
      @properties[m[0]] = Array.new
    end

    matches.each do |m|
      @properties[m[0]].push m[1].strip
    end
    return @properties
  end

  def read_members
    matches = @text.downcase.scan(/([a-z'0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,5}).{0,80}[\S]{12}\/\/\/\/    /).flatten
    @members = Array.new
    matches.each do |m|
      @members.push m.strip
    end
  end

end

