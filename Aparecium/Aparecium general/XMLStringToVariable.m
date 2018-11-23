function xmlStruct = XMLStringToVariable(variable)
xmlStruct = tinyxml2_wrap('parse', variable);