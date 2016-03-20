//
//  CheckpointFunc.swift
//  Run
//
//  Created by Jason Ho on 17/3/2016.
//  Copyright © 2016 Arefly. All rights reserved.
//

import UIKit
import Foundation
import Async
import Alamofire
import CocoaLumberjack
import SwiftyJSON

class CheckpointFunc {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let checkpointsDataKey = "checkpointsData"
    let pathsDataKey = "pathsData"
    
    
    func saveCheckpoints(checkpoints: [Checkpoint]) {
        // 儲存checkpoints數據（參見：http://stackoverflow.com/a/26233274/2603230）
        let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(checkpoints)
        self.defaults.setObject(arrayOfObjectsData, forKey: checkpointsDataKey)
        
        DDLogDebug("已儲存checkpoints數據至defaults")
    }
    
    func getCheckpoints() -> [Checkpoint] {
        if let arrayOfObjectsUnarchivedData = defaults.dataForKey(checkpointsDataKey) {
            if let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as? [Checkpoint] {
                DDLogDebug("已從defaults獲取checkpoints數據")
                DDLogVerbose("checkpoints內容：\(arrayOfObjectsUnarchived)")
                
                return arrayOfObjectsUnarchived
            }
        }
        DDLogWarn("從defaults獲取checkpoints數據失敗、將返回空值")
        DDLogWarn("可能原因：第一次開啟App、checkpoints數據未設定")
        return []
    }
    
    
    func savePaths(paths: [Path]) {
        // 儲存paths數據（參見：http://stackoverflow.com/a/26233274/2603230）
        let arrayOfObjectsData = NSKeyedArchiver.archivedDataWithRootObject(paths)
        self.defaults.setObject(arrayOfObjectsData, forKey: pathsDataKey)
        
        DDLogDebug("已儲存paths數據至defaults")
    }
    
    func getPaths() -> [Path] {
        if let arrayOfObjectsUnarchivedData = defaults.dataForKey(pathsDataKey) {
            if let arrayOfObjectsUnarchived = NSKeyedUnarchiver.unarchiveObjectWithData(arrayOfObjectsUnarchivedData) as? [Path] {
                DDLogDebug("已從defaults獲取paths數據")
                DDLogVerbose("paths內容：\(arrayOfObjectsUnarchived)")
                
                return arrayOfObjectsUnarchived
            }
        }
        DDLogWarn("從defaults獲取paths數據失敗、將返回空值")
        DDLogWarn("可能原因：第一次開啟App、checkpoints數據未設定")
        return []
    }
    
    
    
    func loadCheckpointsDataFromServer(completion: () -> Void) {
        Alamofire.request(.GET, BasicConfig.CheckpointDataGetURL)
            .response { request, response, data, error in
                if let error = error {
                    DDLogError("checkpoints伺服器數據獲取錯誤：\(error)")
                } else {
                    let json = JSON(data: data!)
                    var checkpointsData = [Checkpoint]()
                    
                    for (index, subJson): (String, JSON) in json["checkpoint"] {
                        let checkpointToBeAppend = Checkpoint(json: subJson)
                        checkpointsData.append(checkpointToBeAppend)
                        if(Int(index) == 0){
                            self.defaults.setDouble(checkpointToBeAppend.coordinate.latitude, forKey: "initLatitude")
                            self.defaults.setDouble(checkpointToBeAppend.coordinate.longitude, forKey: "initLongitude")
                            DDLogVerbose("已從通過第一個checkpoint設定init數據")
                        }
                    }
                    DDLogVerbose("已從伺服器獲取checkpointsData：\(checkpointsData)")
                    
                    CheckpointFunc().saveCheckpoints(checkpointsData)
                    
                    
                    
                    var pathsData = [Path]()
                    for (_, subJson): (String, JSON) in json["path"] {
                        let pathToBeAppend = Path(json: subJson)
                        pathsData.append(pathToBeAppend)
                    }
                    CheckpointFunc().savePaths(pathsData)
                    
                    
                    
                    completion()
                }
        }
    }
    
}