
# encoding: UTF-8

class MarbleElizabeth

    # @filepath

    def initialize(filepath)
        @filepath = filepath
    end

    def commitBlob(blob)
        nhash = "SHA256-#{Digest::SHA256.hexdigest(blob)}"
        # Some operations may accidentally call those functions on a marble that has died, that create an empty file
        raise "a57bb88e-d792-4b15-bb7d-3ff7d41ee3ce" if !File.exists?(@filepath)
        db = SQLite3::Database.new(@filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.transaction 
        db.execute "delete from _data_ where _key_=?", [nhash]
        db.execute "insert into _data_ (_key_, _value_) values (?,?)", [nhash, blob]
        db.commit 
        db.close
        nhash
    end

    def filepathToContentHash(filepath)
        "SHA256-#{Digest::SHA256.file(filepath).hexdigest}"
    end

    def readBlobErrorIfNotFound(nhash)
        # Some operations may accidentally call those functions on a marble that has died, that create an empty file
        raise "a57bb88e-d793-4b15-bb7d-3ff7d41ee3ce" if !File.exists?(@filepath)
        db = SQLite3::Database.new(@filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        blob = nil
        db.execute("select * from _data_ where _key_=?", [nhash]) do |row|
            blob = row['_value_']
        end
        db.close
        return blob if blob

        # When I did the original data migration, some blobs endded up in Asteroids-TheBigBlobs. Don't ask why...
        # (Actually, they were too big for sqlite, and the existence of those big blogs in the first place is because
        # "ClickableType" data exist in one big blob 🙄)

        filepath = "/Users/pascal/Galaxy/DataBank/Catalyst/Marbles-TheLargeMigrationBlobs/#{nhash}.data"
        if File.exists?(filepath) then
            return IO.read(filepath) 
        end

        raise "[Error: 2400b1c6-42ff-49d0-b37c-fbd37f179e01, nhash: #{nhash}]"
    end

    def datablobCheck(nhash)
        begin
            readBlobErrorIfNotFound(nhash)
            true
        rescue
            false
        end
    end
end

class Marble

    # @filepath

    # -----------------------------------------------------

    def initialize(filepath)
        raise "a57bb88e-d791-4b15-bb7d-3ff7d41ee3ce" if !File.exists?(filepath)
        @filepath = filepath
    end

    def uuid()
        get("uuid")
    end

    def unixtime()
        get("unixtime")
    end

    def domain()
        get("domain")
    end

    def description()
        get("description")
    end

    def type()
        get("type")
    end

    def payload()
        get("payload")
    end

    # -----------------------------------------------------

    def set(key, value)
        # Some operations may accidentally call those functions on a marble that has died, that create an empty file
        raise "a57bb88e-d794-4b15-bb7d-3ff7d41ee3ce" if !File.exists?(@filepath)
        db = SQLite3::Database.new(@filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.transaction 
        db.execute "delete from _data_ where _key_=?", [key]
        db.execute "insert into _data_ (_key_, _value_) values (?,?)", [key, value]
        db.commit 
        db.close
    end

    def getOrNull(key)
        # Some operations may accidentally call those functions on a marble that has died, that create an empty file
        raise "a57bb88e-d795-4b15-bb7d-3ff7d41ee3ce" if !File.exists?(@filepath)
        db = SQLite3::Database.new(@filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.results_as_hash = true
        value = nil
        db.execute("select * from _data_ where _key_=?", [key]) do |row|
            value = row['_value_']
        end
        db.close
        value

        return value if value

        nhash = key
        filepath = "/Users/pascal/Galaxy/DataBank/Catalyst/Marbles-TheLargeMigrationBlobs/#{nhash}.data"
        if File.exists?(filepath) then
            return IO.read(filepath) 
        end

        nil
    end

    def get(key)
        value = getOrNull(key)
        raise "error: 3cc77bfa-ab61-451d-bb0b-902540684a84: could not extract mandatory key '#{key}' at marble '#{@filepath}'" if value.nil?
        value
    end

    # -----------------------------------------------------

    def filepath()
        @filepath
    end

    def isStillAlive()
        File.exists?(@filepath)
    end

    def destroy()
        FileUtils.rm(@filepath)
    end

    # -----------------------------------------------------

    def hasNote()
        text = getOrNull("note")
        !text.nil? and text.size > 0 
    end

    def getNote()
        getOrNull("note") || ""
    end

    def editNote()
        text = getNote()
        text = Utils::editTextSynchronously(text)
        set("note", text)
    end

end

class Marbles

    # Marbles::domains()
    def self.domains()
        ["anniversaries", "waves", "quarks"]
    end

    # Marbles::filepaths()
    def self.filepaths()
        Marbles::domains()
            .map{|domain|
                LucilleCore::locationsAtFolder("/Users/pascal/Galaxy/DataBank/Catalyst/Marbles/#{domain}")
            }
            .flatten
    end

    # Marbles::marblesOfGivenDomainInOrder(domain)
    def self.marblesOfGivenDomainInOrder(domain)
        LucilleCore::locationsAtFolder("/Users/pascal/Galaxy/DataBank/Catalyst/Marbles/#{domain}")
            .sort
            .map{|filepath| Marble.new(filepath)}
    end

    # Marbles::issueNewEmptyMarble(filepath)
    def self.issueNewEmptyMarble(filepath)
        raise "[37d4ec0d-5562-47c1-861c-ca08078e26b0: #{filepath}]" if File.exists?(filepath)

        db = SQLite3::Database.new(filepath)
        db.busy_timeout = 117
        db.busy_handler { |count| true }
        db.execute "create table _data_ (_key_ string, _value_ blob)", []
        db.close

        Marble.new(filepath)
    end

    # Marbles::access(marble)
    def self.access(marble)

        return if !marble.isStillAlive()
        puts marble.type()

        if marble.type() == "Line" then
            puts marble.description()
            return
        end
        if marble.type() == "Url" then
            puts "opening '#{marble.payload()}'"
            Utils::openUrl(marble.payload())
            return
        end
        if marble.type() == "Text" then
            puts "opening text '#{marble.payload()}' (edit mode)"
            nhash = marble.payload()
            text1 = MarbleElizabeth.new(marble.filepath()).readBlobErrorIfNotFound(nhash)
            text2 = Utils::editTextSynchronously(text1)
            if (text1 != text2) and LucilleCore::askQuestionAnswerAsBoolean("commit changes ? ") then
                payload = MarbleElizabeth.new(marble.filepath()).commitBlob(text2)
                marble.set("payload", payload)
            end
            return
        end
        if marble.type() == "ClickableType" then
            puts "opening file '#{marble.payload()}'"
            nhash, extension = marble.payload().split("|")
            filepath = "/Users/pascal/Desktop/#{nhash}#{extension}"
            blob = MarbleElizabeth.new(marble.filepath()).readBlobErrorIfNotFound(nhash)
            File.open(filepath, "w"){|f| f.write(blob) }
            puts "I have exported the file at '#{filepath}'"
            system("open '#{filepath}'")
            return
        end
        if marble.type() == "AionPoint" then
            puts "opening aion point '#{marble.payload()}'"
            nhash = marble.payload()
            targetReconstructionFolderpath = "/Users/pascal/Desktop"
            AionCore::exportHashAtFolder(MarbleElizabeth.new(marble.filepath()), nhash, targetReconstructionFolderpath)
            puts "Export completed"
            return
        end
        raise "[error: 456c8df0-efb7-4588-b30d-7884b33442b9]"
    end

    # Marbles::postAccessCleanUp(marble)
    def self.postAccessCleanUp(marble)

        return if !marble.isStillAlive()

        if marble.type() == "Line" then
            return
        end
        if marble.type() == "Url" then
            return
        end
        if marble.type() == "Text" then
            return
        end
        if marble.type() == "ClickableType" then
            puts "cleaning file '#{marble.payload()}'"
            nhash, extension = marble.payload().split("|")
            filepath = "/Users/pascal/Desktop/#{nhash}#{extension}"
            return if !File.exists?(filepath)
            LucilleCore::removeFileSystemLocation(filepath)
            return
        end
        if marble.type() == "AionPoint" then
            puts "cleaning aion point '#{marble.payload()}'"
            nhash = marble.payload()
            aionObject = AionCore::getAionObjectByHash(MarbleElizabeth.new(marble.filepath()), nhash)
            location = "/Users/pascal/Desktop/#{aionObject["name"]}"
            return if !File.exists?(location)
            LucilleCore::removeFileSystemLocation(location)
            return
        end
        raise "[error: 456c8df0-efb7-4588-b30d-7884b33442b9]"
    end

    # Marbles::edit(marble)
    def self.edit(marble)

        if marble.type() == "Line" then
            line = LucilleCore::askQuestionAnswerAsString("line: ")
            return nil if line == ""
            marble.set("description", line)
            marble.set("payload", "")
            return
        end
        if marble.type() == "Url" then
            description = LucilleCore::askQuestionAnswerAsString("description (empty for not changing): ")
            if description != "" then
                marble.set("description", description)
            end  
            url = LucilleCore::askQuestionAnswerAsString("url: ")
            if url != "" then
                marble.set("payload", url)
            end
            return
        end
        if marble.type() == "Text" then
            description = LucilleCore::askQuestionAnswerAsString("description (empty for not changing): ")
            if description != "" then
                marble.set("description", description)
            end
            nhash = marble.payload()
            text1 = MarbleElizabeth.new(marble.filepath()).readBlobErrorIfNotFound(nhash)
            text2 = Utils::editTextSynchronously(text1)
            payload = MarbleElizabeth.new(marble.filepath()).commitBlob(text2)
            marble.set("payload", payload)
            return
        end
        if marble.type() == "ClickableType" then
            description = LucilleCore::askQuestionAnswerAsString("description (empty for not changing): ")
            if description != "" then
                marble.set("description", description)
            end
            filenameOnTheDesktop = LucilleCore::askQuestionAnswerAsString("filename (on Desktop): ")
            filepath = "/Users/pascal/Desktop/#{filenameOnTheDesktop}"
            if File.exists?(filepath) then
                nhash = MarbleElizabeth.new(marble.filepath()).commitBlob(IO.read(filepath)) # bad choice, this file could be large
                dottedExtension = File.extname(filenameOnTheDesktop)
                payload = "#{nhash}|#{dottedExtension}"
                marble.set("payload", payload)
            else
                puts "Could not find file: #{filepath}"
            end
            return
        end
        if marble.type() == "AionPoint" then
            description = LucilleCore::askQuestionAnswerAsString("description (empty for not changing): ")
            if description != "" then
                marble.set("description", description)
            end
            locationNameOnTheDesktop = LucilleCore::askQuestionAnswerAsString("location name (on Desktop): ")
            location = "/Users/pascal/Desktop/#{locationNameOnTheDesktop}"
            if File.exists?(location) then
                payload = AionCore::commitLocationReturnHash(MarbleElizabeth.new(marble.filepath()), location)
                marble.set("payload", payload)
            else
                puts "Could not find file: #{filepath}"
            end
            return
        end
        raise "[error: 707CAFD7-46CF-489B-B829-5F4816C4911D]"
    end

    # Marbles::transmute(marble)
    def self.transmute(marble)
        puts "Marbles::transmute(marble) is not implemented yet"
        LucilleCore::pressEnterToContinue()
    end
end

class MarblesFsck
    # MarblesFsck::fsckMarble(marble)
    def self.fsckMarble(marble)

        puts "fsck: #{marble.filepath()} (#{marble.domain()}, #{marble.type()})"

        filepath = marble.filepath()

        raise "[error: f88fcaad-2882-4fd6-ac1e-a85a83f761b6] ; filepath: #{filepath}" if marble.uuid().nil?
        raise "[error: 5ff068b9-b9fb-4826-a6ad-398d8b0709bd] ; filepath: #{filepath}" if marble.unixtime().nil?
        raise "[error: 6d283c5e-3c50-45ef-8c26-2e10a563fb53] ; filepath: #{filepath}" if marble.domain().nil?

        if !["anniversaries", "waves", "quarks"].include?(marble.domain()) then
            raise "[error: eacdf935-09d1-4e64-a16f-49c5de81c775] ; filepath: #{filepath}"
        end

        raise "[error: dfb12670-1391-4cb1-ba4f-0541b77aad9b] ; filepath: #{filepath}" if marble.description().nil?
        raise "[error: bf1662b8-b1aa-4610-ae17-9c3992a0e24d] ; filepath: #{filepath}" if marble.type().nil?

        if !["Line", "Url", "Text", "ClickableType", "AionPoint"].include?(marble.type()) then
            raise "[error: 2ca6437e-5566-41d5-8cc9-620d0623bed9] ; filepath: #{filepath}"
        end

        raise "[error: 672db530-20ca-4981-ab4b-0c7b832e205b] ; filepath: #{filepath}" if marble.payload().nil?

        if marble.domain() == "anniversaries" then
            raise "[error: 0912e41d-676b-4b54-82ec-fb45698fd902] ; filepath: #{filepath}" if marble.getOrNull("startdate").nil?
            raise "[error: 52e24a4f-6a12-4d76-ae4c-94fce3a88a87] ; filepath: #{filepath}" if marble.getOrNull("repeatType").nil?
            raise "[error: dfbe3fb4-d4a9-4e78-bb0f-4d3e00a06618] ; filepath: #{filepath}" if marble.getOrNull("lastCelebrationDate").nil?
        end

        if marble.domain() == "waves" then
            raise "[error: b4ea09e4-db79-416c-b3da-857305e37e46] ; filepath: #{filepath}" if marble.getOrNull("repeatType").nil?
            raise "[error: 38eec138-5ffe-44c5-a2bc-6b13c9bb4f60] ; filepath: #{filepath}" if marble.getOrNull("repeatValue").nil?
            raise "[error: fda08d22-406e-4dc4-89f7-db590b10db8c] ; filepath: #{filepath}" if marble.getOrNull("lastDoneDateTime").nil?
        end

        if marble.type() == "Line" then
            return
        end

        if marble.type() == "Url" then
            if !marble.payload().start_with?("http") then
                raise "[error: 4f2bab70-1ed5-476a-bd12-402355bbdb6b] ; filepath: #{filepath}"
            end
            return
        end

        if marble.type() == "Text" then
            if marble.getOrNull(marble.payload()).nil? then
                raise "[error: f220bac1-4ab1-40df-b751-7573d3adc685] ; filepath: #{filepath}"
            end
            return
        end
        if marble.type() == "ClickableType" then
            nhash = marble.payload().split("|").first
            if marble.getOrNull(nhash).nil? then
                raise "[error: c195269a-264b-4a0b-b1d8-fb0175c12cbf] ; filepath: #{filepath}"
            end
            return
        end 
        if marble.type() == "AionPoint" then
            nhash = marble.payload()
            status = AionFsck::structureCheckAionHash(MarbleElizabeth.new(marble.filepath()), nhash)
            if !status then
                raise "[error: 53BBC142-23CA-4939-9691-32F7C6FC9C65] ; filepath: #{filepath}"
            end
            return
        end
        raise "[cfe763bb-013b-4ae6-a611-935dca16260b: #{marble.filepath()}]"
    end

    # MarblesFsck::fsck()
    def self.fsck()
        Marbles::domains()
            .map{|domain| Marbles::marblesOfGivenDomainInOrder(domain) }
            .flatten
            .each{|marble|
                next if KeyValueStore::flagIsTrue(nil, "84acdcb8-ecac-4527-8cfa-aa2503148839:#{marble.filepath()}:#{File.mtime(marble.filepath())}")
                MarblesFsck::fsckMarble(marble)
                KeyValueStore::setFlagTrue(nil, "84acdcb8-ecac-4527-8cfa-aa2503148839:#{marble.filepath()}:#{File.mtime(marble.filepath())}")
            }
    end
end