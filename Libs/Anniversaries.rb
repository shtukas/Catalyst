
class Anniversaries

    # Anniversaries::dateIsCorrect(date)
    def self.dateIsCorrect(date)
        begin
            Date.parse(date)
            true
        rescue
            false
        end
    end

    # Anniversaries::datePlusNMonthAnniversaryStyle(date: String, shiftInMonths: Integer)
    def self.datePlusNMonthAnniversaryStyle(date, shiftInMonths)
        dateElements = [date[0, 4].to_i, date[5, 2].to_i+shiftInMonths, date[8, 2].to_i]

        while dateElements[1] > 12 do
            dateElements[0] = dateElements[0]+1
            dateElements[1] = dateElements[1] - 12
        end

        date = "#{dateElements[0]}-#{dateElements[1].to_s.rjust(2, "0")}-#{dateElements[2].to_s.rjust(2, "0")}"

        while !Anniversaries::dateIsCorrect(date) do
            date = "#{date[0, 4]}-#{date[5, 2]}-#{(date[8, 2].to_i-1).to_s.rjust(2, "0")}"
        end
        date
    end

    # Anniversaries::computeNextCelebrationDateOrdinal(startdate: String, repeatType: String, lastCelebrationDate: String) # [ date: String, ordinal: Int ]
    def self.computeNextCelebrationDateOrdinal(startdate, repeatType, lastCelebrationDate)
        cursordate = Date.parse(startdate)
        cursorOrdinal = 0
        if repeatType == "weekly" then
            loop {
                if cursordate.to_s > lastCelebrationDate then
                    return [cursordate.to_s, cursorOrdinal]
                end
                cursordate = cursordate + 7
                cursorOrdinal = cursorOrdinal + 1
            }
        end
        if repeatType == "monthly" then
            loop {
                if cursordate.to_s > lastCelebrationDate then
                    return [cursordate.to_s, cursorOrdinal]
                end
                cursorOrdinal = cursorOrdinal + 1
                cursordate = Date.parse(Anniversaries::datePlusNMonthAnniversaryStyle(startdate, cursorOrdinal))
            }
        end
        if repeatType == "yearly" then
            loop {
                if cursordate.to_s > lastCelebrationDate then
                    return [cursordate.to_s, cursorOrdinal]
                end
                cursorOrdinal = cursorOrdinal + 1
                cursordate = "#{startdate[0, 4].to_i+cursorOrdinal}-#{startdate[5, 2]}-#{startdate[8, 2]}"
                while !Anniversaries::dateIsCorrect(cursordate) do
                    cursordate = "#{cursordate[0, 4]}-#{cursordate[5, 2]}-#{(cursordate[8, 2].to_i-1).to_s.rjust(2, "0")}"
                end
            }
        end
    end

    # Anniversaries::runTests()
    def self.runTests()
        raise "72118532-21b3-4897-a6d1-7c21458b4624" if Anniversaries::datePlusNMonthAnniversaryStyle("2020-11-25", 1) != "2020-12-25"
        raise "279b1ee3-728e-4883-9a4d-abf3b9a494d7" if Anniversaries::datePlusNMonthAnniversaryStyle("2020-12-25", 1) != "2021-01-25"
        raise "5507b102-2651-4b57-ba7b-7e6c217bddba" if Anniversaries::datePlusNMonthAnniversaryStyle("2021-01-01", 1) != "2021-02-01"
        raise "38e0536a-7943-4649-a002-6f65e9d88c0a" if Anniversaries::datePlusNMonthAnniversaryStyle("2021-01-31", 1) != "2021-02-28"
        raise "cd8feeec-54bd-4a63-be2c-e279c77390ba" if Anniversaries::datePlusNMonthAnniversaryStyle("2021-01-31", 2) != "2021-03-31"
        raise "d82394e7-708d-49a8-9d65-792a77093ce5" if Anniversaries::datePlusNMonthAnniversaryStyle("2021-01-31", 3) != "2021-04-30"
        raise "8bb58535-b435-4bbe-9ded-76cf5d1ce6ad" if Anniversaries::datePlusNMonthAnniversaryStyle("2024-01-31", 1) != "2024-02-29"
        raise "53ac9950-7df9-481d-a3cf-2ec07f566f89" if Anniversaries::datePlusNMonthAnniversaryStyle("2024-01-31", 2) != "2024-03-31"

        raise "ff1f70da-1342-4a20-91cb-f5a86f66a44c" if Anniversaries::computeNextCelebrationDateOrdinal("2021-02-28", "yearly", "2022-01-01").join(", ") != "2022-02-28, 1"
        raise "ff1f70da-1342-4a20-91cb-f5a86f66a44c" if Anniversaries::computeNextCelebrationDateOrdinal("2024-02-29", "yearly", "2025-01-01").join(", ") != "2025-02-28, 1"
    end

    # ----------------------------------------------------------------------------------

    # Anniversaries::interactivelyIssueNewAnniversaryOrNull()
    def self.interactivelyIssueNewAnniversaryOrNull()

        uuid = SecureRandom.uuid

        anniversary = {}
        anniversary["uuid"] = uuid
        anniversary["schema"] = "anniversary"
        anniversary["unixtime"] = Time.new.to_i

        description = LucilleCore::askQuestionAnswerAsString("description (empty to abort): ")
        if description == "" then
            return nil
        end
        anniversary["description"] = description

        startdate = LucilleCore::askQuestionAnswerAsString("startdate (empty to abort): ")
        if startdate == "" then
            return nil
        end
        anniversary["startdate"] = startdate

        repeatType = LucilleCore::selectEntityFromListOfEntitiesOrNull("repeat type", ["weekly", "monthly", "yearly"])
        if repeatType.nil? then
            return nil
        end
        anniversary["repeatType"] = repeatType

        lastCelebrationDate = LucilleCore::askQuestionAnswerAsString("lastCelebrationDate (default to today): ")
        if lastCelebrationDate == "" then
            lastCelebrationDate = Utils::today()
        end
        anniversary["lastCelebrationDate"] = lastCelebrationDate

        CoreDataTx::commit(anniversary)

        anniversary
    end

    # Anniversaries::nextDateOrdinal(anniversary) # [ date: String, ordinal: Int ]
    def self.nextDateOrdinal(anniversary)
        Anniversaries::computeNextCelebrationDateOrdinal(anniversary["startdate"], anniversary["repeatType"], anniversary["lastCelebrationDate"] || "2001-01-01")
    end

    # Anniversaries::toString(anniversary)
    def self.toString(anniversary)
        date, n = Anniversaries::nextDateOrdinal(anniversary)
        "[anniversary] [#{anniversary["startdate"]}, #{date}, #{n.to_s.ljust(4)}, #{anniversary["repeatType"].ljust(7)}] #{anniversary["description"]}"
    end

    # Anniversaries::ns16s()
    def self.ns16s()
        CoreDataTx::getObjectsBySchema("anniversary")
            .select{|anniversary| Anniversaries::nextDateOrdinal(anniversary)[0] <= Utils::today() }
            .map{|anniversary|
                {
                    "uuid"     => anniversary["uuid"],
                    "announce" => Anniversaries::toString(anniversary).gsub("[anniversary]","[anni]"),
                    "access"   => lambda {
                        puts Anniversaries::toString(anniversary).green
                        if LucilleCore::askQuestionAnswerAsBoolean("done ? : ") then
                            anniversary["lastCelebrationDate"] = Time.new.to_s[0, 10]
                            CoreDataTx::commit(anniversary)
                        end
                    },
                    "done"   => lambda {
                        puts Anniversaries::toString(anniversary).green
                        anniversary["lastCelebrationDate"] = Time.new.to_s[0, 10]
                        CoreDataTx::commit(anniversary)
                    }
                }
            }
    end

    # Anniversaries::dailyBriefing()
    def self.dailyBriefing()
        puts "Anniversaries daily briefing:"
        CoreDataTx::getObjectsBySchema("anniversary")
            .sort{|i1, i2| Anniversaries::nextDateOrdinal(i1)[0] <=> Anniversaries::nextDateOrdinal(i2)[0] }
            .each{|anniversary|
                puts Anniversaries::toString(anniversary)
            }
        LucilleCore::pressEnterToContinue()
    end

    # Anniversaries::landing(anniversary)
    def self.landing(anniversary)
        loop {

            puts Anniversaries::toString(anniversary).green

            puts "update start date | destroy".yellow
            puts UIServices::mainMenuCommands().yellow

            command = LucilleCore::askQuestionAnswerAsString("> ")
            break if command == ""

            if Interpreting::match("update start date", command) then
                startdate = Utils::editTextSynchronously(anniversary["startdate"])
                return if startdate == ""
                anniversary["startdate"] = startdate
                CoreDataTx::commit(anniversary)
            end

            if Interpreting::match("destroy", command) then
                CoreDataTx::delete(anniversary["uuid"])
                break
            end

            UIServices::mainMenuInterpreter(command)
        }
    end

    # Anniversaries::anniversariesDive()
    def self.anniversariesDive()
        loop {
            anniversaries = CoreDataTx::getObjectsBySchema("anniversary")
                        .sort{|i1, i2| Anniversaries::nextDateOrdinal(i1)[0] <=> Anniversaries::nextDateOrdinal(i2)[0] }
            anniversary = LucilleCore::selectEntityFromListOfEntitiesOrNull("anniversary", anniversaries, lambda{|item| Anniversaries::toString(item) })
            return if anniversary.nil?
            Anniversaries::landing(anniversary)
        }
    end

    # Anniversaries::main()
    def self.main()
        loop {
            puts "Anniversaries (main)"

            puts "dive (into anniversaries) | make (new anniversary)".yellow
            puts UIServices::mainMenuCommands().yellow


            command = LucilleCore::askQuestionAnswerAsString("> ")
            break if command == ""

            if Interpreting::match("dive", command) then
                Anniversaries::anniversariesDive()
            end

            if Interpreting::match("make", command) then
                Anniversaries::interactivelyIssueNewAnniversaryOrNull()
                break
            end

            UIServices::mainMenuInterpreter(command)
        }
    end

    # Anniversaries::nx19s()
    def self.nx19s()
        CoreDataTx::getObjectsBySchema("anniversary").map{|item|
            {
                "announce" => Anniversaries::toString(item),
                "lambda"   => lambda { Anniversaries::landing(item) }
            }
        }
    end
end