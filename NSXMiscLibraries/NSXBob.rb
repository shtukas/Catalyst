
# encoding: UTF-8

$BOB_AGENTS_IDENTITIES = []

class NSXBob

    # NSXBob::registerAgent(data)
    def self.registerAgent(data)
        $BOB_AGENTS_IDENTITIES << data
    end

    # NSXBob::agents()
    def self.agents()
        $BOB_AGENTS_IDENTITIES
    end

    # NSXBob::getAgentDataByAgentUUIDOrNull(agentuuid)
    def self.getAgentDataByAgentUUIDOrNull(agentuuid)
        NSXBob::agents()
            .select{|agentinterface| agentinterface["agentuid"]==agentuuid }
            .first
    end

    # NSXBob::getAgentDataByAgentNameOrNull(agentname)
    def self.getAgentDataByAgentNameOrNull(agentname)
        NSXBob::agents()
            .select{|agentinterface| agentinterface["agent-name"]==agentname }
            .first
    end

end

NSXBob::registerAgent(
    {
        "agent-name"  => "Anniversaries",
        "agentuid"    => "639beee6-c12e-4cb8-bc9a-f7890fa95db0",
        "get-objects" => lambda { NSXAgentAnniversaries::getObjects() },
        "get-objects-all" => lambda { NSXAgentAnniversaries::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentAnniversaries::processObjectAndCommand(object, command) },
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "BackupsMonitor",
        "agentuid"    => "63027c23-6131-4230-b49b-d3f23aa5ff54",
        "get-objects" => lambda { NSXAgentBackupsMonitor::getObjects() },
        "get-objects-all" => lambda { NSXAgentBackupsMonitor::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentBackupsMonitor::processObjectAndCommand(object, command) },
        "interface"   => lambda { NSXAgentBackupsMonitor::interface() }
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "DailyGuardianWork",
        "agentuid"    => "a6d554fd-44bf-4937-8dc6-5c9f1dcdaeba",
        "get-objects" => lambda { NSXAgentDailyGuardianWork::getObjects() },
        "get-objects-all" => lambda { NSXAgentDailyGuardianWork::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentDailyGuardianWork::processObjectAndCommand(object, command) },
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "DailyTimeCommitments",
        "agentuid"    => "8b881a6f-33b7-497a-9293-2aaeefa16c18",
        "get-objects" => lambda { NSXAgentDailyTimeCommitments::getObjects() },
        "get-objects-all" => lambda { NSXAgentDailyTimeCommitments::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentDailyTimeCommitments::processObjectAndCommand(object, command) },
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "DesktopLucilleFile",
        "agentuid"    => "f7b21eb4-c249-4f0a-a1b0-d5d584c03316",
        "get-objects" => lambda { NSXAgentDesktopLucilleFile::getObjects() },
        "get-objects-all" => lambda { NSXAgentDesktopLucilleFile::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentDesktopLucilleFile::processObjectAndCommand(object, command) },
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "Streams",
        "agentuid"    => "d2de3f8e-6cf2-46f6-b122-58b60b2a96f1",
        "get-objects" => lambda { NSXAgentStreams::getObjects() },
        "get-objects-all" => lambda { NSXAgentStreams::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentStreams::processObjectAndCommand(object, command) },
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "VideosStreamConsumptionMonitor",
        "agentuid"    => "6e02cc3f-5342-46b8-b98c-7865b7e163f1",
        "get-objects" => lambda { NSXAgentVideosStreamConsumptionMonitor::getObjects() },
        "get-objects-all" => lambda { NSXAgentVideosStreamConsumptionMonitor::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentVideosStreamConsumptionMonitor::processObjectAndCommand(object, command) },
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "Vienna",
        "agentuid"    => "2ba71d5b-f674-4daf-8106-ce213be2fb0e",
        "get-objects" => lambda { NSXAgentVienna::getObjects() },
        "get-objects-all" => lambda { NSXAgentVienna::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentVienna::processObjectAndCommand(object, command) },
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "Wave",
        "agentuid"    => "283d34dd-c871-4a55-8610-31e7c762fb0d",
        "get-objects" => lambda { NSXAgentWave::getObjects() },
        "get-objects-all" => lambda { NSXAgentWave::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentWave::processObjectAndCommand(object, command) },
    }
)

NSXBob::registerAgent(
    {
        "agent-name"  => "DesktopFilesMonitor",
        "agentuid"    => "ec12c56b-9692-424e-bb17-220b9066407d",
        "get-objects" => lambda { NSXAgentDesktopFilesMonitor::getObjects() },
        "get-objects-all" => lambda { NSXAgentDesktopFilesMonitor::getAllObjects() },
        "object-command-processor" => lambda{ |object, command| NSXAgentDesktopFilesMonitor::processObjectAndCommand(object, command) },
    }
)
