# encoding: UTF-8

# This variable contains the objects of the current display.
# We use it to speed up display after some operations

require 'digest/sha1'
# Digest::SHA1.hexdigest 'foo'
# Digest::SHA1.file(myFile).hexdigest

require 'securerandom'
# SecureRandom.hex    #=> "eb693ec8252cd630102fd0d0fb7c3485"
# SecureRandom.hex(4) #=> "eb693123"
# SecureRandom.uuid   #=> "2d931510-d99f-494a-8c67-87feb05e1594"

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

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/Ping.rb"
=begin 
    Ping::put(uuid, weight)
    Ping::totalOverTimespan(uuid, timespanInSeconds)
    Ping::totalToday(uuid)
=end

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/Mercury.rb"
=begin
    Mercury::postValue(channel, value)
    Mercury::getFirstValueOrNull(channel)
    Mercury::deleteFirstValue(channel)

    Mercury::discardFirstElementsToEnforeQueueSize(channel, size)
    Mercury::discardFirstElementsToEnforceTimeHorizon(channel, unixtime)

    Mercury::getQueueSize(channel)
    Mercury::getAllValues(channel)
=end

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/SectionsType0141.rb"
# SectionsType0141::contentToSections(text)
# SectionsType0141::applyNextTransformationToContent(content)

require "/Users/pascal/Galaxy/LucilleOS/Libraries/Ruby-Libraries/BTreeSets.rb"
=begin
    BTreeSets::values(repositorylocation or nil, setuuid: String): Array[Value]
    BTreeSets::set(repositorylocation or nil, setuuid: String, valueuuid: String, value)
    BTreeSets::getOrNull(repositorylocation or nil, setuuid: String, valueuuid: String): nil | Value
    BTreeSets::destroy(repositorylocation, setuuid: String, valueuuid: String)
=end

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/Quarks.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/Cubes.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/Cliques.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/NyxGarbageCollection.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Nyx/Quarks.rb"

require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Asteroids/Asteroids.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/VideoStream/VideoStream.rb"
require "/Users/pascal/Galaxy/LucilleOS/Applications/Catalyst/Catalyst/Drives.rb"

# ------------------------------------------------------------------------

class Floats

    # Floats::issueFloat()
    def self.issueFloat()
        items = []

        items << [
            "description", 
            lambda {
                description = LucilleCore::askQuestionAnswerAsString("description: ")
                return if description.size == 0
                float = {
                    "id"          => SecureRandom.hex,
                    "unixtime"    => Time.new.to_i,
                    "type"        => "float-description-ff149b92-cf23-49b2-9268-b63f8773eb40",
                    "description" => description
                }
                BTreeSets::set("/Users/pascal/Galaxy/DataBank/Catalyst/Floats", "7B828D25-43D7-4FA2-BCE0-B1EC86ECF27E", float["id"], float)
            }
        ]

        items << [
            "quark (new)", 
            lambda {
                quark = Quarks::issueNewQuarkInteractivelyOrNull()
                return if quark.nil?
                float = {
                    "id"         => SecureRandom.hex,
                    "unixtime"   => Time.new.to_i,
                    "type"       => "float-quark-d442c162-893c-47f8-ba57-b84980a79d59",
                    "quarkuuid"  => quark["uuid"]
                }
                BTreeSets::set("/Users/pascal/Galaxy/DataBank/Catalyst/Floats", "7B828D25-43D7-4FA2-BCE0-B1EC86ECF27E", float["id"], float)
            }
        ]
        items << [
            "clique (new)", 
            lambda {
                clique = Cliques::issueCliqueInteractivelyOrNull()
                return if clique.nil?
                float = {
                    "id"         => SecureRandom.hex,
                    "unixtime"   => Time.new.to_i,
                    "type"       => "float-clique-656a24a8-2acb-417a-b23e-09dc29106f38",
                    "cliqueuuid" => clique["uuid"]
                }
                BTreeSets::set("/Users/pascal/Galaxy/DataBank/Catalyst/Floats", "7B828D25-43D7-4FA2-BCE0-B1EC86ECF27E", float["id"], float)
            }
        ]

        LucilleCore::menuItemsWithLambdas(items)
    end

    # Floats::processFloat(float)
    def self.processFloat(float)
        if float["type"] == "float-description-ff149b92-cf23-49b2-9268-b63f8773eb40" then
            puts "float: #{float["description"]}"
            return if !LucilleCore::askQuestionAnswerAsBoolean("destroy ? ")
            BTreeSets::destroy("/Users/pascal/Galaxy/DataBank/Catalyst/Floats", "7B828D25-43D7-4FA2-BCE0-B1EC86ECF27E", float["id"])
        end
        if float["type"] == "float-quark-d442c162-893c-47f8-ba57-b84980a79d59" then
            quarkuuid = float["quarkuuid"]
            quark = Quarks::getOrNull(quarkuuid)
            if quark.nil? then
                return if !LucilleCore::askQuestionAnswerAsBoolean("destroy ? ")
                BTreeSets::destroy("/Users/pascal/Galaxy/DataBank/Catalyst/Floats", "7B828D25-43D7-4FA2-BCE0-B1EC86ECF27E", float["id"])
                return
            end
            items = []
            items << [
                "(quark) dive", 
                lambda { Quarks::quarkDive(quark) }
            ]
            items << [
                "destroy", 
                lambda {
                    BTreeSets::destroy("/Users/pascal/Galaxy/DataBank/Catalyst/Floats", "7B828D25-43D7-4FA2-BCE0-B1EC86ECF27E", float["id"])
                }
            ]
            LucilleCore::menuItemsWithLambdas(items)
        end
        if float["type"] == "float-clique-656a24a8-2acb-417a-b23e-09dc29106f38" then
            cliqueuuid = float["cliqueuuid"]
            clique = Quarks::getOrNull(cliqueuuid)
            if clique.nil? then
                return if !LucilleCore::askQuestionAnswerAsBoolean("destroy ? ")
                BTreeSets::destroy("/Users/pascal/Galaxy/DataBank/Catalyst/Floats", "7B828D25-43D7-4FA2-BCE0-B1EC86ECF27E", float["id"])
                return
            end
            items = []
            items << [
                "(clique) dive", 
                lambda { Cliques::cliqueDive(clique) }
            ]
            items << [
                "destroy", 
                lambda {
                    BTreeSets::destroy("/Users/pascal/Galaxy/DataBank/Catalyst/Floats", "7B828D25-43D7-4FA2-BCE0-B1EC86ECF27E", float["id"])
                }
            ]
            LucilleCore::menuItemsWithLambdas(items)
        end
    end
end


