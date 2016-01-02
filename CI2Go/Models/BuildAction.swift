//
//  BuildAction.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/1/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import RealmSwift
import ObjectMapper

class BuildAction: Object, Mappable, Equatable, Comparable {
    enum Status: String {
        case Success = "success"
        case Failed = "failed"
        case Canceled = "canceled"
        case Timedout = "timedout"
        case Running = "running"
    }
    dynamic var bashCommand = ""
    dynamic var buildStep: BuildStep? {
        didSet { updateId() }
    }
    dynamic var stepNumber: Int = 0
    dynamic var command = ""
    dynamic var endedAt: NSDate?
    dynamic var exitCode: Int = 0
    dynamic var hasOutput = false
    dynamic var id = ""
    dynamic var isCanceled = false
    dynamic var isContinue = false
    dynamic var isFailed = false
    dynamic var isInfrastructureFail = false
    dynamic var isParallel = false
    dynamic var isTimedout = false
    dynamic var isTruncated = false
    dynamic var name = ""
    dynamic var nodeIndex: Int = 0 {
        didSet { updateId() }
    }
    dynamic var outputURLString: String?
    dynamic var runTimeMillis: Int = 0
    dynamic var source = ""
    dynamic var startedAt: NSDate?
    dynamic var rawStatus: String?
    dynamic var type = ""
    dynamic var output = ""

    required convenience init?(_ map: Map) {
        self.init()
        mapping(map)
    }

    var status: Status? {
        get {
            if let rawStatus = rawStatus {
                return Status(rawValue: rawStatus)
            }
            return nil
        }
        set(value) {
            rawStatus = value?.rawValue
        }
    }

    func mapping(map: Map) {
        isTruncated <- map["truncated"]
        nodeIndex <- map["index"]
        isParallel <- map["parallel"]
        isFailed <- map["failed"]
        isInfrastructureFail <- map["infrastructure_fail"]
        name <- map["name"]
        bashCommand <- map["bash_command"]
        rawStatus <- map["status"]
        isTimedout <- map["timedout"]
        isContinue <- map["continue"]
        type <- map["type"]
        outputURLString <- map["output_url"]
        exitCode <- map["exit_code"]
        isCanceled <- map["canceled"]
        stepNumber <- map["step"]
        runTimeMillis <- map["run_time_millis"]
        hasOutput <- map["has_output"]
        endedAt <- (map["end_time"], JSONDateTransform())
        startedAt <- (map["start_time"], JSONDateTransform())
    }

    func updateId() {
        if let stepId = self.buildStep?.id where stepId.utf8.count > 0 {
            id = "\(stepId)@\(nodeIndex)"
        }
    }

    override class func primaryKey() -> String {
        return "id"
    }

    var outputURL: NSURL? {
        get {
            if let outputURLString = outputURLString {
                return NSURL(string: outputURLString)
            }
            return nil
        }
        set(value) {
            outputURLString = value?.absoluteString
        }
    }

    var logFileName: String {
        let fn = id.md5
        let si = fn.startIndex
        let ei = si.advancedBy(2)
        return "\(fn.substringToIndex(ei))/\(fn.substringFromIndex(ei))"
    }

    var logFile: NSURL {
        return NSFileManager.defaultManager()
            .containerURLForSecurityApplicationGroupIdentifier(kCI2GoAppGroupIdentifier)!
            .URLByAppendingPathComponent("BuildLog", isDirectory: true)
            .URLByAppendingPathComponent(logFileName)
    }

    var logData: String? {
        get {
            guard NSFileManager.defaultManager().fileExistsAtPath(logFile.absoluteString) else {
                return nil
            }
            do {
                return try String(contentsOfURL: logFile, encoding: NSUTF8StringEncoding)
            } catch {
                return nil
            }
        }
        set(value) {
            let m = NSFileManager.defaultManager()
            guard let dir = logFile.URLByDeletingLastPathComponent else {
                return
            }
            if !m.fileExistsAtPath(dir.absoluteString) {
                do {
                    try m.createDirectoryAtURL(dir, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    return
                }
            }
            do {
                try value?.writeToURL(logFile, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
            }
        }
    }

    override static func ignoredProperties() -> [String] {
        return ["status", "outputURL", "logFile", "logFileName", "logData"]
    }
}

func ==(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id == rhs.id
}

func >(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id > rhs.id
}

func <(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id < rhs.id
}

func >=(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id >= rhs.id
}

func <=(lhs: BuildAction, rhs: BuildAction) -> Bool {
    return lhs.id <= rhs.id
}
