
# encoding: UTF-8

class Quarks

    # Quarks::quarks()
    def self.quarks()
        TodoCoreData::getSet("d65674c7-c8c4-4ed4-9de9-7c600b43eaab")
    end

    # Quarks::issueNewQuarkInteractivelyOrNull()
    def self.issueNewQuarkInteractivelyOrNull()
        element = NereidInterface::interactivelyIssueNewElementOrNull()
        return nil if element.nil?
        quark = {
            "uuid"       => SecureRandom.hex,
            "nyxNxSet"   => "d65674c7-c8c4-4ed4-9de9-7c600b43eaab",
            "unixtime"   => Time.new.to_i,
            "nereiduuid" => element["uuid"]
        }
        TodoCoreData::put(quark)
        quark
    end

    # --------------------------------------------------

    # Quarks::toString(quark)
    def self.toString(quark)
        "[quark] #{NereidInterface::toString(quark["nereiduuid"])}"
    end

    # --------------------------------------------------

    # Quarks::access(quark)
    def self.access(quark)
        NereidInterface::access(quark["nereiduuid"])
    end

    # Quarks::landing(quark)
    def self.landing(quark)
        loop {

            return if TodoCoreData::getOrNull(quark["uuid"]).nil?
            quark = TodoCoreData::getOrNull(quark["uuid"]) # could have been transmuted in the previous loop

            system("clear")

            mx = LCoreMenuItemsNX1.new()

            puts Quarks::toString(quark)
            puts "uuid: #{quark["uuid"]}".yellow
            puts "ordinal: #{DxThreadQuarkMapping::getQuarkOrdinal(quark)}".yellow

            puts ""

            DxThreadQuarkMapping::getDxThreadsForQuark(quark).each{|dxthread|
                mx.item(
                    "source: #{DxThreads::toString(dxthread)}",
                    lambda { DxThreads::landing(dxthread) }
                )
            }

            puts ""

            mx.item(
                "access".yellow,
                lambda { Quarks::access(quark) }
            )

            mx.item("set/update ordinal".yellow, lambda {
                ordinal = LucilleCore::askQuestionAnswerAsString("ordnal: ")
                return if ordinal == ""
                DxThreadQuarkMapping::setQuarkOrdinal(quark, ordinal.to_f)
            })

            mx.item("move to another DxThread".yellow, lambda {
                dxthreads = DxThreadQuarkMapping::getDxThreadsForQuark(quark)
                if dxthreads.size == 0 then
                    NyxPatricia::moveTargetToNewDxThread(quark, nil)
                    return
                end
                if dxthreads.size == 1 then
                    NyxPatricia::moveTargetToNewDxThread(quark, dxthreads[0])
                    return
                end
                dxthread = LucilleCore::selectEntityFromListOfEntitiesOrNull("DxThread", dxthreads, lambda { |dxthread| DxThreads::toString(dxthread) })
                return if dxthread.nil?
                NyxPatricia::moveTargetToNewDxThread(quark, dxthread)
            })

            mx.item("edit".yellow, lambda {
                NereidInterface::edit(quark["nereiduuid"])
            })

            mx.item("transmute".yellow, lambda { 
                NereidInterface::transmuteOrNull(quark["nereiduuid"])
            })

            mx.item("json object".yellow, lambda { 
                puts JSON.pretty_generate(quark)
                LucilleCore::pressEnterToContinue()
            })

            mx.item("destroy quark and content".yellow, lambda { 
                if LucilleCore::askQuestionAnswerAsBoolean("Are you sure you want to destroy this quark and its content? ") then
                    Quarks::destroyQuarkAndNereidContent(quark)
                end
            })

            puts ""

            status = mx.promptAndRunSandbox()
            break if !status
        }
    end

    # Quarks::destroyQuark(quark)
    def self.destroyQuark(quark)
        TodoCoreData::destroy(quark)
    end

    # Quarks::destroyQuarkAndNereidContent(quark)
    def self.destroyQuarkAndNereidContent(quark)
        status = NereidInterface::destroyElement(quark["nereiduuid"])
        return if !status
        TodoCoreData::destroy(quark)
    end
end
