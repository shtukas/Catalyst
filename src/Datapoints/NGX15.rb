
# encoding: UTF-8

class NGX15

    # NGX15::ngx15s()
    def self.ngx15s()
        NyxObjects2::getSet("0f555c97-3843-4dfe-80c8-714d837eba69")
    end

    # NGX15::issueNGX15(code)
    def self.issueNGX15(code)
        object = {
            "uuid"       => SecureRandom.uuid,
            "nyxNxSet"   => "0f555c97-3843-4dfe-80c8-714d837eba69",
            "unixtime"   => Time.new.to_f,
            "ngx15"      => code
        }
        NyxObjects2::put(object)
        object
    end

    # NGX15::issueNewNGX15InteractivelyOrNull()
    def self.issueNewNGX15InteractivelyOrNull()
        op = LucilleCore::selectEntityFromListOfEntitiesOrNull("mode", ["location already exists", "issue new location name"])
        return nil if op.nil?
        if op == "location already exists" then
            code = LucilleCore::askQuestionAnswerAsString("code name: ")
            return nil if code.size == 0
        end
        if op == "issue new location name" then
            code = "NGX15-#{SecureRandom.uuid}"
            puts "code: #{code}"
            LucilleCore::pressEnterToContinue()
        end
        NGX15::issueNGX15(code)
    end

    # NGX15::toString(ngx15)
    def self.toString(ngx15)
        if NGX15_Extended1::ngx15IsExtended(ngx15) then
            return "[NGX15] [Extended] #{ngx15["description"]} ; #{NGX15_Extended1::toString(ngx15)}"
        end
        if ngx15["description"] then
            return "[NGX15] #{ngx15["description"]} ( #{ngx15["ngx15"]} )"
        end
        "[NGX15] #{ngx15["ngx15"]}"
    end

    # NGX15::openNGX15(ngx15)
    def self.openNGX15(ngx15)
        location = GalaxyFinder::uniqueStringToLocationOrNull(ngx15["ngx15"])
        if location then
            puts "target file '#{location}'"
            if File.file?(location) then
                system("open '#{File.dirname(location)}'")
            else
                system("open '#{location}'")
            end
            LucilleCore::pressEnterToContinue()
        else
            puts "I could not determine the location of #{ngx15["ngx15"]}"
            LucilleCore::pressEnterToContinue()
        end
    end

    # NGX15::landing(ngx15)
    def self.landing(ngx15)
        loop {

            return if NyxObjects2::getOrNull(ngx15["uuid"]).nil?

            system("clear")

            mx = LCoreMenuItemsNX1.new()

            puts ""

            puts NGX15::toString(ngx15).green
            puts "uuid: #{ngx15["uuid"]}".yellow
            puts "date: #{GenericNyxObject::getObjectReferenceDateTime(ngx15)}".yellow

            puts ""

            mx.item(
                "open".yellow,
                lambda {
                    NGX15::openNGX15(ngx15)
                }
            )

            mx.item("set/update description".yellow, lambda {
                description = Miscellaneous::editTextSynchronously(ngx15["description"] || "").strip
                return if description == ""
                ngx15["description"] = description
                NyxObjects2::put(ngx15)
            })

            mx.item("set/update datetime".yellow, lambda {
                datetime = Miscellaneous::editTextSynchronously(ngx15["referenceDateTime"] || Time.new.utc.iso8601).strip
                ngx15["referenceDateTime"] = datetime
                NyxObjects2::put(ngx15)
            })

            mx.item("add tag".yellow, lambda {
                set = Tags::selectExistingTagOrMakeNewOneOrNull()
                return if set.nil?
                Arrows::issueOrException(set, ngx15)
            })

            mx.item("add to listing".yellow, lambda {
                node = Listings::extractionSelectListingOrMakeListingOrNull()
                return if node.nil?
                Arrows::issueOrException(node, ngx15)
            })

            mx.item("remove from listing".yellow, lambda {
                xnodes = Arrows::getSourcesForTargetOfGivenNyxType(ngx15, "abb20581-f020-43e1-9c37-6c3ef343d2f5") + Arrows::getSourcesForTargetOfGivenNyxType(ngx15, "f1ae7449-16d5-41c0-a89e-f2a8e486cc99")
                xnode = LucilleCore::selectEntityFromListOfEntitiesOrNull("xnodes", xnodes, lambda { |xnode| GenericNyxObject::toString(xnode) })
                return if xnode.nil?
                Arrows::unlink(xnode, ngx15)
            })

            mx.item("destroy".yellow, lambda {
                if LucilleCore::askQuestionAnswerAsBoolean("Are you sure you want to destroy '#{NGX15::toString(ngx15)}': ") then
                    NGX15::ngx15TerminationProtocolReturnBoolean(ngx15)
                end
            })

            puts ""

            sources = Arrows::getSourcesForTarget(ngx15)
            sources.each{|source|
                mx.item(
                    "source: #{GenericNyxObject::toString(source)}",
                    lambda { GenericNyxObject::landing(source) }
                )
            }

            puts ""

            Arrows::getTargetsForSource(ngx15).each{|target|
                menuitems.item(
                    "target: #{GenericNyxObject::toString(target)}",
                    lambda { GenericNyxObject::landing(target) }
                )
            }

            puts ""

            status = mx.promptAndRunSandbox()
            break if !status
        }
    end

    # NGX15::ngx15TerminationProtocolReturnBoolean(ngx15)
    def self.ngx15TerminationProtocolReturnBoolean(ngx15)

        puts "Destroying ngx15: #{NGX15::toString(ngx15)}"

        location = GalaxyFinder::uniqueStringToLocationOrNull(ngx15["ngx15"])
        if location then
            puts "Target file '#{location}'"
            puts "Delete as appropriate"
            system("open '#{File.dirname(location)}'")
            LucilleCore::pressEnterToContinue()
        else
            puts "I could not determine the location of #{ngx15["ngx15"]}"
            if !LucilleCore::askQuestionAnswerAsBoolean("Continue with ngx15 deletion ? ") then
                return
            end
        end

        NyxObjects2::destroy(ngx15)

        true
    end
end

class NGX15_Extended1

    # NGX15_Extended1::isDigit(char)
    def self.isDigit(char)
        ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].include?(char)
    end

    # NGX15_Extended1::filenameiIsExtended1(filename)
    def self.filenameiIsExtended1(filename)
        return false if filename.size < 3
        return false if filename[0, 1] != "X"
        return false if !NGX15_Extended1::isDigit(filename[1, 1])
        return false if !NGX15_Extended1::isDigit(filename[2, 1])
        true
    end

    # NGX15_Extended1::filepathIsExtended1(filepath)
    def self.filepathIsExtended1(filepath)
        NGX15_Extended1::filenameiIsExtended1(File.basename(filepath))
    end

    # NGX15_Extended1::folderIsExtended1(folderpath)
    def self.folderIsExtended1(folderpath)
        return false if LucilleCore::locationsAtFolder(folderpath).size == 0
        LucilleCore::locationsAtFolder(folderpath)
            .all?{|location|
                NGX15_Extended1::filepathIsExtended1(location)
            }
    end

    # NGX15_Extended1::ngx15IsExtended(ngx15)
    def self.ngx15IsExtended(ngx15)
        location = GalaxyFinder::uniqueStringToLocationOrNull(ngx15["ngx15"])
        return false if File.file?(location)
        NGX15_Extended1::folderIsExtended1(location)
    end

    # NGX15_Extended1::transformPathFragmentForToString(fragment)
    def self.transformPathFragmentForToString(fragment)
        fragment.split("/").drop(1).map{|t| t[3, t.size].strip }.join(" ; ")
    end

    # NGX15_Extended1::toStringCore(originalFolderPath, currentLocationCursor)
    def self.toStringCore(originalFolderPath, currentLocationCursor)
        if File.file?(currentLocationCursor) then
            fragment = currentLocationCursor[originalFolderPath.size, currentLocationCursor.size]
            NGX15_Extended1::transformPathFragmentForToString(fragment)
        else
            if !NGX15_Extended1::folderIsExtended1(currentLocationCursor) then
                fragment = currentLocationCursor[originalFolderPath.size, currentLocationCursor.size]
                NGX15_Extended1::transformPathFragmentForToString(fragment)
            else
                NGX15_Extended1::toStringCore(originalFolderPath, LucilleCore::locationsAtFolder(currentLocationCursor).sort.first)
            end
        end
    end

    # NGX15_Extended1::toString(ngx15)
    def self.toString(ngx15)
        location = GalaxyFinder::uniqueStringToLocationOrNull(ngx15["ngx15"])
        NGX15_Extended1::toStringCore(location, location)
    end
end
