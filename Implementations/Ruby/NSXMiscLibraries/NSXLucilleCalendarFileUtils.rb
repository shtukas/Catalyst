# encoding: UTF-8

=begin

Struct1 [
    Part # Notes           : String
    Part # Catalyst Items  : String
    Part # Calendar Future : String
    Part # Birthdays       : Strimg
]

Struct2 [
    Part # Notes            : String
    Sections                : Array[String] # Individual strings are sections
    Part # Calendar Future  : String
    Part # Birthdays        : String
]

=end

class NSXLucilleCalendarFileUtils

    # NSXLucilleCalendarFileUtils::sectionToSectionUUID(section)
    def self.sectionToSectionUUID(section)
        Digest::SHA1.hexdigest(section.strip)[0, 8]
    end

    # NSXLucilleCalendarFileUtils::fileContentsToStruct1(content) : Struct1
    def self.fileContentsToStruct1(content)
        content.split(LUCILLE_FILE_MARKER)
    end

    # NSXLucilleCalendarFileUtils::fileContentsToStruct2(content) : Struct2
    def self.fileContentsToStruct2(content)
        struct1 = NSXLucilleCalendarFileUtils::fileContentsToStruct1(content)
        [
            struct1[0],
            SectionsType0141::contentToSections(struct1[1].lines.to_a),
            struct1[2],
            struct1[3]
        ]
    end

    # NSXLucilleCalendarFileUtils::struct2ToFileContent(struct2)
    def self.struct2ToFileContent(struct2)
        [
            struct2[0],
            LUCILLE_FILE_MARKER + "\n\n",
            struct2[1].map{|str| str.strip}.join("\n").strip,
            "\n\n",
            LUCILLE_FILE_MARKER,
            struct2[2],
            LUCILLE_FILE_MARKER,
            struct2[3]
        ].join()
    end

    # NSXLucilleCalendarFileUtils::commitStruct2ToDisk(struct2)
    def self.commitStruct2ToDisk(struct2)
        filepath = "/Users/pascal/Desktop/Calendar.txt"
        File.open(filepath, "w") { |io| io.puts(NSXLucilleCalendarFileUtils::struct2ToFileContent(struct2)) }
    end

    # NSXLucilleCalendarFileUtils::applyNextTransformationToStruct2(struct2)
    def self.applyNextTransformationToStruct2(struct2)
        return struct2 if struct2[1].empty?
        text = NSXMiscUtils::applyNextTransformationToContent(struct2[1][0])
        text = text.strip
        text = NSXLucilleCalendarFileUtils::recursivelyRemoveEmptyLineIfInSecondPosition(text)
        struct2[1][0] = text
        struct2
    end

    # NSXLucilleCalendarFileUtils::getStruct()
    def self.getStruct()
        filepath = "/Users/pascal/Desktop/Calendar.txt"
        NSXLucilleCalendarFileUtils::fileContentsToStruct2(IO.read(filepath))
    end

    # NSXLucilleCalendarFileUtils::trueIfTodoItemsInFile()
    def self.trueIfTodoItemsInFile()
        (IO.read("/Users/pascal/Desktop/Calendar.txt").split("@marker-51B5803C-F4B2-4CB3-B26B-6F2E99E2AA44"))[1].strip.size > 0
    end

    # NSXLucilleCalendarFileUtils::commitFileCopyToBin()
    def self.commitFileCopyToBin()
        filepath = "/Users/pascal/Desktop/Calendar.txt"
        NSXMiscUtils::copyLocationToCatalystBin(filepath)
    end

    # NSXLucilleCalendarFileUtils::writeANewLucilleFileWithoutThisSectionUUID(uuid)
    def self.writeANewLucilleFileWithoutThisSectionUUID(uuid)
        NSXLucilleCalendarFileUtils::commitFileCopyToBin()
        struct2 = NSXLucilleCalendarFileUtils::getStruct()
        struct2[1] = struct2[1].reject{|section|
            NSXLucilleCalendarFileUtils::sectionToSectionUUID(section) == uuid
        }
        NSXLucilleCalendarFileUtils::commitStruct2ToDisk(struct2)
    end

    # NSXLucilleCalendarFileUtils::applyNextTransformationToLucilleFile()
    def self.applyNextTransformationToLucilleFile()
        NSXLucilleCalendarFileUtils::commitFileCopyToBin()
        struct2 = NSXLucilleCalendarFileUtils::getStruct()
        struct2 = NSXLucilleCalendarFileUtils::applyNextTransformationToStruct2(struct2)
        NSXLucilleCalendarFileUtils::commitStruct2ToDisk(struct2)
    end

    # NSXLucilleCalendarFileUtils::injectNewLineInPart1OfTheFile(line)
    def self.injectNewLineInPart1OfTheFile(line)
        NSXLucilleCalendarFileUtils::commitFileCopyToBin()
        struct2 = NSXLucilleCalendarFileUtils::getStruct()
        sections = struct2[1]
        sections << line
        struct2[1] = sections
        NSXLucilleCalendarFileUtils::commitStruct2ToDisk(struct2)
    end

    # NSXLucilleCalendarFileUtils::recursivelyRemoveEmptyLineIfInSecondPosition(text)
    def self.recursivelyRemoveEmptyLineIfInSecondPosition(text)
        lines = text.lines.to_a
        return text if lines.size <= 2
        if lines[1].strip.size==0 then
            lines[1] = nil
            text = lines.compact.join()
            return NSXLucilleCalendarFileUtils::recursivelyRemoveEmptyLineIfInSecondPosition(text)
        end
        text
    end

end