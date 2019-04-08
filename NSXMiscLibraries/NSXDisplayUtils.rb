#!/usr/bin/ruby

# encoding: UTF-8

class NSXDisplayUtils

    # NSXDisplayUtils::objectInferfaceString(object)
    def self.objectInferfaceString(object)
        announce = object['announce'].strip
        part2 = 
            [
                object["commands"] ? " #{object["commands"].join(" ")}" : '',
                object["defaultExpression"] ? " (#{object["defaultExpression"].green})" : ""
            ].join()
        part2.strip
    end

    # NSXDisplayUtils::objectCatalystListingDisplayString(object, isFocus)
    def self.objectCatalystListingDisplayString(object, isFocus)
        object["commands"] = object["commands"].reject{|command| command.include?('planning') }
        object["commands"] = ( NSXMiscUtils::hasPlanningText(object["uuid"]) ? ["planning".green] : ["planning".yellow] ) + object["commands"]
        if isFocus then
            if object['body'] then
                [
                    object['body'],
                    "\n" + NSXDisplayUtils::objectInferfaceString(object),
                ].join()
            else
                [
                    "-> ",
                   object['announce'],
                   "\n" + NSXDisplayUtils::objectInferfaceString(object),
                ].join()
            end
        else
            "-> "+object['announce'][0,NSXMiscUtils::screenWidth()-9]
        end
    end

    # NSXDisplayUtils::doPresentObjectInviteAndExecuteCommand(object)
    def self.doPresentObjectInviteAndExecuteCommand(object)
        return if object.nil?
        puts NSXDisplayUtils::objectCatalystListingDisplayString(object, true)
        puts NSXDisplayUtils::objectInferfaceString(object)
        print "-->(2) "
        command = STDIN.gets().strip
        command = command.size>0 ? command : ( object["defaultExpression"] ? object["defaultExpression"] : "" )
        NSXGeneralCommandHandler::processCommand(object, command)
    end

    # NSXDisplayUtils::doListCalaystObjectsAndSeLectedOneObjectAndInviteAndExecuteCommand(objects): Boolean
    # Return value specifies if an oject was chosen and processed
    def self.doListCalaystObjectsAndSeLectedOneObjectAndInviteAndExecuteCommand(objects)
        object = LucilleCore::selectEntityFromListOfEntitiesOrNull("object", objects, lambda{|object| object['announce'] })
        return false if object.nil?
        NSXDisplayUtils::doPresentObjectInviteAndExecuteCommand(object)
        true
    end

    # NSXDisplayUtils::verticalSize(displayStr)
    def self.verticalSize(displayStr)
        displayStr.lines.map{|line| (line.size.to_f/NSXMiscUtils::screenWidth()).ceil }.inject(0, :+)
    end
end