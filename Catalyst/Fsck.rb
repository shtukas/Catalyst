#!/Users/pascal/.rvm/rubies/ruby-2.5.1/bin/ruby

# encoding: UTF-8

require 'json'
# JSON.pretty_generate(object)

require 'time'
require 'date'
require 'colorize'

require 'securerandom'
# SecureRandom.hex    #=> "eb693ec8252cd630102fd0d0fb7c3485"
# SecureRandom.hex(4) #=> "eb693123"
# SecureRandom.uuid   #=> "2d931510-d99f-494a-8c67-87feb05e1594"

require 'fileutils'
# FileUtils.mkpath '/a/b/c'
# FileUtils.cp(src, dst)
# FileUtils.mv 'oldname', 'newname'
# FileUtils.rm(path_to_image)
# FileUtils.rm_rf('dir/to/remove')

require 'digest/sha1'
# Digest::SHA1.hexdigest 'foo'
# Digest::SHA1.file(myFile).hexdigest

require 'find'
require 'thread'

require "/Users/pascal/Galaxy/LucilleOS/Libraries/Ruby-Libraries/LucilleCore.rb"

require "/Users/pascal/Galaxy/LucilleOS/Libraries/Ruby-Libraries/KeyValueStore.rb"
=begin
    KeyValueStore::setFlagTrue(repositorylocation or nil, key)
    KeyValueStore::setFlagFalse(repositorylocation or nil, key)
    KeyValueStore::flagIsTrue(repositorylocation or nil, key)

    KeyValueStore::set(repositorylocation or nil, key, value)
    KeyValueStore::getOrNull(repositorylocation or nil, key)
    KeyValueStore::getOrDefaultValue(repositorylocation or nil, key, defaultValue)
    KeyValueStore::destroy(repositorylocation or nil, key)
=end

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/DoNotShowUntil.rb"
#    DoNotShowUntil::setUnixtime(uid, unixtime)
#    DoNotShowUntil::isVisible(uid)

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/Common.rb"

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/DataIntegrityOfficer.rb"

# -----------------------------------------------------------------

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/OpenCycles/OpenCycles.rb"

# -------------------------------------------------------------------------

def specialCircumstancesGetOrNull(uuid)
    folderPath = "/Volumes/EnergyGrid/Data/Pascal/Snapshots/Lucille18-Galaxy/2020/20200528-091604-074494/Lucille18-Galaxy/DataBank/Catalyst/Cubes"
    filepath = "#{folderPath}/#{uuid}.json"
    return nil if !File.exists?(filepath)
    JSON.parse(IO.read(filepath))
end

class Fsck

    # Fsck::checkOpenCycle(opencycle)
    def self.checkOpenCycle(opencycle)
        puts "[checking open cycle] #{opencycle["uuid"]}"
        targetuuid = opencycle["targetuuid"]
        entity = Nyx::getOrNull(targetuuid)
        if entity.nil? then
            puts "[error] open cycle".red
            puts JSON.pretty_generate(opencycle)
            puts "... points as an unkown entity".red
            exit
        end
        supportedTypes = [
            "starlight-node-8826cbad-e54e-4e78-bf7d-28c9c5019721",
            "cube-933c2260-92d1-4578-9aaf-cd6557c664c6",
            "quark-6af2c9d7-67b5-4d16-8913-c5980b0453f2"
        ]
        if !supportedTypes.include?(entity["nyxType"]) then
            puts "[error] open cycle".red
            puts JSON.pretty_generate(opencycle)
            puts "... points as an unsupported entity".red
            puts JSON.pretty_generate(entity)
            exit
        end
    end

    # Fsck::run()
    def self.run()
        puts "-> Starting Catalyst Integrity Check"

        opencycles = Nyx::objects("open-cycle-9fa96e3c-d140-4f82-a7f0-581c918e9e6f")
        if opencycles.empty? then
            puts "[info] I could not find open cycles"
        end
        opencycles.each{|opencycle|
            Fsck::checkOpenCycle(opencycle)
        }

        puts "-> Completed Catalyst Integrity Check"
    end
end

