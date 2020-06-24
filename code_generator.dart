// Copyright 2020 Ashraff Hathibelagal
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import './utils.dart';
import './opcodes.dart';

class CodeGenerator {

    int fnC = 0;    // functions counter
    TypesHolder typesHolder = TypesHolder();
    FunctionsHolder functionsHolder = FunctionsHolder();
    Map<int, String> functionNames = {};
    Map<int, String> functionContents = {};
    int nImports = 0;
    int nImportedFunctions = 0;
    
    List<String> stack = [];
    
    void addFunctionName(int index, String name) {
        functionNames[index] = name;
    }
    
    void generateFunctions() {
        for(var i=0;i<functionsHolder.nFunctions;i++) {
            int typeIndex = functionsHolder.contents[i];
            var fType = typesHolder.contents[typeIndex];
            String fnName = functionNames[i];
            String header = getFunctionHeader(fType, name: fnName);
            if(i >= nImportedFunctions) {
                print(header);
                print("{ ${functionContents[i]}");
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
        fnIndex += nImportedFunctions;
        var output = functionContents[fnIndex] ?? "";        
        var fType = typesHolder.contents[functionsHolder.contents[fnIndex]];
        int pC = fType.nParameters;
        for(int i=0;i<n;i++) {
            output += Utils.toDartType(lType) + " l$pC;\n";
            pC++;
        }
        functionContents[fnIndex] = output;
    }
    
    void addCode(int fnIndex, int opcode, List parameters) {
        fnIndex += nImportedFunctions;
        print(stack);
        switch(opcode) {
            case Opcodes.i32_CONST:
            case Opcodes.i64_CONST:            
                stack.add("${parameters[0]}");
                break;
            case Opcodes.local_GET:
                stack.add("l${parameters[0]}");
                break;
            case Opcodes.local_SET:
                String value = stack.removeLast();
                addCodeToFunction(fnIndex, "l${parameters[0]} = $value;");
                break;
            case Opcodes.local_TEE:
                String value = stack.removeLast();
                addCodeToFunction(fnIndex, "l${parameters[0]} = $value;");
                stack.add("l${parameters[0]}");
                break;
            case Opcodes.ctrl_CALL:
                addFunctionCall(parameters[0], fnIndex);                
                break;
            case Opcodes.parametric_DROP:
                stack.removeLast();
                break;
            case Opcodes.i32_SUB:
            case Opcodes.i64_SUB:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 - $c2)");
                break;
            case Opcodes.i32_ADD:
            case Opcodes.i64_ADD:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 + $c2)");
                break;
            case Opcodes.i32_LT_u:
            case Opcodes.i64_LT_u:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 < $c2)");
                break;
            case Opcodes.ctrl_IF:
                String cond = stack.removeLast();
                addCodeToFunction(fnIndex, "if($cond) {");
                break;
            case Opcodes.ctrl_ELSE:
                addCodeToFunction(fnIndex, "} else {");
                break;
            case Opcodes.ctrl_END:
                addCodeToFunction(fnIndex, "}");
                break;
            case Opcodes.ctrl_RETURN:                
                addReturnFromFunction(fnIndex);
                break;
        }
    }
    
    void addFunctionCall(fnToCall, fnIndex) {
        String fnName = functionNames[fnToCall] ?? "f$fnToCall";
        int nParameters = typesHolder.contents[functionsHolder.contents[fnToCall]].nParameters;
        String input = "";
        for(int i=0;i<nParameters;i++) {
            input += stack.removeLast() + ",";
        }
        if(input.endsWith(",")) {
            input = input.substring(0, input.length-1);
        }
        stack.add("$fnName($input)");
    }
    
    void addReturnFromFunction(fnIndex) { 
        int nResults = typesHolder.contents[functionsHolder.contents[fnIndex]].nResults;
        String rValue = "";
        if(nResults == 1) {
            rValue = stack.removeLast();
        }
        addCodeToFunction(fnIndex, "return $rValue;");
    }
    
    void addCodeToFunction(int fnIndex, String code) {
        String output = functionContents[fnIndex] ?? "";
        output += code + "\n";
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
