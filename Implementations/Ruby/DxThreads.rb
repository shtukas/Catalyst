# encoding: UTF-8

class DxThreadsTarget
    # DxThreadsTarget::getDxThreadStreamCardinal()
    def self.getDxThreadStreamCardinal()
        DxThreadQuarkMapping::getQuarkUUIDsForDxThreadInOrder(DxThreads::getStream()).size
    end

    # DxThreadsTarget::getIdealDxThreadStreamCardinal()
    def self.getIdealDxThreadStreamCardinal()
        t1 = 1612052387 # 2021-01-26 22:43:56 +0000
        y1 = 3728

        t2 = 1624747436 # 2021-06-26 22:43:56
        y2 = 100

        slope = (y2-y1).to_f/(t2-t1)

        return (Time.new.to_f - t1) * slope + y1
    end
end

class DxThreadsUIUtils

    # DxThreadsUIUtils::runDxThreadQuarkPair(dxthread, quark)
    def self.runDxThreadQuarkPair(dxthread, quark)
        loop {
            element = NereidInterface::getElementOrNull(quark["nereiduuid"])
            if element.nil? then
                puts DxThreads::dxThreadAndTargetToString(dxthread, quark).green
                if LucilleCore::askQuestionAnswerAsBoolean("Should I delete this quark ? ") then
                    Quarks::destroyQuarkAndNereidContent(quark)
                end
                return
            end
            thr = Thread.new {
                sleep 3600
                loop {
                    CatalystUtils::onScreenNotification("Catalyst", "Item running for more than an hour")
                    sleep 60
                }
            }
            t1 = Time.new.to_f
            puts "running: #{DxThreads::dxThreadAndTargetToString(dxthread, quark).green}"
            NereidInterface::accessCatalystEdition(quark["nereiduuid"])
            puts "done (destroy quark and nereid element) | >nyx | >dxthread | landing | / | pause | exit-running  | exit(-stopped) (default)".yellow
            input = LucilleCore::askQuestionAnswerAsString("> ")
            thr.exit
            timespan = Time.new.to_f - t1
            timespan = [timespan, 3600*2].min
            puts "putting #{timespan} seconds to quark: #{Quarks::toString(quark)}"
            Bank::put(quark["uuid"], timespan)
            puts "putting #{timespan} seconds to dxthread: #{DxThreads::toString(dxthread)}"
            Bank::put(dxthread["uuid"], timespan)
            if input == "done" then
                Quarks::destroyQuarkAndNereidContent(quark)
                return
            end
            if input == ">nyx" then
                item = Patricia::getDX7ByUUIDOrNull(quark["nereiduuid"]) 
                return if item.nil?
                Patricia::landing(item)
                Quarks::destroyQuark(quark)
                return
            end
            if input == ">dxthread" then
                Patricia::moveTargetToNewDxThread(quark, dxthread)
                return
            end
            if input == "landing" then
                Quarks::landing(quark)
                next
            end
            if input == "pause" then
                puts "paused...".green
                LucilleCore::pressEnterToContinue("Press enter to resume: ")
                next
            end
            if input == "exit-running" then
                RunningItems::start(Quarks::toString(quark), [quark["uuid"], dxthread["uuid"]])
                return
            end
            if input == "exit" then
                return
            end
            if input == "/" then
                UIServices::servicesFront()
                next
            end
            return
        }
    end

    # DxThreadsUIUtils::dxThreadToDisplayItemsNS16(dxthread)
    def self.dxThreadToDisplayItemsNS16(dxthread)
        DxThreadQuarkMapping::dxThreadToQuarksInOrderForUIListing(dxthread)
            .map{|quark|
                {
                    "uuid"     => quark["uuid"],
                    "display"  => "⛵️ #{DxThreads::toStringWithAnalytics(dxthread).yellow}".yellow,
                    "announce" => DxThreads::dxThreadAndTargetToString(dxthread, quark),
                    "commands" => "done (destroy quark and nereid element) | >nyx | >dxthread | landing",
                    "lambda"   => lambda{ DxThreadsUIUtils::runDxThreadQuarkPair(dxthread, quark) }
                }
            }
    end

    # DxThreadsUIUtils::streamLateChargesDisplayItemsNS16OrNull()
    def self.streamLateChargesDisplayItemsNS16OrNull()
        return nil if DxThreadsTarget::getDxThreadStreamCardinal() < DxThreadsTarget::getIdealDxThreadStreamCardinal()
        dxthread = DxThreads::getStream()
        {
            "uuid"             => "368e9e69-b69e-42fb-8207-f85203582552",
            "completionRatio"  => 0.25,
            "description"      => "Stream late charges".yellow,
            "block"            => nil,
            "DisplayItemsNS16" => DxThreadsUIUtils::dxThreadToDisplayItemsNS16(dxthread)
        }
    end

end

class DxThreads

    # DxThreads::visualisationDepth()
    def self.visualisationDepth()
        30
    end

    # DxThreads::dxthreads()
    def self.dxthreads()
        M54::getSet("2ed4c63e-56df-4247-8f20-e8d220958226")
    end

    # DxThreads::getStream()
    def self.getStream()
        M54::getOrNull("791884c9cf34fcec8c2755e6cc30dac4")
    end

    # DxThreads::make(description, timeCommitmentPerDayInHours)
    def self.make(description, timeCommitmentPerDayInHours)
        {
            "uuid"        => SecureRandom.hex,
            "nyxNxSet"    => "2ed4c63e-56df-4247-8f20-e8d220958226",
            "unixtime"    => Time.new.to_f,
            "description" => description,
            "timeCommitmentPerDayInHours" => timeCommitmentPerDayInHours,
        }
    end

    # DxThreads::issue(description, timeCommitmentPerDayInHours)
    def self.issue(description, timeCommitmentPerDayInHours)
        object = DxThreads::make(description, timeCommitmentPerDayInHours)
        M54::put(object)
        object
    end

    # DxThreads::issueDxThreadInteractivelyOrNull()
    def self.issueDxThreadInteractivelyOrNull()
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return nil if description == ""
        timeCommitmentPerDayInHours = LucilleCore::askQuestionAnswerAsString("timeCommitmentPerDayInHours: ")
        return nil if timeCommitmentPerDayInHours == ""
        timeCommitmentPerDayInHours = timeCommitmentPerDayInHours.to_f
        return nil if timeCommitmentPerDayInHours == 0
        DxThreads::issue(description, timeCommitmentPerDayInHours)
    end

    # DxThreads::toString(object)
    def self.toString(object)
        "[DxThread] #{object["description"]}"
    end

    # DxThreads::toStringWithAnalytics(dxthread)
    def self.toStringWithAnalytics(dxthread)
        ratio = DxThreads::completionRatio(dxthread)
        "[DxThread] [#{"%4.2f" % dxthread["timeCommitmentPerDayInHours"]} hours, #{"%6.2f" % (100*ratio)} % completed] #{dxthread["description"]}"
    end

    # DxThreads::dxThreadAndTargetToString(dxthread, quark)
    def self.dxThreadAndTargetToString(dxthread, quark)
        uuid = "#{dxthread["uuid"]}-#{quark["uuid"]}"
        "#{DxThreads::toString(dxthread)} (#{"%8.3f" % DxThreadQuarkMapping::getDxThreadQuarkOrdinal(dxthread, quark)}) #{Patricia::toString(quark)}"
    end

    # DxThreads::completionRatio(dxthread)
    def self.completionRatio(dxthread)
        BankExtended::recoveredDailyTimeInHours(dxthread["uuid"]).to_f/dxthread["timeCommitmentPerDayInHours"]
    end

    # DxThreads::determinePlacingOrdinalForThread(dxthread)
    def self.determinePlacingOrdinalForThread(dxthread)
        puts "Placement ordinal listing"
        quarks = DxThreadQuarkMapping::dxThreadToQuarksInOrder(dxthread, DxThreads::visualisationDepth())
        quarks.each{|quark|
            puts "[#{"%8.3f" % DxThreadQuarkMapping::getDxThreadQuarkOrdinal(dxthread, quark)}] #{Patricia::toString(quark)}"
        }
        ordinal = LucilleCore::askQuestionAnswerAsString("placement ordinal ('low' for 21st, empty for last): ")
        if ordinal == "" then
            return DxThreadQuarkMapping::getNextOrdinal()
        end
        if ordinal == "low" then
            return Patricia::computeNew21stOrdinalForDxThread(dxthread)
        end
        ordinal.to_f
    end

    # DxThreads::selectOneExistingDxThreadOrNull()
    def self.selectOneExistingDxThreadOrNull()
        LucilleCore::selectEntityFromListOfEntitiesOrNull("DxThread", DxThreads::dxthreads(), lambda{|o| DxThreads::toString(o) })
    end

    # DxThreads::landing(dxthread, showAllTargets)
    def self.landing(dxthread, showAllTargets = false)
        loop {
            system("clear")

            return if M54::getOrNull(dxthread["uuid"]).nil?

            puts DxThreads::toString(dxthread).green
            puts "uuid: #{dxthread["uuid"]}".yellow
            puts "time commitment per day in hours: #{dxthread["timeCommitmentPerDayInHours"]}".yellow
            puts "no display on this day: #{dxthread["noDisplayOnThisDay"]}".yellow

            mx = LCoreMenuItemsNX1.new()

            puts ""

            DxThreadQuarkMapping::dxThreadToQuarksInOrder(dxthread, showAllTargets ? nil : DxThreads::visualisationDepth())
                .each{|quark|
                    mx.item("[quark] [#{"%8.3f" % DxThreadQuarkMapping::getDxThreadQuarkOrdinal(dxthread, quark)}] #{Patricia::toString(quark)}", lambda { 
                        Patricia::landing(quark) 
                    })
                }

            puts ""

            mx.item("relanding on all quarks".yellow, lambda { 
                DxThreads::landing(dxthread, true)
            })

            mx.item("no display on this day".yellow, lambda { 
                dxthread["noDisplayOnThisDay"] = CatalystUtils::today()
                M54::put(dxthread)
            })

            mx.item("rename".yellow, lambda { 
                name1 = CatalystUtils::editTextSynchronously(dxthread["name"]).strip
                return if name1 == ""
                dxthread["name"] = name1
                M54::put(dxthread)
            })

            mx.item("update daily time commitment".yellow, lambda { 
                time = LucilleCore::askQuestionAnswerAsString("daily time commitment in hour: ").to_f
                dxthread["timeCommitmentPerDayInHours"] = time
                M54::put(dxthread)
            })

            mx.item("start thread".yellow, lambda { 
                RunningItems::start(DxThreads::toString(dxthread), [dxthread["uuid"]])
                puts "Started"
                LucilleCore::pressEnterToContinue()
            })

            mx.item("add time".yellow, lambda { 
                timeInHours = LucilleCore::askQuestionAnswerAsString("Time in hours: ")
                return if timeInHours == ""
                Bank::put(dxthread["uuid"], timeInHours.to_f*3600)
            })

            mx.item("add new quark".yellow, lambda {
                Patricia::getQuarkPossiblyArchitectedOrNull(nil, dxthread)
            })

            mx.item("select and move quark".yellow, lambda { 
                quarks = DxThreadQuarkMapping::dxThreadToQuarksInOrder(dxthread, DxThreads::visualisationDepth())
                quark = LucilleCore::selectEntityFromListOfEntitiesOrNull("quark", quarks, lambda { |quark| Patricia::toString(quark) })
                return if quark.nil?
                Patricia::moveTargetToNewDxThread(quark, dxthread)
            })

            mx.item("json object".yellow, lambda { 
                puts JSON.pretty_generate(dxthread)
                LucilleCore::pressEnterToContinue()
            })

            mx.item("flush focus uuids".yellow, lambda { 
                KeyValueStore::destroy(nil, "3199a49f-3d71-4a02-83b2-d01473664473:#{dxthread["uuid"]}")
            })
            
            mx.item("destroy".yellow, lambda { 
                if LucilleCore::askQuestionAnswerAsBoolean("DxThread: '#{DxThreads::toString(dxthread)}': ") then
                    M54::destroy(dxthread)
                end
            })
            puts ""
            status = mx.promptAndRunSandbox()
            break if !status
        }
    end

    # DxThreads::getThreadsAvailableTodayInCompletionRatioOrder()
    def self.getThreadsAvailableTodayInCompletionRatioOrder()
        DxThreads::dxthreads()
            .select{|dxthread| dxthread["noDisplayOnThisDay"] != CatalystUtils::today() } 
            .sort{|dx1, dx2| DxThreads::completionRatio(dx1) <=> DxThreads::completionRatio(dx2) }
    end

    # DxThreads::main()
    def self.main()
        loop {
            system("clear")

            ms = LCoreMenuItemsNX1.new()

            DxThreads::dxthreads()
                .sort{|dx1, dx2| dx1["description"] <=> dx2["description"] }
                .each{|dxthread|
                    ms.item(DxThreads::toStringWithAnalytics(dxthread), lambda { 
                        DxThreads::landing(dxthread)
                    })
                }

            ms.item("make new DxThread", lambda { 
                object = DxThreads::issueDxThreadInteractivelyOrNull()
                return if object.nil?
                DxThreads::landing(object)
            })

            status = ms.promptAndRunSandbox()
            break if !status
        }
    end
end

