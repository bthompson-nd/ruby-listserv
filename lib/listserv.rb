class Listserv

  # Iinitialize the class, file name optional
  def initialize(*args)
    if args.size < 1
      @title = ''
      return self
    else
      self.load args[0]
      return self
    end
  end

  # Load a file by name
  def load(filename)
    @properties = Hash.new

    # After an initial series of 11 characters, Listserv files consist of 100-character "lines"
    # These lines do not have line terminator characters so we must split them directly based on a 100-character limit.
    offset = 11
    length = 100
    file = filename

    # The first 'line' contains the plain title of the Listserv.
    @title = IO.read(file, length, offset += length, mode:'rb')
    begin
      @title = @title.strip[2..-1]
    rescue
      @title = "{Could Not Parse Title}"
    end

    # Read the first section of the file. Settings come in the form of "* Key= Value"
    while line = IO.read(file, length, offset += length, mode: 'rb')
      property = line.scan(/\*\s{1,2}(\S+)= (.+)/)
      hash = property.to_h
      hash.each do |k, v|
        if @properties[k] == nil
          @properties[k] = Array.new
        end
        v.strip.split(',').each do |val|
          @properties[k].push val
        end
      end
      if line.include? ' PW= '
        break
      end
    end

    # Read the members, 100-character lines are terminated by the eight-character sequence "////    "
    @members = Array.new
    while line = IO.read(file, length, offset += length, mode: 'rb')
      member_matches = line.scan(/(.{1,80})[\S]{12}\/\/\/\/    /)
      begin
        member_match_count = member_matches.flatten!.count
      rescue
        member_match_count = 0
      end
      if member_match_count > 0
        member_matches.each do |m|
          @members.push m.strip
        end
      end
    end
    return self
  end

  # Get the Listserv's title
  def title
    @title
  end

  # Get a Hash of the Listserv's properties. This includes the members
  def properties
    @properties
  end

  # Get an Array of the Listserv's members. Full names are stripped. Lowercase emails only.
  def members
    get_emails @members
  end

  # Get the Listserv's password
  def pw
    if @properties['PW'].class == Array && @properties['PW'].size > 0
      @properties['PW'][0]
    else
      nil
    end
  end

  # Get the Listserv's owners in an array of email addresses
  def owners
    get_emails @properties['Owner']
  end

  # Get the Listserv's editors in an array of email addresses
  def editors
    get_emails @properties['Editor']
  end

  # Get the Listserv's moderators in an array of email addresses
  def moderators
    get_emails @properties['Moderator']
  end


  private

  def get_emails(matches)
    output = [] #The output variable
    begin
      matches.flatten! #Flattens the match array in case the original contained any arrays (it probably didn't)
      matches.map! {|m| m.split(',')} #Split any elements of the match array if they are comma-delimited
      matches.flatten! #Flatten the split comma-delimited elements back down so this is a 1-D array again
      matches.each do |match|
        #Find any email addresses in a match
        emails = match.downcase.scan(/[a-z'0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,5}/)
        emails.each do |email|
          output.push email #Put those email addresses into the output variable
        end
      end
    rescue
      #You were probably passed an empty block of matches
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

