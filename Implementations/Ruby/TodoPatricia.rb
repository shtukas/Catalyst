
# encoding: UTF-8

class TodoPatricia

    # -----------------------------------------------
    # is

    # TodoPatricia::isQuark(object)
    def self.isQuark(object)
        object["nyxNxSet"] == "d65674c7-c8c4-4ed4-9de9-7c600b43eaab"
    end

    # TodoPatricia::isWave(object)
    def self.isWave(object)
        object["nyxNxSet"] == "7deb0315-98b5-4e4d-9ad2-d83c2f62e6d4"
    end

    # TodoPatricia::isDxThread(object)
    def self.isDxThread(object)
        object["nyxNxSet"] == "2ed4c63e-56df-4247-8f20-e8d220958226"
    end

    # -----------------------------------------------
    # gets

    # TodoPatricia::toString(object)
    def self.toString(object)
        if TodoPatricia::isQuark(object) then
            return Quarks::toString(object)
        end
        if TodoPatricia::isWave(object) then
            return Waves::toString(object)
        end
        if TodoPatricia::isDxThread(object) then
            return DxThreads::toString(object)
        end
        puts object
        raise "[error: d4c62cad-0080-4270-82a9-81b518c93c0e]"
    end

    # -----------------------------------------------
    # operations

    # TodoPatricia::landing(object)
    def self.landing(object)
        if TodoPatricia::isQuark(object) then
            Quarks::landing(object)
            return
        end
        if TodoPatricia::isWave(object) then
            Waves::landing(object)
            return 
        end
        if TodoPatricia::isDxThread(object) then
            return DxThreads::landing(object)
        end
        puts object
        raise "[error: fb2fb533-c9e5-456e-a87f-0523219e91b7]"
    end

    # TodoPatricia::destroy(object)
    def self.destroy(object)
        if TodoPatricia::isQuark(object) then
            Quarks::destroyQuarkAndNereidContent(object)
            return
        end
        puts object
        raise "[error: 09e17b29-8620-4345-b358-89c58c248d6f]"
    end

    # --------------------------------------------------
    # User Interface (Part 1)

    # TodoPatricia::selectOneTargetOrNullDefaultToSingletonWithConfirmation(object)
    def self.selectOneTargetOrNullDefaultToSingletonWithConfirmation(object)
        targets = TodoArrows::getTargetsForSource(object)
        if targets.size == 0 then
            return nil
        end
        if targets.size == 1 then
            if LucilleCore::askQuestionAnswerAsBoolean("selecting target: '#{TodoPatricia::toString(targets[0])}' confirm ? ", true) then
                return targets[0]
            end
            return nil
        end
        LucilleCore::selectEntityFromListOfEntitiesOrNull("target", targets, lambda{|target| TodoPatricia::toString(target) })
    end

    # TodoPatricia::selectOneTargetOfThisObjectOrNull(object)
    def self.selectOneTargetOfThisObjectOrNull(object)
        LucilleCore::selectEntityFromListOfEntitiesOrNull("target", TodoArrows::getTargetsForSource(object), lambda{|t| TodoPatricia::toString(t) })
    end

    # TodoPatricia::selectZeroOrMoreTargetsFromThisObject(object)
    def self.selectZeroOrMoreTargetsFromThisObject(object)
        selected, _ = LucilleCore::selectZeroOrMore("target", [], TodoArrows::getTargetsForSource(object), lambda{|t| TodoPatricia::toString(t) })
        selected
    end

    # TodoPatricia::selectOneParentOfThisObjectOrNull(object)
    def self.selectOneParentOfThisObjectOrNull(object)
        LucilleCore::selectEntityFromListOfEntitiesOrNull("target", TodoArrows::getSourcesForTarget(object), lambda{|t| TodoPatricia::toString(t) })
    end

    # --------------------------------------------------
    # Architect

    # TodoPatricia::computeNew21stOrdinalForDxThread(dxthread)
    def self.computeNew21stOrdinalForDxThread(dxthread)
        ordinals = TodoArrows::getTargetsForSource(dxthread)
                    .map{|t| Ordinals::getObjectOrdinal(t) }
                    .sort
        ordinals = ordinals.drop(19).take(2)
        if ordinals.size < 2 then
            return Ordinals::computeNextOrdinal()
        end
        (ordinals[0]+ordinals[1]).to_f/2
    end

    # TodoPatricia::set21stOrdinalForObjectAtDxThread(dxthread, object)
    # This is called when an object is created by Todo-Inbox or vienna-import
    def self.set21stOrdinalForObjectAtDxThread(dxthread, object)
        ordinal = TodoPatricia::computeNew21stOrdinalForDxThread(dxthread)
        Ordinals::setOrdinalForUUID(object["uuid"], ordinal)
    end

    # TodoPatricia::moveTargetToNewDxThread(quark, dxParentOpt or null)
    def self.moveTargetToNewDxThread(quark, dxParentOpt)
        dx2 = DxThreads::selectOneExistingDxThreadOrNull()
        return if dx2.nil?
        TodoArrows::issueOrException(dx2, quark)
        TodoArrows::unlink(dxParentOpt, quark) if dxParentOpt
        ordinal = DxThreads::determinePlacingOrdinalForThread(dx2)
        Ordinals::setOrdinalForUUID(quark["uuid"], ordinal)
    end

    # TodoPatricia::getQuarkPossiblyArchitectedOrNull(quarkOpt, dxThreadOpt)
    def self.getQuarkPossiblyArchitectedOrNull(quarkOpt, dxThreadOpt)
        quark = quarkOpt ? quarkOpt : Quarks::issueNewQuarkInteractivelyOrNull()
        return nil if quark.nil?
        dxthread = dxThreadOpt ? dxThreadOpt : DxThreads::selectOneExistingDxThreadOrNull()
        return nil if dxthread.nil?
        TodoArrows::issueOrException(dxthread, quark)
        ordinal = DxThreads::determinePlacingOrdinalForThread(dxthread)
        Ordinals::setOrdinalForUUID(quark["uuid"], ordinal)
        TodoPatricia::landing(quark)
        quark
    end
end