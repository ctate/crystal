import Foundation

struct FunctionDetail {
    var name: String
    var description: String
    var parameters: ParameterDetail
}

struct ParameterDetail {
    var type: String
    var properties: [String: PropertyDetail]
    var required: [String]
}

struct PropertyDetail {
    var type: String
    var description: String
}

// Parsing function to transform input to structured data
func parseFunctions(from array: [[String: Any]]) -> [FunctionDetail] {
    var outputFunctions: [FunctionDetail] = []
    
    for item in array {
        if let type = item["type"] as? String, type == "function",
           let functionDict = item["function"] as? [String: Any] {
            if let functionDetail = parseFunction(from: functionDict) {
                outputFunctions.append(functionDetail)
            }
        }
    }
    
    return outputFunctions
}

func parseFunction(from dict: [String: Any]) -> FunctionDetail? {
    guard let name = dict["name"] as? String,
          let description = dict["description"] as? String,
          let parametersDict = dict["parameters"] as? [String: Any] else {
        return nil
    }
    
    if let parameters = parseParameters(from: parametersDict) {
        return FunctionDetail(name: name, description: description, parameters: parameters)
    }
    
    return nil
}

func parseParameters(from dict: [String: Any]) -> ParameterDetail? {
    guard let type = dict["type"] as? String,
          let propertiesDict = dict["properties"] as? [String: [String: Any]],
          let required = dict["required"] as? [String] else {
        return nil
    }
    
    let properties = propertiesDict.mapValues { propDict -> PropertyDetail in
        let type = propDict["type"] as? String ?? "unknown"
        let description = propDict["description"] as? String ?? ""
        return PropertyDetail(type: type, description: description)
    }
    
    return ParameterDetail(type: type, properties: properties, required: required)
}

// Function to encode structured data back to [[String: Any]]
func encodeFunctions(functions: [FunctionDetail]) -> [[String: Any]] {
    return functions.map { function in
        [
            "name": function.name,
            "description": function.description,
            "input_schema": encodeParameters(parameters: function.parameters)
        ]
    }
}

func encodeParameters(parameters: ParameterDetail) -> [String: Any] {
    let propertiesDict = parameters.properties.mapValues { property in
        [
            "type": property.type,
            "description": property.description
        ]
    }
    
    return [
        "type": parameters.type,
        "properties": propertiesDict,
        "required": parameters.required
    ]
}
