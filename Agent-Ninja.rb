#!/usr/bin/ruby

# encoding: UTF-8

require_relative "MiniFIFOQ.rb"
# -------------------------------------------------------------------------------------

NINJA_BINARY_FILEPATH = "/Galaxy/LucilleOS/Binaries/ninja"
NINJA_ITEMS_REPOSITORY_FOLDERPATH = "/Galaxy/DataBank/Ninja/Items"

# Ninja::generalUpgrade()

class NinjaFolderPathFeeder
    def initialize()
        @folderpaths = []
    end
    def next()
        if @folderpaths.empty? then
            @folderpaths = JSON.parse(`ninja api:pending`).shuffle
        end
        @folderpaths.shift
    end
end

$ninjaFolderPathFeeder = NinjaFolderPathFeeder.new()

class NinjaTimestampManager
    def addTimestamp()
        MiniFIFOQ::push("timestamps-5bd4-431b-9eef-24ca1d005a3c", Time.new.to_i)
    end
    def getTimestamps()
        MiniFIFOQ::takeWhile("timestamps-5bd4-431b-9eef-24ca1d005a3c", lambda{|unixtime| (Time.new.to_i - unixtime)>86400 })
        MiniFIFOQ::values("timestamps-5bd4-431b-9eef-24ca1d005a3c")
    end
end

$ninjaTimestampManager = NinjaTimestampManager.new()

class Ninja

    def self.agentuuid()
        "d3d1d26e-68b5-4a99-a372-db8eb6c5ba58"
    end

    def self.interface()
        
    end

    def self.generalUpgrade()
        folderpath = $ninjaFolderPathFeeder.next()
        if folderpath.nil? then
            return []
        end
        metric = 0.20 + 0.4*Math.exp(-$ninjaTimestampManager.getTimestamps().size.to_f/16) + Jupiter::traceToMetricShift("deb58288-31e9-4d20-848d-8ac33d3701ee")
        object = {
            "uuid" => "96287511",
            "agent-uid" => self.agentuuid(),
            "metric" => metric,
            "announce" => "ninja: folderpath: #{File.basename(folderpath)}",
            "commands" => [],
            "item-data" => {
                "ninja-folderpath" => folderpath
            }
        }
        FlockTransformations::addOrUpdateObject(object)
    end

    def self.processObjectAndCommand(object, command)
        folderpath = object["item-data"]["ninja-folderpath"]
        system("ninja api:play-folderpath '#{folderpath}'")
        $ninjaTimestampManager.addTimestamp()
        FlockTransformations::removeObjectIdentifiedByUUID(object["uuid"])
    end
end
