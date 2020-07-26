# encoding: UTF-8

class DataPortalUI

    # DataPortalUI::dataPortalFrontCatalyst()
    def self.dataPortalFrontCatalyst()
        loop {
            system("clear")

            ms = LCoreMenuItemsNX1.new()

            ms.item(
                "General Search (synchronous)", 
                lambda { GeneralSearch::searchAndDive() }
            )

            ms.item(
                "Graph Types Interactive Search", 
                lambda { NavigationTypes::interactiveSearchAndExplore() }
            )

            puts ""

            ms.item(
                "new point",
                lambda { 
                    point = NSDataType1::issueNewPointAndItsFirstFrameInteractivelyOrNull()
                    return if point.nil?
                    NavigationTypes::landing(point)
                }
            )

            ms.item(
                "new node",
                lambda { 
                    node = NSDataType2::issueNewNodeInteractivelyOrNull()
                    return if node.nil?
                    NavigationTypes::landing(node)
                }
            )


            ms.item(
                "Merge two nodes",
                lambda { 
                    puts "Merging two nodes"
                    puts "Selecting one after the other and then will merge"
                    node1 = NavigationTypes::selectExistingObjectInteractivelyOrNull()
                    return if node1.nil?
                    node2 = NavigationTypes::selectExistingObjectInteractivelyOrNull()
                    return if node2.nil?
                    if node1["uuid"] == node2["uuid"] then
                        puts "You have selected the same node twice. Aborting merge operation."
                        LucilleCore::pressEnterToContinue()
                        return
                    end

                    # Moving all the node upstreams of node2 towards node 1
                    NavigationTypes::getUpstreamNavigationTypes(node2).each{|x|
                        puts "arrow (1): #{NSDataType2::nodeToString(x)} -> #{NSDataType2::nodeToString(node1)}"
                    }
                    # Moving all the downstreams of node2 toward node 1
                    NavigationTypes::getDownstreamNavigationTypes(node2).each{|x|
                        puts "arrow (2): #{NSDataType2::nodeToString(node1)} -> #{NSDataType2::nodeToString(x)}"
                    }

                    return if !LucilleCore::askQuestionAnswerAsBoolean("confirm merge : ")

                    # Moving all the node upstreams of node2 towards node 1
                    NavigationTypes::getUpstreamNavigationTypes(node2).each{|x|
                        Arrows::issueOrException(x, node1)
                    }
                    # Moving all the downstreams of node2 toward node 1
                    NavigationTypes::getDownstreamNavigationTypes(node2).each{|x|
                        Arrows::issueOrException(node1, x)
                    }
                    NyxObjects::destroy(node2)
                }
            )

            ms.item(
                "dangerously edit a nyx object by uuid", 
                lambda { 
                    uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
                    return if uuid == ""
                    object = NyxObjects::getOrNull(uuid)
                    return if object.nil?
                    object = Miscellaneous::editTextSynchronously(JSON.pretty_generate(object))
                    object = JSON.parse(object)
                    NyxObjects::destroy(object)
                    NyxObjects::put(object)
                }
            )

            puts ""

            ms.item(
                "Asteroids",
                lambda { Asteroids::main() }
            )

            ms.item(
                "asteroid (new)",
                lambda { 
                    asteroid = Asteroids::issueAsteroidInteractivelyOrNull()
                    return if asteroid.nil?
                    puts JSON.pretty_generate(asteroid)
                    LucilleCore::pressEnterToContinue()
                }
            )

            ms.item(
                "asteroid floats open-project-in-the-background", 
                lambda { 
                    loop {
                        system("clear")
                        menuitems = LCoreMenuItemsNX1.new()
                        Asteroids::asteroids()
                            .select{|asteroid| asteroid["orbital"]["type"] == "open-project-in-the-background-b458aa91-6e1" }
                            .each{|asteroid|
                                menuitems.item(
                                    Asteroids::asteroidToString(asteroid),
                                    lambda { Asteroids::landing(asteroid) }
                                )
                            }
                        status = menuitems.prompt()
                        break if !status
                    }
                }
            )

            puts ""

            ms.item(
                "Calendar",
                lambda { 
                    system("open '#{Miscellaneous::catalystDataCenterFolderpath()}/Calendar/Items'") 
                }
            )

            ms.item(
                "Waves",
                lambda { Waves::main() }
            )

            puts ""

            ms.item(
                "Print Generation Speed Report", 
                lambda { CatalystObjectsOperator::generationSpeedReport() }
            )

            ms.item(
                "Curation::session()", 
                lambda { Curation::session() }
            )

            ms.item(
                "DeskOperator::commitDeskChangesToPrimaryRepository()", 
                lambda { DeskOperator::commitDeskChangesToPrimaryRepository() }
            )

            ms.item(
                "Drives::runShadowUpdate()", 
                lambda { Drives::runShadowUpdate() }
            )

            ms.item(
                "NyxGarbageCollection::run()", 
                lambda { NyxGarbageCollection::run() }
            )

            ms.item(
                "Archive timeline garbage collection", 
                lambda { 
                    puts "#{EstateServices::getArchiveT1mel1neSizeInMegaBytes()} Mb"
                    EstateServices::binTimelineGarbageCollectionEnvelop(true)
                }
            )

            status = ms.prompt()
            break if !status
        }
    end

    # DataPortalUI::dataPortalFrontDocNet()
    def self.dataPortalFrontDocNet()
        system("clear")
        puts "DocNet (Multi-user Documentation Content Managment Network)"
        LucilleCore::pressEnterToContinue()

        loop {
            system("clear")

            puts "DocNet"

            ms = LCoreMenuItemsNX1.new()

            ##General Search is not valid in docnet
            #ms.item(
            #    "general search", 
            #    lambda { GeneralSearch::searchAndDive() }
            #)

            ms.item(
                "Read user documentation", 
                lambda { 
                    system("open 'https://github.com/shtukas/catalyst/blob/master/documentation/DocNet.md'")
                }
            )

            ms.item(
                "Network Interactive Search", 
                lambda { NavigationTypes::interactiveSearchAndExplore() } # "NavigationTypes" are called Network in the DocNet context.
            )

            ms.item(
                "Make new point",
                lambda { 
                    ns1 = NSDataType1::issueNewPointAndItsFirstFrameInteractivelyOrNull()
                    return if ns1.nil?
                    NavigationTypes::landing(ns1)
                }
            )

            ms.item(
                "Make new node",
                lambda { 
                    ns2 = NSDataType2::issueNewNodeInteractivelyOrNull()
                    return if ns2.nil?
                    NavigationTypes::landing(ns2)
                }
            )

            if Miscellaneous::isAlexandra() then
                ms.item(
                    "Merge two nodes",
                    lambda { 
                        puts "Merging two nodes"
                        puts "Selecting one after the other and then will merge"
                        node1 = NavigationTypes::selectExistingObjectInteractivelyOrNull()
                        return if node1.nil?
                        node2 = NavigationTypes::selectExistingObjectInteractivelyOrNull()
                        return if node2.nil?
                        if node1["uuid"] == node2["uuid"] then
                            puts "You have selected the same node twice. Aborting merge operation."
                            LucilleCore::pressEnterToContinue()
                            return
                        end

                        # Moving all the node upstreams of node2 towards node 1
                        NavigationTypes::getUpstreamNavigationTypes(node2).each{|x|
                            puts "arrow (1): #{NSDataType2::nodeToString(x)} -> #{NSDataType2::nodeToString(node1)}"
                        }
                        # Moving all the downstreams of node2 toward node 1
                        NavigationTypes::getDownstreamNavigationTypes(node2).each{|x|
                            puts "arrow (2): #{NSDataType2::nodeToString(node1)} -> #{NSDataType2::nodeToString(x)}"
                        }

                        return if !LucilleCore::askQuestionAnswerAsBoolean("confirm merge : ")

                        # Moving all the node upstreams of node2 towards node 1
                        NavigationTypes::getUpstreamNavigationTypes(node2).each{|x|
                            Arrows::issueOrException(x, node1)
                        }
                        # Moving all the downstreams of node2 toward node 1
                        NavigationTypes::getDownstreamNavigationTypes(node2).each{|x|
                            Arrows::issueOrException(node1, x)
                        }
                        NyxObjects::destroy(node2)
                    }
                )
            end

            if Miscellaneous::isAlexandra() then
                ms.item(
                    "dangerously edit a nyx object by uuid", 
                    lambda { 
                        uuid = LucilleCore::askQuestionAnswerAsString("uuid: ")
                        return if uuid == ""
                        object = NyxObjects::getOrNull(uuid)
                        return if object.nil?
                        object = Miscellaneous::editTextSynchronously(JSON.pretty_generate(object))
                        object = JSON.parse(object)
                        NyxObjects::destroy(object)
                        NyxObjects::put(object)
                    }
                )
            end

            if Miscellaneous::isAlexandra() then
                ms.item(
                    "Curation::session()", 
                    lambda { Curation::session() }
                )
            end

            ms.item(
                "Run network synchronization", 
                lambda { DataStoresOrchestration::fullSync() }
            )

            ms.item(
                "Show dataset statistics", 
                lambda { 
                    system("clear")
                    NyxPrimaryObjects::nyxNxSets().each{|setid|
                        puts "-> setid: #{setid}, count:#{NyxObjects::getSet(setid).size}"
                    }
                    LucilleCore::pressEnterToContinue()
                }
            )

            ms.item(
                "exit", 
                lambda { exit }
            )

            status = ms.prompt()
            # break if !status
        }
    end

    # DataPortalUI::dataPortalFront()
    def self.dataPortalFront()
        if Realms::isCatalyst() then
            DataPortalUI::dataPortalFrontCatalyst()
            return
        end
        if Realms::isDocnet() then
            DataPortalUI::dataPortalFrontDocNet()
            return
        end
        Realms::raiseException()
    end
end


