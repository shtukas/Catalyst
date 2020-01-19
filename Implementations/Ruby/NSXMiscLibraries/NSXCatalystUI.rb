# encoding: UTF-8

# This variable contains the objects of the current display.
# We use it to speed up display after some operations

require "/Users/pascal/Galaxy/2020-LucilleOS/Software-Common/Ruby-Libraries/KeyValueStore.rb"
=begin
    KeyValueStore::setFlagTrue(repositorylocation or nil, key)
    KeyValueStore::setFlagFalse(repositorylocation or nil, key)
    KeyValueStore::flagIsTrue(repositorylocation or nil, key)

    KeyValueStore::set(repositorylocation or nil, key, value)
    KeyValueStore::getOrNull(repositorylocation or nil, key)
    KeyValueStore::getOrDefaultValue(repositorylocation or nil, key, defaultValue)
    KeyValueStore::destroy(repositorylocation or nil, key)
=end

class NSXCatalystUI

    # NSXCatalystUI::stringOrFirstString(content_type)
    def self.stringOrFirstString(content_type)
        if content_type.class.to_s == "String" then
            content_type
        else
            content_type.first
        end
    end

    # NSXCatalystUI::printLucilleInstanceFileAsNext()
    def self.printLucilleInstanceFileAsNext()
        struct2 = LucilleFileUtils::getStruct()
        nextContents = struct2[0]
                        .map{|section| section.strip }
                        .first(10)
                        .join("\n")
        if nextContents.size > 0 then
            puts "-- [] " + "-" * (NSXMiscUtils::screenWidth()-7)
            puts nextContents.strip.green
            puts "-" * (NSXMiscUtils::screenWidth()-1)
            nextContents.lines.to_a.size + 2
        else
            0
        end
    end

    # NSXCatalystUI::performPrimaryDisplayWithCatalystObjects(displayObjects)
    def self.performPrimaryDisplayWithCatalystObjects(displayObjects)

        system("clear")

        verticalSpaceLeft = NSXMiscUtils::screenHeight()-2

        vspace = NSXCatalystUI::printLucilleInstanceFileAsNext()
        verticalSpaceLeft = verticalSpaceLeft - vspace

        focusobject = nil

        if displayObjects.size==0 then
            puts "No objects found"
            print "--> "
            command = STDIN.gets().strip
            NSXGeneralCommandHandler::processCatalystCommandManager(nil, command)
            return
        end

        displayObjectForListing = displayObjects.map{|object| object.clone }
        # displayObjectForListing is being consumed while displayObjects should remain static

        position = 0

        while displayObjectForListing.size>0 do

            # Position management
            position = position + 1
            object = displayObjectForListing.shift
            if position == 1 then
                focusobject = object
            end
            displayStr = NSXDisplayUtils::objectDisplayStringForCatalystListing(object, position == 1, position)
            verticalSize = NSXDisplayUtils::verticalSize(displayStr)
            break if (position > 1) and (verticalSpaceLeft < verticalSize) and (displayObjectForListing + [object]).none?{|object| object["isRunning"] }

            # Display
            puts displayStr
            verticalSpaceLeft = verticalSpaceLeft - verticalSize
            break if verticalSpaceLeft<=0 and displayObjectForListing.none?{|object| object["isRunning"] }
        end

        if focusobject.nil? then
            puts "Nothing to do for the moment (^_^)"
        end

        # -----------------------------------------------------------------------------------

        print "--> "
        command = STDIN.gets().strip
        if command=='' then
            return
        end

        # -----------------------------------------------------------------------------------

        if command.start_with?("'") then
            position = command[1,9].strip.to_i
            return if position==0
            return if position > displayObjects.size
            object = displayObjects[position-1]
            NSXDisplayUtils::doPresentObjectInviteAndExecuteCommand(object)
            return
        end

        NSXGeneralCommandHandler::processCatalystCommandManager(focusobject, command)
    end

    # NSXCatalystUI::performCalendarDisplay()
    def self.performCalendarDisplay()
        system("clear")
        verticalSpace = NSXMiscUtils::screenHeight()-4
        contents = IO.read("/Users/pascal/Desktop/Calendar.txt").strip
        contents = contents.lines.first(verticalSpace).join()
        puts "Calendar:".green
        puts contents
        LucilleCore::pressEnterToContinue()
    end

    # NSXCatalystUI::standardUILoop()
    def self.standardUILoop()
        loop {
            if STARTING_CODE_HASH != NSXEstateServices::locationHashRecursively(CATALYST_CODE_FOLDERPATH) then
                puts "Code change detected. Exiting."
                return
            end
            NSXEstateServices::collectInboxPackage()
            objects = NSXCatalystObjectsOperator::getCatalystListingObjectsOrdered()
            if !KeyValueStore::flagIsTrue(nil, "4b07d6f1-c5b3-4309-bdec-1ca488ed8350:#{NSXMiscUtils::currentDay()}") then
                NSXCatalystUI::performCalendarDisplay()
                KeyValueStore::setFlagTrue(nil, "4b07d6f1-c5b3-4309-bdec-1ca488ed8350:#{NSXMiscUtils::currentDay()}")
                next
            end
            NSXCatalystUI::performPrimaryDisplayWithCatalystObjects(objects)
        }
    end
end


