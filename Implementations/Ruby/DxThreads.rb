# encoding: UTF-8

class DxThreads

    # DxThreads::visualisationDepth()
    def self.visualisationDepth()
        30
    end

    # DxThreads::dxthreads()
    def self.dxthreads()
        TodoCoreData::getSet("2ed4c63e-56df-4247-8f20-e8d220958226")
    end

    # DxThreads::getStream()
    def self.getStream()
        TodoCoreData::getOrNull("791884c9cf34fcec8c2755e6cc30dac4")
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
        TodoCoreData::put(object)
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
        "#{DxThreads::toString(dxthread)} (#{"%8.3f" % DxThreadQuarkMapping::getDxThreadQuarkOrdinal(dxthread, quark)}) #{NyxPatricia::toString(quark)}"
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
            puts "[#{"%8.3f" % DxThreadQuarkMapping::getDxThreadQuarkOrdinal(dxthread, quark)}] #{NyxPatricia::toString(quark)}"
        }
        ordinal = LucilleCore::askQuestionAnswerAsString("placement ordinal ('low' for 21st, empty for last): ")
        if ordinal == "" then
            return DxThreadQuarkMapping::getNextOrdinal()
        end
        if ordinal == "low" then
            return NyxPatricia::computeNew21stOrdinalForDxThread(dxthread)
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

            return if TodoCoreData::getOrNull(dxthread["uuid"]).nil?

            puts DxThreads::toString(dxthread).green
            puts "uuid: #{dxthread["uuid"]}".yellow
            puts "time commitment per day in hours: #{dxthread["timeCommitmentPerDayInHours"]}".yellow
            puts "no display on this day: #{dxthread["noDisplayOnThisDay"]}".yellow

            mx = LCoreMenuItemsNX1.new()

            puts ""

            DxThreadQuarkMapping::dxThreadToQuarksInOrder(dxthread, showAllTargets ? nil : DxThreads::visualisationDepth())
                .each{|quark|
                    mx.item("[quark] [#{"%8.3f" % DxThreadQuarkMapping::getDxThreadQuarkOrdinal(dxthread, quark)}] #{NyxPatricia::toString(quark)}", lambda { 
                        NyxPatricia::landing(quark) 
                    })
                }

            puts ""

            mx.item("relanding on all quarks".yellow, lambda { 
                DxThreads::landing(dxthread, true)
            })

            mx.item("no display on this day".yellow, lambda { 
                dxthread["noDisplayOnThisDay"] = Miscellaneous::today()
                TodoCoreData::put(dxthread)
            })

            mx.item("rename".yellow, lambda { 
                name1 = Miscellaneous::editTextSynchronously(dxthread["name"]).strip
                return if name1 == ""
                dxthread["name"] = name1
                TodoCoreData::put(dxthread)
            })

            mx.item("update daily time commitment in hours".yellow, lambda { 
                time = LucilleCore::askQuestionAnswerAsString("daily time commitment in hour: ").to_f
                dxthread["timeCommitmentPerDayInHours"] = time
                TodoCoreData::put(dxthread)
            })

            mx.item("start thread".yellow, lambda { 
                Runner::start(dxthread["uuid"])
            })

            mx.item("add time".yellow, lambda { 
                timeInHours = LucilleCore::askQuestionAnswerAsString("Time in hours: ")
                return if timeInHours == ""
                Bank::put(dxthread["uuid"], timeInHours.to_f*3600)
            })

            mx.item("add new quark".yellow, lambda {
                NyxPatricia::getQuarkPossiblyArchitectedOrNull(nil, dxthread)
            })

            mx.item("select and move quark".yellow, lambda { 
                quarks = DxThreadQuarkMapping::dxThreadToQuarksInOrder(dxthread, DxThreads::visualisationDepth())
                quark = LucilleCore::selectEntityFromListOfEntitiesOrNull("quark", quarks, lambda { |quark| NyxPatricia::toString(quark) })
                return if quark.nil?
                NyxPatricia::moveTargetToNewDxThread(quark, dxthread)
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
                    TodoCoreData::destroy(dxthread)
                end
            })
            puts ""
            status = mx.promptAndRunSandbox()
            break if !status
        }
    end

    # DxThreads::getThreadsInCompletionRatioOrder()
    def self.getThreadsInCompletionRatioOrder()
        DxThreads::dxthreads()
            .sort{|dx1, dx2| DxThreads::completionRatio(dx1) <=> DxThreads::completionRatio(dx2) }
    end

    # DxThreads::getThreadsAvailableTodayInCompletionRatioOrder()
    def self.getThreadsAvailableTodayInCompletionRatioOrder()
        DxThreads::dxthreads()
            .select{|dxthread| dxthread["noDisplayOnThisDay"] != Miscellaneous::today() } 
            .sort{|dx1, dx2| DxThreads::completionRatio(dx1) <=> DxThreads::completionRatio(dx2) }
    end

    # DxThreads::main()
    def self.main()
        loop {
            system("clear")

            ms = LCoreMenuItemsNX1.new()

            DxThreads::getThreadsInCompletionRatioOrder().each{|dxthread|
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

