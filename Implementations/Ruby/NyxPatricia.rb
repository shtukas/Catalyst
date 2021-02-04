
# encoding: UTF-8

class NyxPatricia

    # -------------------------------------------------------

    # NyxPatricia::isNereidElement(element)
    def self.isNereidElement(element)
        !element["payload"].nil?
    end

    # NyxPatricia::isNX141FSCacheElement(element)
    def self.isNX141FSCacheElement(element)
        element["nyxElementType"] == "736ec8c8-daa6-48cf-8d28-84cfca79bedc"
    end

    # NyxPatricia::isEvent(element)
    def self.isEvent(element)
        element["nyxElementType"] == "ea9f4f69-1c8c-49c9-b644-8854c1be75d8"
    end

    def self.isClassifier(item)
        item["nyxElementType"] == "22f244eb-4925-49be-bce6-db58c2fb489a"
    end

    # -------------------------------------------------------

    # NyxPatricia::getDX7ByUUIDOrNull(uuid)
    def self.getDX7ByUUIDOrNull(uuid)
        element = NereidInterface::getElementOrNull(uuid)
        return element if element

        element = NX141FSCacheElement::getElementByUUIDOrNull(uuid)
        return element if element

        element = Events::getEventForUUIDOrNull(uuid)
        return element if element

        element = Classifiers::getClassifierByUUIDOrNull(uuid)
        return element if element
        nil
    end

    # NyxPatricia::dx7toString(item)
    def self.dx7toString(item)
        if NyxPatricia::isNereidElement(item) then
            return NereidInterface::toString(item)
        end
        if NyxPatricia::isNX141FSCacheElement(item) then
            return NX141FSCacheElement::toString(item)
        end
        if NyxPatricia::isEvent(item) then
            return Events::toString(item)
        end
        if NyxPatricia::isClassifier(item) then
            return Classifiers::toString(item)
        end
        raise "error: 4a902479-4a5e-4d05-9aa1-287f6a4f16d6"
    end

    # NyxPatricia::dx7access(item)
    def self.dx7access(item)
        if NyxPatricia::isNereidElement(item) then
            NereidInterface::access(item)
            return
        end
        if NyxPatricia::isNX141FSCacheElement(item) then
            NX141FSCacheElement::access(item["nx141"])
            return
        end
        if NyxPatricia::isEvent(item) then
            Events::landing(item)
            return
        end
        if NyxPatricia::isClassifier(item) then
            Classifiers::landing(item)
            return
        end
        puts item
        raise "error: 22830b8a-f43d-4f0e-b419-21f809d99404"
    end

    # NyxPatricia::dx7landing(item)
    def self.dx7landing(item)
        if NyxPatricia::isNereidElement(item) then
            NereidProxyOperator::landing(item)
            return
        end
        if NyxPatricia::isNX141FSCacheElement(item) then
            NX141FSCacheElement::landing(item)
            return
        end
        if NyxPatricia::isEvent(item) then
            Events::landing(item)
            return
        end
        if NyxPatricia::isClassifier(item) then
            Classifiers::landing(item)
            return
        end
        puts item
        raise "[error: d7c85779-7085-4f04-aec8-ec019ccc1795]"
    end

    # -------------------------------------------------------

    # NyxPatricia::architectDX7OrNull()
    def self.architectDX7OrNull()
        dx7 = NyxPatricia::selectOneDX7OrNull()
        return dx7 if dx7
        ops = ["Classifier", "Event", "Nereid data carrier"]
        operation = LucilleCore::selectEntityFromListOfEntitiesOrNull("type", ops)
        return if operation.nil?
        if operation == "Nereid data carrier" then
            return NereidInterface::interactivelyIssueNewElementOrNull()
        end
        if operation == "Event" then
            return Events::interactivelyIssueNewEventOrNull()
        end
        if operation == "Classifier" then
            return Classifiers::interactivelyIssueNewClassifierOrNull()
        end        
    end

    # NyxPatricia::architectAddParentForDX7(item)
    def self.architectAddParentForDX7(item)
        e1 = NyxPatricia::architectDX7OrNull()
        return if e1.nil?
        NyxArrows::issueArrow(e1["uuid"], item["uuid"])
    end

    # NyxPatricia::architectAddChildForDX7(item)
    def self.architectAddChildForDX7(item)
        e1 = NyxPatricia::architectDX7OrNull()
        return if e1.nil?
        NyxArrows::issueArrow(item["uuid"], e1["uuid"])
    end

    # NyxPatricia::selectAndRemoveOneParentFromDX7(item)
    def self.selectAndRemoveOneParentFromDX7(item)
        parents = NyxArrows::getParentsUUIDs(item["uuid"])
                    .map{|uuid| NyxPatricia::getDX7ByUUIDOrNull(uuid) }
                    .compact
        return if parents.empty?
        parent = LucilleCore::selectEntityFromListOfEntitiesOrNull("parent", parents, lambda{|parent| NyxPatricia::dx7toString(parent) })
        return if parent.nil?
        NyxArrows::deleteArrow(parent["uuid"], item["uuid"])
    end

    # NyxPatricia::selectAndRemoveOneChildFromDX7(item)
    def self.selectAndRemoveOneChildFromDX7(item)
        children = NyxArrows::getChildrenUUIDs(item["uuid"])
                    .map{|uuid| NyxPatricia::getDX7ByUUIDOrNull(uuid) }
                    .compact
        return if children.empty?
        child = LucilleCore::selectEntityFromListOfEntitiesOrNull("child", children, lambda{|child| NyxPatricia::dx7toString(child) })
        return if child.nil?
        NyxArrows::deleteArrow(item["uuid", child["uuid"]])
    end

    # -------------------------------------------------------

    # NyxPatricia::nyxSearchItemsAll()
    def self.nyxSearchItemsAll()
        searchItems = [
            Classifiers::nyxSearchItems(),
            NereidProxyOperator::nyxSearchItems(),
            NX141FSCacheElement::nyxSearchItems(),
            Events::nyxSearchItems()
        ]
        .flatten
    end

    # NyxPatricia::selectOneDX7OrNull()
    def self.selectOneDX7OrNull()
        searchItem = NyxUtils::selectOneOrNull(NyxPatricia::nyxSearchItemsAll(), lambda{|item| item["announce"] })
        return nil if searchItem.nil?
        searchItem["payload"]
    end

    # NyxPatricia::generalSearchLoop()
    def self.generalSearchLoop()
        loop {
            dx7 = NyxPatricia::selectOneDX7OrNull()
            break if dx7.nil? 
            NyxPatricia::dx7landing(dx7)
        }
    end
end