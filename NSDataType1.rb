
# encoding: UTF-8

class NSDataType1

    # NSDataType1::issue()
    def self.issue()
        object = {
            "uuid"     => SecureRandom.uuid,
            "nyxNxSet" => "c18e8093-63d6-4072-8827-14f238975d04",
            "unixtime" => Time.new.to_f
        }
        NyxObjects::put(object)
        object
    end

    # NSDataType1::cubes()
    def self.cubes()
        NyxObjects::getSet("c18e8093-63d6-4072-8827-14f238975d04")
    end

    # NSDataType1::cubeToString(ns1)
    def self.cubeToString(ns1)
        ns0s = NSDataType1::cubeToFramesInTimeOrder(ns1)
        description = DescriptionZ::getLastDescriptionForSourceOrNull(ns1)
        if description and ns0s.size > 0 then
            return "[#{NavigationPoint::userFriendlyName(ns1)}] [#{ns1["uuid"][0, 4]}] [#{ns0s.last["type"]}] #{description}"
        end
        if description and ns0s.size == 0 then
            return "[#{NavigationPoint::userFriendlyName(ns1)}] [#{ns1["uuid"][0, 4]}] #{description}"
        end
        if description.nil? and ns0s.size > 0 then
            return "[#{NavigationPoint::userFriendlyName(ns1)}] [#{ns1["uuid"][0, 4]}] #{NSDataType0s::frameToString(ns0s.last)}"
        end
        if description.nil? and ns0s.size == 0 then
            return "[#{NavigationPoint::userFriendlyName(ns1)}] [#{ns1["uuid"][0, 4]}] no description and no frame"
        end
    end

    # NSDataType1::cubeToFramesInTimeOrder(ns1)
    def self.cubeToFramesInTimeOrder(ns1)
        Arrows::getTargetsOfGivenSetsForSource(ns1, ["0f555c97-3843-4dfe-80c8-714d837eba69"])
            .sort{|o1, o2| o1["unixtime"] <=> o2["unixtime"] }
    end

    # NSDataType1::cubeToLastFramesOrNull(ns1)
    def self.cubeToLastFramesOrNull(ns1)
        NSDataType1::cubeToFramesInTimeOrder(ns1)
            .last
    end

    # NSDataType1::getAsteroidsForCube(ns1)
    def self.getAsteroidsForCube(ns1)
        Arrows::getSourcesOfGivenSetsForTarget(ns1, ["b66318f4-2662-4621-a991-a6b966fb4398"])
    end

    # NSDataType1::giveDescriptionToCubeInteractively(ns1)
    def self.giveDescriptionToCubeInteractively(ns1)
        description = LucilleCore::askQuestionAnswerAsString("description: ")
        return if description == ""
        descriptionz = DescriptionZ::issue(description)
        Arrows::issue(ns1, descriptionz)
    end

    # NSDataType1::issueNewCubeAndItsFirstFrameInteractivelyOrNull()
    def self.issueNewCubeAndItsFirstFrameInteractivelyOrNull()
        puts "Making a new NSDataType1..."
        ns0 = NSDataType0s::issueNewNSDataType0InteractivelyOrNull()
        return nil if ns0.nil?
        ns1 = NSDataType1::issue()
        Arrows::issue(ns1, ns0)
        NSDataType1::giveDescriptionToCubeInteractively(ns1)
        ns1
    end

    # NSDataType1::openLastCubeFrame(ns1)
    def self.openLastCubeFrame(ns1)
        ns0 = NSDataType1::cubeToLastFramesOrNull(ns1)
        if ns0.nil? then
            puts "I could not find ns0s for this ns1. Aborting"
            LucilleCore::pressEnterToContinue()
            return
        end
        NSDataType0s::openFrame(ns1, ns0)
    end

    # NSDataType1::landing(ns1)
    def self.landing(ns1)
        loop {
            return if NyxObjects::getOrNull(ns1["uuid"]).nil?
            system("clear")

            Miscellaneous::horizontalRule()

            puts NSDataType1::cubeToString(ns1)

            puts "uuid: #{ns1["uuid"]}"
            description = DescriptionZ::getLastDescriptionForSourceOrNull(ns1)
            if description then
                puts "description: #{description}"
            end
            puts "date: #{NavigationPoint::getReferenceDateTime(ns1)}"
            notetext = Notes::getMostRecentTextForSourceOrNull(ns1)
            if notetext then
                puts ""
                puts "Note:"
                puts notetext.lines.map{|line| "    #{line}" }.join()
            end

            menuitems = LCoreMenuItemsNX1.new()

            description = DescriptionZ::getLastDescriptionForSourceOrNull(ns1)
            if description then
                menuitems.item(
                    "description (update)",
                    lambda{
                        description = DescriptionZ::getLastDescriptionForSourceOrNull(ns1)
                        if description.nil? then
                            description = LucilleCore::askQuestionAnswerAsString("description: ")
                        else
                            description = Miscellaneous::editTextUsingTextmate(description).strip
                        end
                        return if description == ""
                        descriptionz = DescriptionZ::issue(description)
                        Arrows::issue(ns1, descriptionz)
                    }
                )
            else
                menuitems.item(
                    "description (set)",
                    lambda{
                        description = LucilleCore::askQuestionAnswerAsString("description: ")
                        return if description == ""
                        descriptionz = DescriptionZ::issue(description)
                        Arrows::issue(ns1, descriptionz)
                    }
                )
            end
            menuitems.item(
                "datetime (update)",
                lambda{
                    datetime = Miscellaneous::editTextUsingTextmate(NavigationPoint::getReferenceDateTime(ns1)).strip
                    return if !Miscellaneous::isProperDateTime_utc_iso8601(datetime)
                    datetimez = DateTimeZ::issue(datetime)
                    Arrows::issue(ns1, datetimez)
                }
            )
            menuitems.item(
                "top note (edit)", 
                lambda{ 
                    text = Notes::getMostRecentTextForSourceOrNull(ns1) || ""
                    text = Miscellaneous::editTextUsingTextmate(text).strip
                    note = Notes::issue(text)
                    Arrows::issue(ns1, note)
                }
            )
            menuitems.item(
                "destroy",
                lambda { 
                    if LucilleCore::askQuestionAnswerAsBoolean("Are you sure to want to destroy this ns1 ? ") then
                        NyxObjects::destroy(ns1)
                    end
                }
            )

            Miscellaneous::horizontalRule()

            ns0 = NSDataType1::cubeToLastFramesOrNull(ns1)
            if ns0 then
                menuitems.item(
                    "open: #{NSDataType0s::frameToString(ns0)}",
                    lambda { NSDataType1::openLastCubeFrame(ns1) }
                )
            else
                puts "No ns0|frame found"
                menuitems.item(
                    "create ns0|frame",
                    lambda {
                        ns0 = NSDataType0s::issueNewNSDataType0InteractivelyOrNull()
                        return if ns0.nil?
                        Arrows::issue(ns1, ns0)
                    }
                )
            end

            Miscellaneous::horizontalRule()

            NSDataType1::getAsteroidsForCube(ns1).each{|asteroid|
                menuitems.item(
                    Asteroids::asteroidToString(asteroid),
                    lambda { Asteroids::landing(asteroid) }
                )
            }

            NavigationPoint::getUpstreamNavigationPoints(ns1).each{|ns|
                # Because we are a Type1, we only expect Type2s here
                menuitems.item(
                    NavigationPoint::toString(ns),
                    NavigationPoint::navigationLambda(ns)
                )
            }
            menuitems.item(
                "add #{NavigationPoint::ufn("Type2")}",
                lambda {
                    ns = NavigationPointSelection::selectExistingNavigationPointType2OrMakeNewType2OrNull()
                    return if ns.nil?
                    Arrows::issue(ns, ns1)
                }
            )
            menuitems.item(
                "remove #{NavigationPoint::ufn("Type2")}",
                lambda {
                    ns = LucilleCore::selectEntityFromListOfEntitiesOrNull("ns", NavigationPoint::getUpstreamNavigationPoints(ns1), lambda{|ns| NavigationPoint::toString(ns) })
                    return if ns.nil?
                    Arrows::remove(ns, ns1)
                }
            )

            Miscellaneous::horizontalRule()

            status = menuitems.prompt()
            break if !status
        }
    end
end
