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

import 'dart:io';
import 'dart:typed_data';

import './utils.dart';
import './opcodes.dart';

class CodeGenerator {

    int fnC = 0;    // functions counter
    TypesHolder typesHolder = TypesHolder();
    FunctionsHolder functionsHolder = FunctionsHolder();
    GlobalsHolder globalsHolder = GlobalsHolder();
    Map<int, String> functionNames = {};
    Map<int, String> functionContents = {};
    Map<int, bool> addedReturn = {};
    
    int nImports = 0;
    int nImportedFunctions = 0;
    
    List<String> stack = [];
    List<String> bStack = [];
    int bCount = 0;    
    
    int depth = 0;
    
    void addFunctionName(String name, {int index}) {
        int i = index ?? functionsHolder.nFunctions;
        functionNames[i] = name;
    }
    
    void addGlobalName(String name, int index) {
        globalsHolder.names[index] = name;
    }
    
    void generateGlobals() {
        for(var i=0;i<globalsHolder.nGlobals;i++) {
            String gName = globalsHolder.names[i] ?? "g$i";
            int mutability = globalsHolder.types[i].mutability;
            int vType = globalsHolder.types[i].vType;
            String output = mutability == 0 ? "final " : "";
            output += Utils.toDartType(vType) + " $gName = () { ";
            output += globalsHolder.contents[i];
            output += "();";
            print(output);
        }
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
    
    void addGlobal(int gIndex, int opcode, List parameters) {
        addCode(gIndex, opcode, parameters, global: true);
    }
    
    String getGlobalName(int index) {
        return globalsHolder.names[index] ?? "g$index";
    }
    
    void addCode(int fnIndex, int opcode, List parameters, {bool global = false}) {
        if(!global) {
            fnIndex += nImportedFunctions;
        }
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
                addCodeToFunction(fnIndex, "l${parameters[0]} = $value;", global);
                break;
            case Opcodes.global_GET:
                stack.add("${getGlobalName(parameters[0])}");
                break;
            case Opcodes.global_SET:
                String value = stack.removeLast();
                addCodeToFunction(fnIndex, "${getGlobalName(parameters[0])} = $value;", global);
                break;
            case Opcodes.local_TEE:
                String value = stack.removeLast();
                addCodeToFunction(fnIndex, "l${parameters[0]} = $value;", global);
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
            case Opcodes.i32_MUL:
            case Opcodes.i64_MUL:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 * $c2)");
                break;
            case Opcodes.i32_DIV_u:
            case Opcodes.i32_DIV_s:
            case Opcodes.i64_DIV_u:
            case Opcodes.i64_DIV_s:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 / $c2)");
                break;
            case Opcodes.i32_SHL:
            case Opcodes.i64_SHL:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 << $c2)");
                break;
            case Opcodes.i32_SHR_u:
            case Opcodes.i64_SHR_u:
            case Opcodes.i32_SHR_s:
            case Opcodes.i64_SHR_s:            
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 >> $c2)");
                break;
            case Opcodes.i32_AND:
            case Opcodes.i64_AND:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 & $c2)");
                break;
            case Opcodes.i32_OR:
            case Opcodes.i64_OR:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 | $c2)");
                break;
            case Opcodes.i32_XOR:
            case Opcodes.i64_XOR:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 ^ $c2)");
                break;
            case Opcodes.i32_LT_u:
            case Opcodes.i32_LT_s:            
            case Opcodes.i64_LT_u:
            case Opcodes.i64_LT_s:            
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 < $c2)");
                break;
            case Opcodes.i32_LE_u:
            case Opcodes.i32_LE_s:            
            case Opcodes.i64_LE_u:
            case Opcodes.i64_LE_s:            
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 <= $c2)");
                break;
            case Opcodes.i32_GE_u:
            case Opcodes.i32_GE_s:            
            case Opcodes.i64_GE_u:
            case Opcodes.i64_GE_s:            
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 >= $c2)");
                break;
            case Opcodes.i32_GT_u:
            case Opcodes.i32_GT_s:            
            case Opcodes.i64_GT_u:
            case Opcodes.i64_GT_s:            
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 > $c2)");
                break;
            case Opcodes.i32_NE:
            case Opcodes.i64_NE:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 != $c2)");
                break;
            case Opcodes.i32_EQ:
            case Opcodes.i64_EQ:
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c1 == $c2)");
                break;
            case Opcodes.i32_EQZ:
            case Opcodes.i64_EQZ:
                String c1 = stack.removeLast();
                stack.add("($c1 == 0)");
                break;                
            case Opcodes.ctrl_IF:
                bStack.add("IF");
                String cond = stack.removeLast();
                addCodeToFunction(fnIndex, "if($cond) {", global);
                break;
            case Opcodes.ctrl_ELSE:
                addCodeToFunction(fnIndex, "} else {", global);
                break;            
            case Opcodes.ctrl_END:
                String bType = bStack.removeLast();
                if(bType.startsWith("BLOCK") || bType.startsWith("LOOP")) {
                    addCodeToFunction(fnIndex, "break;", global);
                } else if(bType.startsWith("FUNCTION")) {
                    addReturnFromFunction(fnIndex, global);
                }
                addCodeToFunction(fnIndex, "}", global);
                break;
            case Opcodes.ctrl_RETURN:
                addReturnFromFunction(fnIndex, global);
                break;
            case Opcodes.i64_EXTEND_i32_u:
            case Opcodes.i64_EXTEND_i32_s:
            case Opcodes.i32_WRAP_i64:                
                break;
            case Opcodes.parametric_SELECT:
                String c = stack.removeLast();
                String c2 = stack.removeLast();
                String c1 = stack.removeLast();
                stack.add("($c == true) ? $c1 : $c2");
                break;
            case Opcodes.ctrl_BLOCK:
                String bl = addBlockToStack();
                addCodeToFunction(fnIndex, "$bl: while(true) {", global);
                break;
            case Opcodes.ctrl_LOOP:
                String bl = addBlockToStack(isLoop: true);
                addCodeToFunction(fnIndex, "$bl: while(true) {", global);
                break;
            case Opcodes.ctrl_BR_IF:
                String cond = stack.removeLast();
                String label = getLabel(parameters[0]);
                addCodeToFunction(fnIndex, "if($cond) $label", global);
                break;
            case Opcodes.ctrl_BR:
                String label = getLabel(parameters[0]);
                addCodeToFunction(fnIndex, "$label", global);
                break;
            case Opcodes.i32_LOAD:
            case Opcodes.i32_LOAD8_s:
            case Opcodes.i32_LOAD8_u:
            case Opcodes.i32_LOAD16_s:
            case Opcodes.i32_LOAD16_u:
            case Opcodes.i64_LOAD:
            case Opcodes.i64_LOAD8_s:
            case Opcodes.i64_LOAD8_u:
            case Opcodes.i64_LOAD16_s:
            case Opcodes.i64_LOAD16_u:
            case Opcodes.i64_LOAD32_s:
            case Opcodes.i64_LOAD32_u:
                loadFromMemory(parameters[0], opcode);
                break;
            case Opcodes.i32_STORE:
            case Opcodes.i32_STORE8:
            case Opcodes.i32_STORE16:
            case Opcodes.i64_STORE:
            case Opcodes.i64_STORE8:
            case Opcodes.i64_STORE16:
            case Opcodes.i64_STORE32:
                storeToMemory(fnIndex, parameters[0], opcode, global);
                break;
            default:
                print(stack);
                print("generator not found: 0x" + Utils.get0x(opcode));
                exit(1);
        }
    }
    
    void loadFromMemory(List<int> mem, int opcode) {
        String index = stack.removeLast();
        String offset = "$index + ${mem[1]}";
        String method = "";
        switch(opcode) {
            case Opcodes.i32_LOAD:
                method = "getInt32";
                break;
            case Opcodes.i32_LOAD8_s:
                method = "getInt8";
                break;
            case Opcodes.i32_LOAD8_u:
                method = "getUint8";
                break;            
            case Opcodes.i32_LOAD16_s:
                method = "getInt16";
                break;            
            case Opcodes.i32_LOAD16_u:
                method = "getUint16";
                break;            
            case Opcodes.i64_LOAD:
                method = "getInt64";
                break;            
            case Opcodes.i64_LOAD8_s:
                method = "getInt8";
                break;            
            case Opcodes.i64_LOAD8_u:
                method = "getUint8";
                break;            
            case Opcodes.i64_LOAD16_s:
                method = "getInt16";
                break;                     
            case Opcodes.i64_LOAD16_u:
                method = "getUint16";
                break;              
            case Opcodes.i64_LOAD32_s:
                method = "getInt32";
                break;            
            case Opcodes.i64_LOAD32_u:                
                method = "getUint32";
                break;            
        }
        stack.add("memory.${method}($offset)");
    }
    
    void storeToMemory(int fnIndex, List<int> mem, int opcode, bool global) {
        String contents = stack.removeLast();
        String index = stack.removeLast();
        String offset = "$index + ${mem[1]}";
        
        String method = "";
        switch(opcode) {
            case Opcodes.i32_STORE8:
            case Opcodes.i64_STORE8:
                method = "setInt8";            
                break;
            case Opcodes.i32_STORE16:
            case Opcodes.i64_STORE16:
                method = "setInt16";
                break;
            case Opcodes.i32_STORE:
            case Opcodes.i64_STORE32:            
                method = "setInt32";
                break;                    
            case Opcodes.i64_STORE:
                method = "setInt64";
                break;            
        }
        
        addCodeToFunction(fnIndex, "memory.${method}($offset, $contents);", global);    
    }
    
    String getLabel(int x) {
        String label = "";
        int i=0;
        while(i<x) {
            String cur = bStack[bStack.length - i - 1];
            if(cur.startsWith("BLOCK") || cur.startsWith("LOOP")) {
                i++;
            }
        }
        label = bStack[bStack.length - i - 1];
        if(bStack.last.startsWith("BLOCK"))
            return "break $label;";
        if(bStack.last.startsWith("LOOP"))
            return "continue $label;";
        return "ERROR";        
    }
    
    void addFunctionToStack() {
        bStack.add("FUNCTION");
    }
    
    String addBlockToStack({bool isLoop=false}) {
        bCount++;
        String toAdd = "";
        if(!isLoop)
            toAdd = "BLOCK_$bCount";
        else
            toAdd = "LOOP_$bCount";
        bStack.add(toAdd);
        return toAdd;
    }
    
    int getBStackLength() {
        return bStack.length - 1;
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
    
    void addReturnFromFunction(fnIndex, global) { 
        int nResults = global ? 1 : typesHolder.contents[functionsHolder.contents[fnIndex]].nResults;
        if(stack.length < nResults) return;
        String rValue = "";
        if(nResults == 1) {
            rValue = stack.removeLast();
        }
        addCodeToFunction(fnIndex, "return $rValue;", global);
    }
    
    void addCodeToFunction(int fnIndex, String code, bool global) {
        var contents = {};
        if(global) {
            contents = globalsHolder.contents;
        } else {
            contents = functionContents;
        }
        
        String output = contents[fnIndex] ?? "";
        output += code + "\n";
        contents[fnIndex] = output;
    }
    
    void addData(List<DataElement> de) {
        String output = "import 'dart:typed_data';\n";
        output += "ByteData memory;\n";
        
        output += "void _initializeDATA() {\n";
        output += "Uint8List _m = Uint8List(65535 * 2);\n";
        output += "List<int> d = [];\n";        
        for(DataElement e in de) {
            int offset = e.offset;
            String bytes = "d = [";
            for(var b in e.bytes) {
                bytes += "$b,";
            }
            if(bytes.endsWith(","))
                bytes = bytes.substring(0, bytes.length - 1);
            bytes += "];\n";
            bytes += "_m.setAll($offset, d);\n";
            output += bytes;
        }
        output += "memory = _m.buffer.asByteData();\n";        
        output += "}";
        print(output);
    }
}

class FunctionType {
    List<int> parameters;
    List<int> results;    
    int nParameters = 0;
    int nResults = 0;
    
    FunctionType({this.parameters, this.nParameters, this.results, this.nResults});
}

class GlobalType {
    int mutability;
    int vType;
    
    GlobalType(this.mutability, this.vType);
}

class TypesHolder {
    int nTypes = 0;
    Map<int, FunctionType> contents = {};
    
    void add(FunctionType ft) {
        contents[nTypes] = ft;
        nTypes++;
    }
}

class GlobalsHolder {
    int nGlobals = 0;
    Map<int, String> contents = {};
    Map<int, GlobalType> types = {};
    Map<int, String> names = {};
}

class FunctionsHolder {
    int nFunctions = 0;
    Map<int, int> contents = {};
    
    void add(int typeIndex) {
        contents[nFunctions] = typeIndex;
        nFunctions++;
    }
}

class DataElement {
    int offset;
    Uint8List bytes;
    DataElement(this.offset, this.bytes);
}
