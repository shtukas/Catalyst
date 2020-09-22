
class NSNode1638Extended

    # NSNode1638Extended::selectOneDatapointFromDatapointsOrNull(nodes)
    def self.selectOneDatapointFromDatapointsOrNull(nodes)
        LucilleCore::selectEntityFromListOfEntitiesOrNull("node", nodes, lambda { |node| NSNode1638::toString(node) })
    end

    # NSNode1638Extended::selectOneDatapointFromExistingDatapointsOrNull()
    def self.selectOneDatapointFromExistingDatapointsOrNull()
        loop {
            pattern = LucilleCore::askQuestionAnswerAsString("pattern: ")
            if pattern == "" then
                return
            end
            datapoints = SelectionLookupDataset::patternToDatapoints(pattern)
            if datapoints.empty? then
                puts "No results for this pattern"
                LucilleCore::pressEnterToContinue()
                next
            end
            datapoint = NSNode1638Extended::selectOneDatapointFromDatapointsOrNull(datapoints)
            if datapoint.nil? then
                next
            end
            return datapoint
        }
    end

    # NSNode1638Extended::selectOneExistingDatapointOrMakeANewOneOrNull()
    def self.selectOneExistingDatapointOrMakeANewOneOrNull()
        puts "selectOneExistingDatapointOrMakeANewOneOrNull()"
        LucilleCore::pressEnterToContinue()
        datapoint = NSNode1638Extended::selectOneDatapointFromExistingDatapointsOrNull()
        return datapoint if datapoint
        status = LucilleCore::askQuestionAnswerAsBoolean("You did not select an existing point, would you like to create a new one ? ")
        if !status then
            return nil
        end
        NSNode1638::issueNewPointInteractivelyOrNull()
    end

    # NSNode1638Extended::interactiveDatapointSearchAndExplore()
    def self.interactiveDatapointSearchAndExplore()
        loop {
            system("clear")
            pattern = LucilleCore::askQuestionAnswerAsString("pattern: ")
            return nil if pattern == ""
            nodes = SelectionLookupDataset::patternToDatapoints(pattern)
            #nodes = GenericObjectInterface::applyDateTimeOrderToObjects(nodes)
            next if nodes.empty?
            loop {
                #nodes = nodes.select{|node| NyxObjects2::getOrNull(node["uuid"])} # one could have been destroyed in the previous loop
                break if nodes.empty?
                system("clear")
                node = NSNode1638Extended::selectOneDatapointFromDatapointsOrNull(nodes)
                break if node.nil?
                NSNode1638::landing(node)
            }
        }
    end

    # NSNode1638Extended::interactiveNodeNcursesSearch(): Array[Nodes]
    def self.interactiveNodeNcursesSearch()

        Curses::init_screen
        # Initializes a standard screen. At this point the present state of our terminal is saved and the alternate screen buffer is turned on

        Curses::noecho
        # Disables characters typed by the user to be echoed by Curses.getch as they are typed.

        globalState = {
            "userSearchString" => "",
            "userSearchStringLastTimeUpdate" => nil,
            "userSearchStringHasBeenModifiedSinceLastSearch" => false,
            "selectedObjets" => []
        }

        win1 = Curses::Window.new(1, Miscellaneous::screenWidth(), 0, 0)
        win2 = Curses::Window.new(1, Miscellaneous::screenWidth(), 1, 0)
        win3 = Curses::Window.new(Miscellaneous::screenHeight()-2, Miscellaneous::screenWidth(), 2, 0)

        win1.refresh
        win2.refresh
        win3.refresh

        win1UpdateState = lambda {
            win1.setpos(0,0)
            win1.deleteln()
            win1 << ("-> " + globalState["userSearchString"])
            win1.refresh
        }

        win2UpdateStateToSearching = lambda {
            win2.setpos(0,0)
            win2.deleteln()
            win2 << "searching @ #{Time.new.to_s}"
            win2.refresh
        }
        win2UpdateStateToNotSearching = lambda {
            win2.setpos(0,0)
            win2.deleteln()
            win2.refresh
        }

        thread4 = Thread.new {
            loop {
                sleep 0.01

                next if globalState["userSearchString"].size < 3 
                next if globalState["userSearchStringLastTimeUpdate"].nil?
                next if !globalState["userSearchStringHasBeenModifiedSinceLastSearch"]

                pattern = globalState["userSearchString"]
                globalState["userSearchStringHasBeenModifiedSinceLastSearch"] = false

                win2UpdateStateToSearching.call()

                objects = SelectionLookupDataset::patternToDatapoints(pattern)
                globalState["selectedObjets"] = objects

                win3.setpos(0,0)
                objects.first(Miscellaneous::screenHeight()-3).each{|object|
                    win3.deleteln()
                    win3 << "#{NSNode1638::toString(object)}\n"
                }
                (win3.maxy - win3.cury).times {win3.deleteln()}
                win3.refresh

                win2UpdateStateToNotSearching.call()
                win1UpdateState.call()
            }
        }

        win1UpdateState.call()

        loop {
            char = win1.getch.to_s # Reads and return a character non blocking

            next if char.size == 0

            if char == '127' then
                # delete
                next if globalState["userSearchString"].length == 0
                globalState["userSearchString"] = globalState["userSearchString"][0, globalState["userSearchString"].length-1]
                globalState["userSearchStringHasBeenModifiedSinceLastSearch"] = true
                globalState["userSearchStringLastTimeUpdate"] = Time.new.to_f

                win1UpdateState.call()
                next
            end

            if char == '10' then
                # enter
                break
            end

            globalState["userSearchString"] = globalState["userSearchString"] + char
            globalState["userSearchStringHasBeenModifiedSinceLastSearch"] = true
            globalState["userSearchStringLastTimeUpdate"] = Time.new.to_f
            win1UpdateState.call()
        }

        Thread.kill(thread4)

        win1.close
        win2.close
        win3.close

        Curses::close_screen # this method restore our terminal's settings

        return globalState["selectedObjets"]
    end
end