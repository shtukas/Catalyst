#!/usr/bin/ruby

# encoding: UTF-8

require "/Galaxy/local-resources/Ruby-Libraries/LucilleCore.rb"

require 'json'

=begin

  -- reading the string and building the object
     dataset = IO.read($dataset_location)
     JSON.parse(dataset)

  -- printing the string
     file.puts JSON.pretty_generate(dataset)

=end

require 'date'

require 'digest/sha1'
# Digest::SHA1.hexdigest 'foo'
# Digest::SHA1.file(myFile).hexdigest

require 'securerandom'
# SecureRandom.hex    #=> "eb693ec8252cd630102fd0d0fb7c3485"
# SecureRandom.hex(4) #=> "eb693123"
# SecureRandom.uuid   #=> "2d931510-d99f-494a-8c67-87feb05e1594"

require 'fileutils'
# FileUtils.mkpath '/a/b/c'
# FileUtils.cp(src, dst)
# FileUtils.mv('oldname', 'newname')
# FileUtils.rm(path_to_image)
# FileUtils.rm_rf('dir/to/remove')

require 'find'

require_relative "Commons.rb"

require_relative "Wave.rb"
require_relative "Ninja.rb"
require_relative "Stream.rb"
require_relative "Today.rb"
require_relative "TimeCommitments.rb"
require_relative "StreamKiller.rb"
require_relative "GuardianTime.rb"
require_relative "Kimchee.rb"
require_relative "Vienna.rb"
require_relative "ViennaKiller.rb"
require_relative "OpenProjects.rb"

# ----------------------------------------------------------------------

# CatalystObjects::all()

class CatalystObjects
    def self.all()

        sources = [
            ["Wave", lambda { WaveInterface::getCatalystObjects() }],
            ["Ninja", lambda { Ninja::getCatalystObjects() }],
            ["Stream", lambda { Stream::getCatalystObjectsFirst6() }],
            ["Today", lambda { Today::getCatalystObjects() }],
            ["TimeCommitments", lambda { TimeCommitments::getCatalystObjects() }],
            ["StreamKiller", lambda { StreamKiller::getCatalystObjects() }],
            ["GuardianTime", lambda { GuardianTime::getCatalystObjects() }],
            ["Kimchee", lambda{ Kimchee::getCatalystObjects() }],
            ["Vienna", lambda{ Vienna::getCatalystObjects() }],
            ["ViennaKiller", lambda{ ViennaKiller::getCatalystObjects() }],
            ["OpenProjects", lambda{ OpenProjects::getCatalystObjects() }]
        ]

        struct1 = sources.map{|pair|
            startTime = Time.new.to_f
            xobjects  = pair[1].call()
            queryTime = Time.new.to_f - startTime
            {
                "domain"  => pair[0],
                "objects" => xobjects,
                "time"    => queryTime
            }
        }

        objects = struct1.map{|s| s["objects"] }.flatten

        if (xtime = struct1.map{|s| s["time"] }.inject(0, :+)) > 1 then
            offender = struct1.sort{|s1,s2| s1["time"]<=>s2["time"] }.last
            objects << {
                "uuid"                => SecureRandom.hex(4),
                "metric"              => 1,
                "announce"            => "-> #{offender["domain"]} generation is taking too long (#{offender["time"]} seconds)",
                "commands"            => [],
                "command-interpreter" => lambda{ |object, command| }
            }
        end
        
        objects = DoNotShowUntil::transform(objects)
        objects
    end
end

