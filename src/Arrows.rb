
# encoding: UTF-8

=begin

Arrows
{
    "uuid"       : String
    "nyxNxSet"   : "d83a3ff5-023e-482c-8658-f7cfdbb6b738"
    "unixtime"   : Float
    "sourceuuid" : String
    "targetuuid" : String
}

table: arrows
    _sourceuuid_    text
    _targetuuid_    text

=end

class ArrowsDatabaseIO

    # ArrowsDatabaseIO::databaseFilepath()
    def self.databaseFilepath()
        "#{Miscellaneous::catalystDataCenterFolderpath()}/Arrows.sqlite3"
    end

    # ArrowsDatabaseIO::arrows()
    def self.arrows()
        db = SQLite3::Database.new(ArrowsDatabaseIO::databaseFilepath())
        db.results_as_hash = true
        answer = []
        db.execute( "select * from arrows" , [] ) do |row|
            answer << {
                "sourceuuid" => row["_sourceuuid_"],
                "targetuuid" => row["_targetuuid_"]
            }
        end
        db.close
        answer
    end

    # ------------------------------------------------
    # Used by ArrowsInMemory

    # ArrowsDatabaseIO::issueOrException(source, target)
    def self.issueOrException(source, target)
        raise "[error: bc82b3b6]" if (source["uuid"] == target["uuid"])
        db = SQLite3::Database.new(ArrowsDatabaseIO::databaseFilepath())
        db.execute "delete from arrows where _sourceuuid_=? and _targetuuid_=?", [source["uuid"], target["uuid"]]
        db.execute "insert into arrows (_sourceuuid_, _targetuuid_) values ( ?, ? )", [source["uuid"], target["uuid"]]
        db.close
    end

    # ArrowsDatabaseIO::destroy(sourceuuid, targetuuid)
    def self.destroy(sourceuuid, targetuuid)
        db = SQLite3::Database.new(ArrowsDatabaseIO::databaseFilepath())
        db.execute "delete from arrows where _sourceuuid_=? and _targetuuid_=?", [sourceuuid, targetuuid]
        db.close
    end

    # ArrowsDatabaseIO::unlink(source, target)
    def self.unlink(source, target)
        ArrowsDatabaseIO::destroy(source["uuid"], target["uuid"])
    end

    # ------------------------------------------------
    # Below no longer used due to ArrowsInMemory

    # ArrowsDatabaseIO::exists?(source, target)
    def self.exists?(source, target)
        db = SQLite3::Database.new(ArrowsDatabaseIO::databaseFilepath())
        db.results_as_hash = true
        answer = false
        db.execute( "select * from arrows where _sourceuuid_=? and _targetuuid_=?" , [source["uuid"], target["uuid"]] ) do |row|
            answer = true
        end
        db.close
        answer
    end

    # ArrowsDatabaseIO::getTargetUUIDsForSource(source)
    def self.getTargetUUIDsForSource(source)
        db = SQLite3::Database.new(ArrowsDatabaseIO::databaseFilepath())
        db.results_as_hash = true
        uuids = []
        db.execute( "select * from arrows where _sourceuuid_=?" , [source["uuid"]] ) do |row|
            uuids << row["_targetuuid_"]
        end
        db.close
        uuids.uniq
    end

    # ArrowsDatabaseIO::getTargetsForSource(source)
    def self.getTargetsForSource(source)
        ArrowsDatabaseIO::getTargetUUIDsForSource(source).map{|uuid| NyxObjects2::getOrNull(uuid) }.compact
    end

    # ArrowsDatabaseIO::getSourcesForTarget(target)
    def self.getSourcesForTarget(target)
        db = SQLite3::Database.new(ArrowsDatabaseIO::databaseFilepath())
        db.results_as_hash = true
        uuids = []
        db.execute( "select * from arrows where _targetuuid_=?" , [target["uuid"]] ) do |row|
            uuids << row["_sourceuuid_"]
        end
        db.close
        uuids.uniq.map{|uuid| NyxObjects2::getOrNull(uuid) }.compact
    end
end

class ArrowsInMemory
    def initialize()
        @arrows = ArrowsDatabaseIO::arrows()
    end

    def issueOrException(source, target)
        ArrowsDatabaseIO::issueOrException(source, target)
        @arrows << {
            "sourceuuid" => source["uuid"],
            "targetuuid" => target["uuid"]
        }
    end

    def destroy(sourceuuid, targetuuid)
        ArrowsDatabaseIO::destroy(sourceuuid, targetuuid)
        @arrows = @arrows
                    .reject{|arrow| (arrow["sourceuuid"] == sourceuuid) and (arrow["targetuuid"] == targetuuid) }
    end

    def unlink(source, target)
        destroy(source["uuid"], target["uuid"])
    end

    def exists?(source, target)
        @arrows.any?{|arrow| (arrow["sourceuuid"] == source["uuid"]) and (arrow["targetuuid"] == target["uuid"]) }
    end

    def getTargetUUIDsForSource(source)
        @arrows
            .select{|arrow| arrow["sourceuuid"] == source["uuid"] }
            .map{|arrow| arrow["targetuuid"] }
            .uniq
    end

    def getTargetsForSource(source)
        getTargetUUIDsForSource(source).map{|uuid| NyxObjects2::getOrNull(uuid) }.compact
    end

    def getSourceUUIDsForTarget(target)
        @arrows
            .select{|arrow| arrow["targetuuid"] == target["uuid"] }
            .map{|arrow| arrow["sourceuuid"] }
            .uniq
    end

    def getSourcesForTarget(target)
        getSourceUUIDsForTarget(target).map{|uuid| NyxObjects2::getOrNull(uuid) }.compact
    end
end

$ArrowsInMemory099be9e4 = ArrowsInMemory.new()
