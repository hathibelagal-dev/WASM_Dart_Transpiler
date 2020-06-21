import './utils.dart';

class CodeGenerator {

    int fnC = 0;
    TypesHolder typesHolder = TypesHolder();
    FunctionsHolder functionsHolder = FunctionsHolder();
    Map<int, String> functionNames = {};
    Map<int, String> functionContents = {};
    int nImports = 0;
    
    void addFunctionName(int index, String name) {
        functionNames[index] = name;
    }
    
    void generateFunctions() {
        for(var i=0;i<functionsHolder.nFunctions;i++) {
            int typeIndex = functionsHolder.contents[i];
            var fType = typesHolder.contents[typeIndex];
            String fnName = functionNames[i];
            String header = getFunctionHeader(fType, name: fnName);
            if(i >= nImports) {
                print(header);
                print("{ ${functionContents[i]} }");
            }
        }
    }
    
    String getFunctionHeader(FunctionType ft, {String name}) {
        String output = "";
        if(ft.nResults == 1) {
            output = Utils.toDartType(ft.results[0]) + " ";
        } else {
            output = "void ";
        }
        output += name == null ? "f$fnC(" : "$name(";
        fnC++;
        int pC = 0;
        for(var i=0;i<ft.nParameters;i++) {
            output += Utils.toDartType(ft.parameters[i]) + " l$pC, ";
            pC++;
        }
        if(pC > 0) {
            output = output.substring(0, output.length - 2);
        }
        output += ")";
        return output;
    }
    
    void addLocalsOfType(int fnIndex, int n, int lType) {
        fnIndex += nImports;
        var output = functionContents[fnIndex] ?? "";        
        var fType = typesHolder.contents[functionsHolder.contents[fnIndex]];
        int pC = fType.nParameters;
        for(int i=0;i<n;i++) {
            output += Utils.toDartType(lType) + " l$pC;\n";
            pC++;
        }
        functionContents[fnIndex] = output;
    }
}

class FunctionType {
    List<int> parameters;
    List<int> results;    
    int nParameters = 0;
    int nResults = 0;
    
    FunctionType({this.parameters, this.nParameters, this.results, this.nResults});
}

class TypesHolder {
    int nTypes = 0;
    Map<int, FunctionType> contents = {};
    
    void add(FunctionType ft) {
        contents[nTypes] = ft;
        nTypes++;
    }
}

class FunctionsHolder {
    int nFunctions = 0;
    Map<int, int> contents = {};
    
    void add(int typeIndex) {
        contents[nFunctions] = typeIndex;
        nFunctions++;
    }
}
