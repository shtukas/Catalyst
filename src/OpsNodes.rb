
# encoding: UTF-8

class OpsNodes

    # OpsNodes::nodes()
    def self.nodes()
        NyxObjects2::getSet("abb20581-f020-43e1-9c37-6c3ef343d2f5")
    end

    # OpsNodes::make(name1)
    def self.make(name1)
        {
            "uuid"     => SecureRandom.hex,
            "nyxNxSet" => "abb20581-f020-43e1-9c37-6c3ef343d2f5",
            "unixtime" => Time.new.to_f,
            "name"     => name1
        }
    end

    # OpsNodes::issue(name1)
    def self.issue(name1)
        node = OpsNodes::make(name1)
        NyxObjects2::put(node)
        node
    end

    # OpsNodes::issueListingInteractivelyOrNull()
    def self.issueListingInteractivelyOrNull()
        name1 = LucilleCore::askQuestionAnswerAsString("ops node name: ")
        return nil if name1 == ""
        OpsNodes::issue(name1)
    end

    # OpsNodes::selectOneExistingListingOrNull()
    def self.selectOneExistingListingOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("ops node", OpsNodes::nodes(), lambda{|node| OpsNodes::toString(node) })
    end

    # OpsNodes::selectOneExistingOrNewListingOrNull()
    def self.selectOneExistingOrNewListingOrNull()
        node = OpsNodes::selectOneExistingListingOrNull()
        return node if node
        return nil if !LucilleCore::askQuestionAnswerAsBoolean("no ops node selected, create a new one ? ")
        OpsNodes::issueListingInteractivelyOrNull()
    end

    # OpsNodes::setTargetOrdinal(node, target, ordinal)
    def self.setTargetOrdinal(node, target, ordinal)
        KeyValueStore::set(nil, "60d47387-cdd4-44f1-a334-904c2b7c4b5c:#{node["uuid"]}:#{target["uuid"]}", ordinal)
    end

    # OpsNodes::getTargetOrdinal(node, target)
    def self.getTargetOrdinal(node, target)
        ordinal = KeyValueStore::getOrNull(nil, "60d47387-cdd4-44f1-a334-904c2b7c4b5c:#{node["uuid"]}:#{target["uuid"]}")
        if ordinal then
            return ordinal.to_f
        end
        ordinals = Arrows::getTargetsForSource(node)
                    .map{|t| KeyValueStore::getOrNull(nil, "60d47387-cdd4-44f1-a334-904c2b7c4b5c:#{node["uuid"]}:#{t["uuid"]}") }
                    .compact
                    .map{|o| o.to_f }
        ordinal = ([0] + ordinals).max + 1
        KeyValueStore::set(nil, "60d47387-cdd4-44f1-a334-904c2b7c4b5c:#{node["uuid"]}:#{target["uuid"]}", ordinal)
        ordinal
    end

    # OpsNodes::toString(node)
    def self.toString(node)
        "[ops node] #{node["name"]}"
    end

    # OpsNodes::landing(node)
    def self.landing(node)

        mx = LCoreMenuItemsNX2.new()

        lambdaDisplay = lambda {

            node = NyxObjects2::getOrNull(node["uuid"])

            mx.reset()

            puts OpsNodes::toString(node).green
            puts "uuid: #{node["uuid"]}".yellow

            sources = Arrows::getSourcesForTarget(node)
            puts "" if !sources.empty?
            sources.each{|source|
                mx.item(
                    "source: #{GenericNyxObject::toString(source)}",
                    lambda { GenericNyxObject::landing(source) }
                )
            }

            targets = Arrows::getTargetsForSource(node)
            targets = targets.select{|target| !GenericNyxObject::isTag(target) }
            targets = GenericNyxObject::applyDateTimeOrderToObjects(targets)
            puts "" if !targets.empty?
            targets
                .each{|target|
                    mx.item(
                        "target ( #{"%6.3f" % OpsNodes::getTargetOrdinal(node, target)} ) #{GenericNyxObject::toString(target)}",
                        lambda { GenericNyxObject::landing(target) }
                    )
                }

        }

        lambdaHelpDisplay = lambda {
            [
                "-> rename",
                "-> add datapoint",
                "-> set target ordinal",
                "-> json object",
                "-> destroy node"
            ].join("\n")
        }

        lambdaPromptInterpreter = lambda { |command|

            node = NyxObjects2::getOrNull(node["uuid"])

            if Miscellaneous::isInteger(command) then
                mx.executeFunctionAtPositionGetValueOrNull(command.to_i)
                return
            end

            if command == "rename" then
                name1 = Miscellaneous::editTextSynchronously(node["name"]).strip
                return if name1 == ""
                node["name"] = name1
                NyxObjects2::put(node)
                OpsNodes::removeSetDuplicates()
                return
            end

            if command == "add datapoint" then
                datapoint = Datapoints::makeNewDatapointOrNull()
                return if datapoint.nil?
                Arrows::issueOrException(node, datapoint)
                return
            end

            if command == "set target ordinal" then
                target = LucilleCore::selectEntityFromListOfEntitiesOrNull("target", Arrows::getTargetsForSource(node), lambda{|t| GenericNyxObject::toString(t) })
                return if target.nil?
                ordinal = LucilleCore::askQuestionAnswerAsString("ordinal: ").to_i
                OpsNodes::setTargetOrdinal(node, target, ordinal)
                return
            end

            if command == "json object" then
                puts JSON.pretty_generate(node)
                LucilleCore::pressEnterToContinue()
                return
            end

            if command == "destroy node" then
                if LucilleCore::askQuestionAnswerAsBoolean("Are you sure you want to destroy ops node: '#{OpsNodes::toString(node)}': ") then
                    NyxObjects2::destroy(node)
                end
                return
            end
        }

        lambdaStillGoing = lambda {
            !NyxObjects2::getOrNull(node["uuid"]).nil?
        }

        ProgramNx::Nx01(lambdaDisplay, lambdaHelpDisplay, lambdaPromptInterpreter, lambdaStillGoing)
    end

    # OpsNodes::main()
    def self.main()
        loop {
            system("clear")
            ms = LCoreMenuItemsNX1.new()

            ms.item("ops nodes dive",lambda { 
                loop {
                    nodes = OpsNodes::nodes()
                    node = LucilleCore::selectEntityFromListOfEntitiesOrNull("ops node", nodes, lambda{|node| OpsNodes::toString(node) })
                    return if node.nil?
                    OpsNodes::landing(node)
                }
            })

            ms.item("make new ops node",lambda { OpsNodes::issueListingInteractivelyOrNull() })

            status = ms.promptAndRunSandbox()
            break if !status
        }
    end
end