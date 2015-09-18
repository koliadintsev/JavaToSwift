//
//  DataPacketConfiguration.swift
//  T2
//
//  Created by Marko Budal on 07/09/15.
//  Copyright (c) 2015 Andrey Kozhurin. All rights reserved.
//

import Foundation

class DataPacketConfiguration: NSXMLParserDelegate {
    
    struct DataPacketConfigurationStruct {
        static let DP_CONFIGURATION_FILE_NAME_DEFAULT = "dataPacketConfiguration.xml"
        static let DP_CONFIGURATION_FILE_PATH_DEFAULT = "."
        
        private static var myConfiguration:DataPacketConfigurationStruct!
        private static var parser: NSXMLParser
        //private static var document: Document!
        //private static var root: Element! -> AlertView
        private static var queueConfigurations:[String: String]!
        private static var queuesSet:[String]!
        private static var dataPacketList:[Int:DataPacketDetail]!
        private static var sFileName:String = "DP_CONFIGURATION_FILE_NAME_DEFAULT"
        private static var sPath:String = "DP_CONFIGURATION_FILE_PATH_DEFAULT"
        private static var sPrefix:String!
        private static var sTopicDefaultTx:String!
        private static var sTopicDefaultAckTx:String!
        private static var sQueueDefaultRx:String!
        private static var sQueueSmsTx:String!
        private static var sQueueSmsRx:String!
        //private static var mContext:Context! -> AlertView
        var queueItem:Bool = false
        var dataItem:Bool = false
        var elementString:String!
        var id:Integer!
        private static var dpDetail: DataPacketDetail!
        
    }
    
    func DataPacketConfiguration(){
        self.initObject()
    }
    
    func initObject() {
        let url: NSURL! = NSBundle.mainBundle().URLForResource(DP_CONFIGURATION_FILE_NAME_DEFAULT, withExtension: "xml")
        var parser = NSXMLParser(contentsOfURL: url)
        
        parser.delegate = self
        var success:Bool = parser.parse()
        
        if success {
            
            //TODO if success
        } else {
            println("parse fail")
            //TODO change to DataPacketException class
        }
        
        
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!)
    {
        elementString = elementName
        if (elementName as NSString).isEqualToString("QueueDefault")
        {
            queueItem = true
            
        } else if (elementName as NSString).isEqualToString("DataPacket") {
            dataItem = true
            id = attributeDict["id"]
            
            dpDetail  = DataPacketDetail.alloc()
            dpDetail.msQueueName = attributeDict["queue"]
            dpDetail.msQueueAckClassName = attributeDict["queueAckClass"]
            dpDetail.bPersistent = attributeDict["persistent"] as? Bool
            dpDetail.compressed = attributeDict["compressed"]
            
        }
    }
    
    
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        
        if(queueItem){
            if elementString.isEqualToString("prefix"){
                sPrefix.append(string)
            } else if elementString.isEqualToString("tx") {
                sTopicDefaultTx.append(string)
            } else if elementString.isEqualToString("txAck") {
                sTopicDefaultAckTx.append(string)
            } else if elementString.isEqualToString("rx") {
                sQueueDefaultRx.append(string)
            } else if elementString.isEqualToString("smsTx") {
                sQueueSmsTx.append(string)
            } else if elementString.isEqualToString("smsRx") {
                sQueueSmsRx.append(string)
            }
        }
        if(dataItem)
        {
            if (sQueueDefaultRx == nil) {
                DataPacketException("Queue default Rx has not been defined")
            }
            if (dpDetail.msQueueName != nil) {
                if (dpDetail.msQueueAckClassName != nil) {
                    var setQueueName : Set<String> = nil
                    if ((setQueueName = queueConfigurations["dpDetail.msQueueAckClassName"]) == nil){
                        setQueueName = Set<String>.alloc()
                    }
                    if (sPrefix != nil) {
                        dpDetail.msQueueName = sPrefix + "." + dpDetail.msQueueName
                    } else {
                        dpDetail.msQueueName = dpDetail.msQueueName //???
                    }
                    setQueueName.insert(dpDetail.msQueueName)
                    queueConfigurations.updateValue(dpDetail.msQueueAckClassName,setQueueName)
                }
            } else {
                if (sPrefix != nil) {
                    dpDetail.msQueueName = sPrefix + "." + sQueueDefaultRx
                }else {
                    dpDetail.msQueueName = sQueueDefaultRx
                }
            }
            queuesSet.append(dpDetail.msQueueName)
            //Stop here
            
            
            if elementString.isEqualToString("class"){
                dpDetail.msClassName.append(string)
            } else if elementString.isEqualToString("tx") {
                
            }
        }
    }
    /*
    var operation : Element = item.getChild("rx");
    if ( operation != nil ) {
    type = operation.getChild("get");
    if ( type != nil ) {
    dpDetail.miRxGet = Integer.parseInt( type.getAttributeValue("size") );
    dpDetail.bRxGetDyn = Boolean.parseBoolean( type.getAttributeValue("dyn") );
    }
    
    type = operation.getChild("set");
    if ( type != nil ) {
    dpDetail.miRxSet = Integer.parseInt( type.getAttributeValue("size") );
    dpDetail.bRxSetDyn = Boolean.parseBoolean( type.getAttributeValue("dyn") );
    }
    
    type = operation.getChild("status");
    if ( type != nil ) {
    dpDetail.miRxStatus = Integer.parseInt( type.getAttributeValue("size") );
    dpDetail.bRxStatusDyn = Boolean.parseBoolean( type.getAttributeValue("dyn") );
    }
    }
    
    operation = item.getChild("tx");
    if ( operation != nil ) {
    dpDetail.bTxChk = Boolean.parseBoolean( operation.getAttributeValue("chk") );
    type = operation.getChild("get");
    
    if ( type != nil ) {
    dpDetail.miTxGet = Integer.parseInt( type.getAttributeValue("size") );
    dpDetail.bTxGetDyn = Boolean.parseBoolean( type.getAttributeValue("dyn") );
    }
    
    type = operation.getChild("set");
    if ( type != nil ) {
    dpDetail.miTxSet = Integer.parseInt( type.getAttributeValue("size") );
    dpDetail.bTxSetDyn = Boolean.parseBoolean( type.getAttributeValue("dyn") );
    }
    
    type = operation.getChild("status");
    if ( type != nil ) {
    dpDetail.miTxStatus = Integer.parseInt( type.getAttributeValue("size") );
    dpDetail.bTxStatusDyn = Boolean.parseBoolean( type.getAttributeValue("dyn") );
    }
    }
    dataPacketList.put(id, dpDetail);
    }
    }
    }
    */
    /**
    * Factory method
    * @return DataPacketConfiguration
    */
    
    func getDataPacketConfiguration() -> DataPacketConfiguration {
        if DataPacketConfigurationStruct.myConfiguration == nil {
            DataPacketConfigurationStruct.myConfiguration = self.DataPacketConfiguration()
        }
        
        return DataPacketConfigurationStruct.myConfiguration
    }
    
    
    /**
    * Gets the detailed configuration for the ID required
    * @param id ID required
    * @return DataPacketDetail
    */
    /*
    func getIdDetail(id: Int) -> DataPacketDetail {
    var dataPackegeList = DataPacketConfigurationStruct.dataPacketList.values
    return DataPacketConfigurationStruct.dataPacketList.values;
    }
    
    /**
    * Gets the Set of different Ack process to instantiate
    * @return Set of Ack process needed
    */
    func getAckProcessSet() -> [String] {
    return DataPacketConfigurationStruct.queueConfigurations.key;
    }
    
    func getAckProcessConf ( key : String ) -> Set<String> {
    return DataPacketConfigurationStruct.queueConfigurations.get(key);
    }
    
    /**
    * Gets the list of different queues where to send DataPacket received
    */
    func getQueues ( ) -> [] {
    return DataPacketConfigurationStruct.queuesSet.toArray()
    }
    */
    
    /**
    * Gets the file name of the datapacket configuration file loaded or to load
    * @return String
    * @see DataPacketConfiguration#setFileName(String)
    */
    func getFileName () -> String {
        return DataPacketConfigurationStruct.sFileName
    }
    
    /**
    * Sets the file name of the datapacket configuration file to load, has to be used before the factory method
    * @see DataPacketConfiguration#getFileName()
    * @see DataPacketConfiguration#getDataPacketConfiguration()
    */
    func setFileName (lsFileName: String?) {
        if var name = lsFileName as String? {
            DataPacketConfigurationStruct.sFileName = name
        }
        DataPacketConfigurationStruct.sFileName = "DP_CONFIGURATION_FILE_NAME_DEFAULT"
    }
    
    /**
    * Gets the path of the datapacket configuration file loaded or to load
    * @return String
    * @see DataPacketConfiguration#setPath(String)
    */
    func getPath() -> String {
        return DataPacketConfigurationStruct.sPath;
    }
    
    /**
    * Sets the path of the datapacket configuration file to load, has to be used before the factory method
    * @see DataPacketConfiguration#getPath()
    * @see DataPacketConfiguration#getDataPacketConfiguration()
    */
    func setPath(lsConfigurationPath: String) {
        DataPacketConfigurationStruct.sPath = lsConfigurationPath;
    }
    
    /**
    * Gets the Queue Prefix
    * @return String
    */
    func getQueuePrefix () -> String {
        return DataPacketConfigurationStruct.sPrefix;
    }
    
    /**
    * Gets the Topic Default Tx
    * @return String
    * @throws DataPacketException
    */
    func getTopicDefaultTx () -> String? {
        if var sTopicDefaultTx = DataPacketConfigurationStruct.sTopicDefaultTx {
            if var sPrefix = DataPacketConfigurationStruct.sPrefix {
                return "\(sPrefix).\(sTopicDefaultTx)"
            }
            return sTopicDefaultTx
        }
        println("Error: getTopicDefaultTx")
        
        return nil
    }
    
    /**
    * Gets the Topic Default Ack Tx
    * @return String
    * @throws DataPacketException
    */
    func getTopicDefaultAckTx () -> String? {
        if var sTopicDefaultAckTx = DataPacketConfigurationStruct.sTopicDefaultAckTx {
            if var sPrefix = DataPacketConfigurationStruct.sPrefix {
                return "\(sPrefix).\(sTopicDefaultAckTx)"
            }
            return sTopicDefaultAckTx
        }
        println("Error: getTopicDefaultAckTx")
        return nil
    }
    
    /**
    * Gets the Queue Default Rx
    * @return String
    * @throws DataPacketException
    */
    func getQueueDefaultRx () -> String? {
        if var sQueueDefaultRx = DataPacketConfigurationStruct.sQueueDefaultRx {
            if var sPrefix = DataPacketConfigurationStruct.sPrefix {
                return "\(sPrefix).\(sQueueDefaultRx)"
            }
            return sQueueDefaultRx
        }
        println("Error: getQueueDefaultRx")
        return nil
    }
    
    /**
    * Gets the Queue SMS Tx
    * @return String       sQueueSmsTx
    * @throws DataPacketException
    */
    func getQueueSmsTx () -> String? {
        if var sQueueSmsTx = DataPacketConfigurationStruct.sQueueSmsTx {
            if var sPrefix = DataPacketConfigurationStruct.sPrefix {
                return "\(sPrefix).\(sQueueSmsTx)"
            }
            return sQueueSmsTx
        }
        println("Error: getQueueSmsTx")
        return nil
    }
    
    
    /**
    * Gets the Queue SMS Rx
    * @return String
    * @throws DataPacketException
    */
    func getQueueSmsRx () -> String {
        if var sQueueSmsRx = DataPacketConfigurationStruct.sQueueSmsRx {
            if var sPrefix = DataPacketConfigurationStruct.sPrefix {
                return "\(sPrefix).\(sQueueSmsRx)"
            }
            return sQueueSmsRx
        }
        println("Error: getQueueSmsRx")
    }
    
    
    
}