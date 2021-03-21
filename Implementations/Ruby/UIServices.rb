# encoding: UTF-8

class DisplayGroups

    # DisplayGroups::fundamentalGroup()
    def self.fundamentalGroup()
        uuid = "7945614c-954a-4c7d-9847-4b67e9b28d56"
        {
            "uuid"             => uuid,
            "completionRatio"  => 0, # this always has priority
            "DisplayItemsNS16" => Calendar::displayItemsNS16() + Anniversaries::displayItemsNS16() + Waves::displayItemsNS16(uuid)
        }
    end

    # DisplayGroups::groupsInOrder()
    def self.groupsInOrder()
        ([DisplayGroups::fundamentalGroup()] + [Tasks::displayGroup()] + DxThreadsUIUtils::displayGroups() + [VideoStream::displayGroup()])
            .sort{|d1, d2| d1["completionRatio"] <=> d2["completionRatio"]}
    end
end

class UIServices

    # UIServices::explore()
    def self.explore()
        loop {
            system("clear")
            typex = NyxClassifiers::interactivelySelectClassifierTypeXOrNull()
            break if typex.nil?
            loop {
                system("clear")
                classifiers = NyxClassifiers::getClassifierDeclarations()
                                .select{|classifier| classifier["type"] == typex["type"] }
                                .sort{|c1, c2| c1["unixtime"] <=> c2["unixtime"] }
                classifier = CatalystUtils::selectOneOrNull(classifiers, lambda{|classifier| NyxClassifiers::toString(classifier) })
                break if classifier.nil?
                NyxClassifiers::landing(classifier)
            }
        }
    end

    # UIServices::servicesFront()
    def self.servicesFront()
        loop {
            system("clear")

            ms = LCoreMenuItemsNX1.new()

            ms.item("Calendar", lambda { Calendar::main() })

            ms.item("Anniversaries", lambda { Anniversaries::main() })

            ms.item("Waves", lambda { Waves::main() })

            ms.item("DxThreads", lambda { DxThreads::main() })

            puts ""

            ms.item("new wave", lambda { Waves::issueNewWaveInteractivelyOrNull() })            

            ms.item("new quark", lambda { Quarks::getQuarkPossiblyArchitectedOrNull(nil, nil) })    

            puts ""

            ms.item("dangerously edit a TodoCoreData object by uuid", lambda { 
                uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
                return if uuid == ""
                object = TodoCoreData::getOrNull(uuid)
                return if object.nil?
                object = CatalystUtils::editTextSynchronously(JSON.pretty_generate(object))
                object = JSON.parse(object)
                TodoCoreData::put(object)
            })

            ms.item("dangerously delete a TodoCoreData object by uuid", lambda { 
                uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
                object = TodoCoreData::getOrNull(uuid)
                return if object.nil?
                puts JSON.pretty_generate(object)
                return if !LucilleCore::askQuestionAnswerAsBoolean("delete ? : ")
                TodoCoreData::destroy(object)
            })

            puts ""

            status = ms.promptAndRunSandbox()
            break if !status
        }
    end

    # UIServices::todoListingOnce()
    def self.todoListingOnce()

        CatalystUtils::importFromLucilleInbox()

        Calendar::dailyBriefingIfNotDoneToday()

        Anniversaries::dailyBriefingIfNotDoneToday()

        displayGroups = DisplayGroups::groupsInOrder()

        system("clear")
        vspaceleft = CatalystUtils::screenHeight()-6

        puts ""

        puts JSON.generate(JSON.parse(`#{CatalystHaskell::execPath()}`))
        puts ""
        vspaceleft = vspaceleft - 2

        RunningItems::displayLines().each{|line|
            puts line
            vspaceleft = vspaceleft - 1
        }

        items = displayGroups
                    .map{|dg| 
                        dg["DisplayItemsNS16"].map{|item|
                            item["x-completion-ratio"] = dg["completionRatio"]
                            item
                        }
                    }
                    .flatten
                    .select{|item| DoNotShowUntil::isVisible(item["uuid"]) }

        items.each_with_index{|item, indx|
            announce = "#{"%3d" % indx} [#{"%6.3f" % item["x-completion-ratio"]}] #{item["announce"]}"
            vspaceleft = vspaceleft - CatalystUtils::verticalSize(announce)
            next if vspaceleft < 0
            puts announce
        }

        if items.empty? then
            puts "Monitoring..."
            # we are going to start a monitor that check for new values and let us know
            thread_2131 = Thread.new {
                loop {
                    sleep 120
                    displayGroups = DisplayGroups::groupsInOrder()
                    items = displayGroups
                                .map{|dg| 
                                    dg["DisplayItemsNS16"].map{|item|
                                        item["x-completion-ratio"] = dg["completionRatio"]
                                        item
                                    }
                                }
                                .flatten
                                .select{|item| DoNotShowUntil::isVisible(item["uuid"]) }
                    next if items.empty?
                    CatalystUtils::onScreenNotification("Catalyst", "Item(s) showed up")
                }
            }
        end

        context = {"items" => items}
        actions = [
            [".", ". (reload)", lambda{|context, command|
                "2:565a0e56-reloop-domain"
            }, true],
            ["..", ".. (access top item)", lambda{|context, command|
                context["items"][0]["lambda"].call()
                "2:565a0e56-reloop-domain"
            }, !context["items"].empty?],
            ["++", "++ # Postpone top item by an hour", lambda{|context, command|
                DoNotShowUntil::setUnixtime(context["items"][0]["uuid"], Time.new.to_i+3600)
                "2:565a0e56-reloop-domain"
            }, !context["items"].empty?],
            ["+ *", "+ <weekdayname> # Postpone top item", lambda{|context, command|
                _, weekdayname = Interpreting::tokenizer(command)
                unixtime = CatalystUtils::codeToUnixtimeOrNull("+#{weekdayname}")
                return "2:565a0e56-reloop-domain" if unixtime.nil?
                item = context["items"][0]
                DoNotShowUntil::setUnixtime(item["uuid"], unixtime)
                "2:565a0e56-reloop-domain"
            }, !context["items"].empty?],
            ["+ * *", "+ <float> <datecode unit> # Postpone top item", lambda{|context, command|
                _, amount, unit = Interpreting::tokenizer(command)
                unixtime = CatalystUtils::codeToUnixtimeOrNull("+#{amount}#{unit}")
                return "2:565a0e56-reloop-domain" if unixtime.nil?
                item = context["items"][0]
                DoNotShowUntil::setUnixtime(item["uuid"], unixtime)
                "2:565a0e56-reloop-domain"
            }, !context["items"].empty?],
            ["select *", "select <n>", lambda{|context, command|
                _, ordinal = Interpreting::tokenizer(command)
                ordinal = ordinal.to_i
                item = context["items"][ordinal]
                return "2:565a0e56-reloop-domain" if item.nil?
                item["lambda"].call()
                "2:565a0e56-reloop-domain"
            }, !context["items"].empty?],
            ["start", "start", lambda{|context, command|
                dxthread = DxThreads::selectOneExistingDxThreadOrNull()
                return "2:565a0e56-reloop-domain" if dxthread.nil?
                op = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", ["Start DxThread", "Start Quark"])
                return if op.nil?
                if op == "Start DxThread" then
                    RunningItems::start(DxThreads::toString(dxthread), [dxthread["uuid"]])
                end
                if op == "Start Quark" then
                    quarks = DxThreadQuarkMapping::dxThreadToQuarksInOrder(dxthread, 20)
                    quark = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", quarks, lambda{|quark| Quarks::toString(quark) })
                    return if quark.nil?
                    DxThreadsUIUtils::runDxThreadQuarkPair(dxthread, quark)
                end
                "2:565a0e56-reloop-domain"
            }, true],
            ["stop", "stop", lambda{|context, command|
                item = LucilleCore::selectEntityFromListOfEntitiesOrNull("item", RunningItems::items(), lambda{|item| item["announce"] })
                return true if item.nil?
                timespan = Time.new.to_f - item["start"]
                item["bankAccounts"].each{|account|
                    puts "putting #{timespan} seconds to account: #{account}"
                    Bank::put(account, timespan)
                }
                RunningItems::destroy(item)
                "2:565a0e56-reloop-domain"
            }, true],
            ["/", "/", lambda{|context, command|
                UIServices::servicesFront()
                "2:565a0e56-reloop-domain"
            }, true],
            ["nyx", "nyx", lambda{|context, command|
                UIServices::nyxMain()
                "2:565a0e56-reloop-domain"
            }, true],
            ["video-stream-pause", "video-stream-pause", lambda{|context, command|
                VideoStream::issueHidePing()
                "2:565a0e56-reloop-domain"
            }, !context["items"].empty?]
        ]
        .select{|item| item[3] }

        existcode = Interpreting::interpreter(context, actions, {
            "displayHelpInLineAtIntialization" => true
        })

        # With the above actions we only have "2:565a0e56-reloop-domain"
        # if exitcode == "3:d9e2b6d5-exit-domain" then

        if thread_2131 then
            thread_2131.exit
        end

        # end
    end

    # UIServices::todoListingMain()
    def self.todoListingMain()
        Thread.new {
            loop {
                sleep 120
                if ProgrammableBooleans::trueNoMoreOftenThanEveryNSeconds("f5f52127-c140-4c59-85a2-8242b546fe1f", 3600) then
                    system("#{File.dirname(__FILE__)}/../../vienna-import")
                end
            }
        }
        loop {
            UIServices::todoListingOnce()
        }
    end

    # UIServices::nyxMain()
    def self.nyxMain()
        loop {
            system("clear")
            puts "Nyx 🗺"
            ops = ["Search", "Explore", "Issue New"]
            operation = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", ops)
            break if operation.nil?
            if operation == "Search" then
                Patricia::generalSearchLoop()
            end
            if operation == "Explore" then
                UIServices::explore()
            end
            if operation == "Issue New" then
                node = Patricia::makeNewNodeOrNull()
                next if node.nil?
                Patricia::landing(node)
            end
        }
    end
end


