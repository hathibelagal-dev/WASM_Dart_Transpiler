import './utils.dart';

class CodeGenerator {

    int fnC = 0;
    TypesHolder typesHolder = TypesHolder();
    FunctionsHolder functionsHolder = FunctionsHolder();
    Map<int, String> functionNames = {};
    int nImports = 0;
    
    void addFunctionName(int index, String name) {
        functionNames[index] = name;
    }
    
    void generateFunctions() {
        for(var i=0;i<functionsHolder.nFunctions;i++) {
            int typeIndex = functionsHolder.contents[i];
            var resultType = typesHolder.contents[typeIndex];
            String fnName = functionNames[i];
            String header = getFunctionHeader(resultType, name: fnName);
            if(i >= nImports) {
                print(header);
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
        output += (name == null ? "f_$fnC(" : "$name(");
        fnC++;
        int pC = 0;
        for(var i=0;i<ft.nParameters;i++) {
            output += Utils.toDartType(ft.parameters[i]) + " p_$pC, ";
            pC++;
        }
        if(pC > 0) {
            output = output.substring(0, output.length - 2);
        }
        output += ")";
        return output;
    }
}

class FunctionType {
    List<int> parameters;
    List<int> results;    
    int nParameters;
    int nResults;
    
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
