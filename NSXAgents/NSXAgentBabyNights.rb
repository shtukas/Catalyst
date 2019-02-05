#!/usr/bin/ruby

# encoding: UTF-8
require "/Galaxy/Software/Misc-Common/Ruby-Libraries/LucilleCore.rb"
require 'securerandom'
# SecureRandom.hex    #=> "eb693ec8252cd630102fd0d0fb7c3485"
# SecureRandom.hex(4) #=> "eb693123"
# SecureRandom.uuid   #=> "2d931510-d99f-494a-8c67-87feb05e1594"
require "time"

# -------------------------------------------------------------------------------------

# NSXAgentBabyNights::getObjects()

BABY_NIGHTS_DATA_FOLDER = "#{CATALYST_COMMON_DATABANK_CATALYST_FOLDERPATH}/Agents-Data/BabyNights/data"

class NSXAgentBabyNights

    # NSXAgentBabyNights::agentuuid()
    def self.agentuuid()
        "83837e64-554b-4dd0-a478-04386d8010ea"
    end

    def self.names()
        ["pascal", "tracy", "holidays"]
    end

    def self.getObjects()
        objects = []
        if NSXData::getValueAsStringOrNull(BABY_NIGHTS_DATA_FOLDER, "2b966eeb-1f2c-416c-8aec-bb711b9cc478:#{Time.now.utc.iso8601[0,10]}").nil? then
            object =
                {
                    "uuid"      => "4b9bcf0a",
                    "agentuid"  => self.agentuuid(),
                    "metric"    => 0.97,
                    "announce"  => "👶 Mining",
                    "commands"  => [],
                    "defaultExpression" => "update"
                }
            objects << object
        end
        objects
    end

    def self.processObjectAndCommand(object, command)
        if command == "update" then
            operation = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", ["Update Records", "Exception:"])
            if operation == "Exception:" then
                exception = LucilleCore::askQuestionAnswerAsString("Exception: ")
                puts "👶 Mining Exception: #{exception}"
                LucilleCore::pressEnterToContinue()
                NSXData::setWritableValue(BABY_NIGHTS_DATA_FOLDER, "2b966eeb-1f2c-416c-8aec-bb711b9cc478:#{Time.now.utc.iso8601[0,10]}", "done")
                return
            end
            if operation == "Update Records" then
                data = JSON.parse(IO.read("#{CATALYST_COMMON_DATABANK_CATALYST_FOLDERPATH}/Agents-Data/BabyNights/data.json"))
                xname = LucilleCore::selectEntityFromListOfEntitiesOrNull("Dropping (yesterday morning)", ["pascal", "tracy", "not applicable"])
                if xname!="not applicable" then
                    data[xname] = data[xname]+0.3
                end
                xname = LucilleCore::selectEntityFromListOfEntitiesOrNull("Picking up (yesterday afternoon)", ["pascal", "tracy", "not applicable"])
                if xname!="not applicable" then
                    data[xname] = data[xname]+0.55
                end
                xname = LucilleCore::selectEntityFromListOfEntitiesOrNull("Night", ["pascal", "tracy"])
                data[xname] = data[xname]+1
                puts "👶 Mining [Pascal: #{data["pascal"]}, Tracy: #{data["tracy"]}]"
                if data["pascal"] >= 10 and data["tracy"] >= 10 then
                    data["pascal"] = data["pascal"] - 10 
                    data["tracy"] = data["tracy"] - 10 
                    puts "👶 Mining [Pascal: #{data["pascal"].round(2)}, Tracy: #{data["tracy"].round(2)}]"
                end
                File.open("#{CATALYST_COMMON_DATABANK_CATALYST_FOLDERPATH}/Agents-Data/BabyNights/data.json", "w"){|f| f.puts(JSON.pretty_generate(data)) }
                LucilleCore::pressEnterToContinue()
                NSXData::setWritableValue(BABY_NIGHTS_DATA_FOLDER, "2b966eeb-1f2c-416c-8aec-bb711b9cc478:#{Time.now.utc.iso8601[0,10]}", "done")
            end

        end
    end

    def self.interface()
        puts "Welcome to BabyNights interface"
        operation = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation:", ["Bonus"])
        if operation == "Bonus" then
            xname = LucilleCore::selectEntityFromListOfEntitiesOrNull("name", ["pascal", "tracy"])
            amount = LucilleCore::askQuestionAnswerAsString("Amount?: ").to_f
            data = JSON.parse(IO.read("#{CATALYST_COMMON_DATABANK_CATALYST_FOLDERPATH}/Agents-Data/BabyNights/data.json"))
            data[xname] = data[xname] + amount
            puts "👶 Mining [Pascal: #{data["pascal"].round(2)}, Tracy: #{data["tracy"].round(2)}]"
            File.open("#{CATALYST_COMMON_DATABANK_CATALYST_FOLDERPATH}/Agents-Data/BabyNights/data.json", "w"){|f| f.puts(JSON.pretty_generate(data)) }
            LucilleCore::pressEnterToContinue()
        end
    end

end