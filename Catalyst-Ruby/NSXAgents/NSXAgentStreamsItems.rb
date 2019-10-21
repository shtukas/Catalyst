#!/usr/bin/ruby

# encoding: UTF-8
require "/Users/pascal/Galaxy/Software/Misc-Common/Ruby-Libraries/LucilleCore.rb"
require 'securerandom'
# SecureRandom.hex    #=> "eb693ec8252cd630102fd0d0fb7c3485"
# SecureRandom.hex(4) #=> "eb693123"
# SecureRandom.uuid   #=> "2d931510-d99f-494a-8c67-87feb05e1594"
require "time"

require "/Users/pascal/Galaxy/Software/Misc-Common/Ruby-Libraries/KeyValueStore.rb"
=begin
    KeyValueStore::setFlagTrue(repositorylocation or nil, key)
    KeyValueStore::setFlagFalse(repositorylocation or nil, key)
    KeyValueStore::flagIsTrue(repositorylocation or nil, key)

    KeyValueStore::set(repositorylocation or nil, key, value)
    KeyValueStore::getOrNull(repositorylocation or nil, key)
    KeyValueStore::getOrDefaultValue(repositorylocation or nil, key, defaultValue)
    KeyValueStore::destroy(repositorylocation or nil, key)
=end

# -------------------------------------------------------------------------------------

class NSXAgentStreamsItems

    # NSXAgentStreamsItems::agentuid()
    def self.agentuid()
        "d2de3f8e-6cf2-46f6-b122-58b60b2a96f1"
    end

    # NSXAgentStreamsItems::getObjects()
    def self.getObjects()
        NSXStreamsUtils::getStreamItemsCatalystObjectsForDisplay()
    end

    # NSXAgentStreamsItems::getAllObjects()
    def self.getAllObjects()
        NSXStreamsUtils::getAllStreamItemsCatalystObjects()
    end

    # NSXAgentStreamsItems::getObjectByUUIDOrNull(objectuuid)
    def self.getObjectByUUIDOrNull(objectuuid)
        NSXAgentStreamsItems::getAllObjects()
            .select{|object| object["uuid"] == objectuuid }
            .first
    end

    # NSXAgentStreamsItems::stopItem(objectuuid, item, isLocalCommand)
    def self.stopItem(objectuuid, item, isLocalCommand)
        return if !NSXRunner::isRunning?(objectuuid)
        timespanInSeconds = NSXRunner::stop(objectuuid)
        NSXRunTimes::addPoint(item["streamuuid"], Time.new.to_i, timespanInSeconds)
        NSXRunTimes::addPoint(item["uuid"], Time.new.to_i, timespanInSeconds)
        if isLocalCommand then
            NSXMultiInstancesWrite::sendEventToDisk({
                "instanceName" => NSXMiscUtils::instanceName(),
                "eventType"    => "MultiInstanceEventType:RunTimesPoint",
                "payload"      => {
                    "uuid"          => SecureRandom.hex,
                    "collectionuid" => item["streamuuid"],
                    "unixtime"      => Time.new.to_i,
                    "algebraicTimespanInSeconds" => timespanInSeconds
                }
            })
            NSXMultiInstancesWrite::sendEventToDisk({
                "instanceName" => NSXMiscUtils::instanceName(),
                "eventType"    => "MultiInstanceEventType:RunTimesPoint",
                "payload"      => {
                    "uuid"          => SecureRandom.hex,
                    "collectionuid" => item["uuid"],
                    "unixtime"      => Time.new.to_i,
                    "algebraicTimespanInSeconds" => timespanInSeconds
                }
            })
        end
    end

    # NSXAgentStreamsItems::processObjectAndCommand(objectuuid, command, isLocalCommand)
    def self.processObjectAndCommand(objectuuid, command, isLocalCommand)
        item = NSXStreamsUtils::getStreamItemByUUIDOrNull(objectuuid)
        return if item.nil?
        if command == "start" then
            return if NSXRunner::isRunning?(objectuuid)
            NSXRunner::start(objectuuid)
            return
        end
        if command == "stop" then
            return if !NSXRunner::isRunning?(objectuuid)
            NSXAgentStreamsItems::stopItem(objectuuid, item, isLocalCommand)
            return
        end
        if command == "open" then
            genericContentItem = NSXGenericContents::viewGenericContentItemReturnUpdatedItemOrNull(item["generic-content-item"])
            if genericContentItem then
                item["generic-content-item"] = genericContentItem
                NSXStreamsUtils::commitItemToDisk(item)
            end
            return
        end
        if command == "folder" then
            folderpath = NSXGenericContents::resolveFoldernameToFolderpathOrNull(item["generic-content-item"]["parent-foldername"])
            return if folderpath.nil?
            system("open '#{folderpath}'")
            return
        end
        if command == "done" then
            NSXAgentStreamsItems::stopItem(objectuuid, item, isLocalCommand)
            NSXStreamsUtils::destroyItem(item)
            if isLocalCommand then
                NSXMultiInstancesWrite::sendEventToDisk({
                    "instanceName" => NSXMiscUtils::instanceName(),
                    "eventType"    => "MultiInstanceEventType:CatalystObjectUUID+Command",
                    "payload"      => {
                        "objectuuid" => objectuuid,
                        "command"    => "done"
                    }
                })
            end
            nsx1309_removeItemIdentifiedById(item["uuid"])
            return
        end
        if command == "recast" then
            item = NSXStreamsUtils::recastStreamItem(item)
            NSXStreamsUtils::commitItemToDisk(item)
            nsx1309_removeItemIdentifiedById(item["uuid"])
            return
        end
        if command == "push" then
            item["ordinal"] = NSXMiscUtils::getNewEndOfQueueStreamOrdinal()
            NSXStreamsUtils::commitItemToDisk(item)
            nsx1309_removeItemIdentifiedById(item["uuid"])
            return
        end
    end
end

begin
    NSXBob::registerAgent(
        {
            "agent-name"  => "NSXAgentStreamsItems",
            "agentuid"    => NSXAgentStreamsItems::agentuid(),
        }
    )
rescue
end
