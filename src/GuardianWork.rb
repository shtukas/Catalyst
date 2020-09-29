# encoding: UTF-8

class GuardianWork

    # We provide
    #    1. A Catalyst object driven by a bank recovering value.
    #    2. A dedicated command line tool.
    #    3. Specific manipulations for on disk mirroring.

    # GuardianWork::uuid()
    def self.uuid()
        "5c4e1873-d511-474d-8562-073c0f08b536"
    end

    # GuardianWork::targetTimeInHours()
    def self.targetTimeInHours()
        7
    end

    # GuardianWork::metric()
    def self.metric()
        uuid = GuardianWork::uuid()
        return 1 if Runner::isRunning?(uuid)
        recoveredTimeInHours = BankExtended::recoveredDailyTimeInHours(uuid)
        (recoveredTimeInHours < GuardianWork::targetTimeInHours()) ? 0.70 : 0
    end

    # GuardianWork::start()
    def self.start()
        Runner::start(GuardianWork::uuid())
    end

    # GuardianWork::stop()
    def self.stop()
        timespanInSeconds =  Runner::stop(GuardianWork::uuid())
        return if timespanInSeconds.nil?
        Bank::put(GuardianWork::uuid(), timespanInSeconds)
    end

    # GuardianWork::toString()
    def self.toString()
        uuid = GuardianWork::uuid()
        ratio = BankExtended::recoveredDailyTimeInHours(GuardianWork::uuid()).to_f/GuardianWork::targetTimeInHours()
        runningFor = Runner::isRunning?(uuid) ? " (running for #{((Runner::runTimeInSecondsOrNull(uuid) || 0).to_f/60).round(2)} mins)" : ""
        "Guardian Work (#{"%.2f" % (100*ratio)} %)#{runningFor}"
    end

    # GuardianWork::catalystObjects()
    def self.catalystObjects()
        uuid = GuardianWork::uuid()
        object = {
            "uuid"             => uuid,
            "body"             => GuardianWork::toString(),
            "metric"           => GuardianWork::metric(),
            "execute"          => lambda { |command| GuardianWork::program(command) },
            "isRunning"        => Runner::isRunning?(uuid),
            "isRunningForLong" => (Runner::runTimeInSecondsOrNull(uuid) || 0) > 3600
        }
        [ object ]
    end

    # GuardianWork::program(command)
    def self.program(command)
        if command == "c2c799b1-bcb9-4963-98d5-494a5a76e2e6" then
            uuid = GuardianWork::uuid()
            Runner::isRunning?(uuid) ? GuardianWork::stop() : GuardianWork::start()
            return
        end

        loop {
            system("clear")
            puts GuardianWork::toString().green
            puts ""
            options = [
                Runner::isRunning?(GuardianWork::uuid()) ? "stop" : "start",
                "add time",
                "open folder"
            ]
            option = LucilleCore::selectEntityFromListOfEntitiesOrNull("operation", options)
            break if option.nil?
            if option == "start" then
                GuardianWork::start()
            end
            if option == "stop" then
                GuardianWork::stop()
            end
            if option == "add time" then
                timeInHours = LucilleCore::askQuestionAnswerAsString("time (in hours): ").to_f
                timespanInSeconds = timeInHours*3600
                Bank::put(GuardianWork::uuid(), timespanInSeconds)
            end
            if option == "open folder" then
                system("open '/Users/pascal/Galaxy/Current/The Guardian/Open Cycles'")
            end
        }
    end
end