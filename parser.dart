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
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import './wasm_reader.dart';
import './opcodes.dart';
import './code_generator.dart';
import './utils.dart';

class Parser {
    String filename;
    WASMReader reader;
    
    int currentSection = -1;
    int currentFn = -1;
    
    CodeGenerator cg = CodeGenerator();
    
    Parser(this.filename);
    
    void initialize() async {
        Uint8List fileContents = await File(filename).readAsBytes(); 
        var data = ByteData.view(fileContents.buffer);
        reader = WASMReader(data: data, fileLength: data.lengthInBytes);
    }
    
    bool checkMagic() {
        if(reader.readByte() == 0x00 && reader.readByte() == 0x61 && 
           reader.readByte() == 0x73 && reader.readByte() == 0x6D) {
            return true;
        }
        return false;
    }
    
    bool checkVersion() {
        if(reader.readByte() == 0x01 && reader.readByte() == 0x0 && 
           reader.readByte() == 0x0 && reader.readByte() == 0x0) {
            return true;
        }
        return false;
    }
    
    void readFunctionType() {
        int prefix = reader.readByte();
        if(prefix != 0x60) {
            _show("Not a function type");
            return;
        }
        
        int nParameters = reader.readU32();
        List<int> parameters = [];
        for(int i=0;i<nParameters;i++) {
            int parameter = reader.readByte();
            parameters.add(parameter);
            _show("Parameter: " + Utils.getValueTypeName(parameter));
        }
        
        int nResults = reader.readU32();
        List<int> results = [];
        for(int i=0;i<nResults;i++) {
            int result = reader.readByte();
            results.add(result);
            _show("Function return type: " + Utils.getValueTypeName(result));
        }
        
        cg.typesHolder.add(
            FunctionType(
                nParameters: nParameters,
                nResults: nResults,
                parameters: parameters,
                results: results
            )
        );
    }
    
    void readMemArg() {
        int align = reader.readU32();
        int offset = reader.readU32();
        _show("Read memory ($align, $offset)");
    }
    
    void readTypeSection(int size) {
        int originalOffset = reader.offset;
        int nFunctions = reader.readU32();
        for(int i=0;i<nFunctions;i++) {
            readFunctionType();
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the type section");
        }
    }
    
    void readLimit() {
        int maxPresent = reader.readByte();
        int minValue = 0;
        int maxValue = 999999999;
        if(maxPresent == 0x0) {
            minValue = reader.readU32();
        } else {
            minValue = reader.readU32();
            maxValue = reader.readU32();
        }
        _show("Read limit starting: $minValue to $maxValue");
    }
    
    void readTableType() {
        int elemType = reader.readByte();
        if(elemType != 0x70) {
            _show("Couldn't understand table.");
            return;
        }
        readLimit();
    }
    
    void readTableSection(int size) {
        int originalOffset = reader.offset;
        int nTables = reader.readU32();
        for(int i=0;i<nTables;i++) {
            readTableType();
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the table section");
        }
    }
    
    void readImportSection(int size) {
        int originalOffset = reader.offset;
        int nImports = reader.readU32();
        for(int i=0;i<nImports;i++) {
            String mod = readName();
            String nm = readName();
            _show("$mod : $nm");
            int descb1 = reader.readByte();
            if(descb1 == 0x00) {
                _show("Function");
                int typeIndex = reader.readU32();
                cg.addFunctionName("$mod.$nm");
                cg.functionsHolder.add(typeIndex);
                cg.nImportedFunctions += 1;
            } else if(descb1 == 0x01) {
                _show("Table");
                readTableType();
            }
        }
        cg.nImports = nImports;
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the import section");
        }
    }
    
    void readFunctionSection(int size) {
        int originalOffset = reader.offset;
        int nTypeIndices = reader.readU32();
        for(int i=0;i<nTypeIndices;i++) {
            int typeIndex = reader.readU32();
            cg.functionsHolder.add(typeIndex);
            _show("Type index: " + Utils.get0x(typeIndex));
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the function section");
        }
    }
    
    String readName() {
        int n = reader.readU32();
        List<int> output = [];
        for(int i=0;i<n;i++) {
            output.add(reader.readByte());
        }
        return utf8.decode(output);
    }
    
    void readExportSection(int size) {
        int originalOffset = reader.offset;
        int nExports = reader.readU32();
        for(int i=0;i<nExports;i++) {
            String name = readName();
            int desc = reader.readByte();
            int index = reader.readU32();
            if(desc == 0x00) {
                _show("$name is $index");
                cg.addFunctionName(name, index: index);
            }
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the export section");
        }
    }
    
    void handleBlock() {
        int output = reader.readByte();
        if(output == 0x40) {
            _show("Empty type block");
        }
        else if(output >= 0x7C && output <= 0x7F) {
            _show("Value type block");
        }
        else {
            reader.offset -= 1;
            int n = reader.readSigned(33);
            _show("Read a signed 33 bit value: $n");
        }
        readExpr();
    }
    
    void processOpCode(int opcode) {
        _show("Processing opcode: 0x" + Utils.get0x(opcode));
        
        switch(opcode) {
            case Opcodes.i32_CONST:
                int n = reader.readS32();
                addCode(opcode, [n]);
                break;
                
            case Opcodes.i64_CONST:
                int n = reader.readS64();
                addCode(opcode, [n]);
                break;
                
            case Opcodes.i32_SUB:
            case Opcodes.i32_ADD:
            case Opcodes.i32_MUL:
            case Opcodes.i32_DIV_u:
            case Opcodes.i32_AND:            
            case Opcodes.i32_OR:
            case Opcodes.i32_XOR:
            case Opcodes.i32_SHL:
            case Opcodes.i32_SHR_s:
            case Opcodes.i32_SHR_u:
            case Opcodes.i32_LT_u:
            case Opcodes.i32_LT_s:
            case Opcodes.i32_LE_u:
            case Opcodes.i32_LE_s:
            case Opcodes.i32_GT_u:
            case Opcodes.i32_GT_s:
            case Opcodes.i32_GE_u:
            case Opcodes.i32_GE_s:
            case Opcodes.i32_EQZ:
            case Opcodes.i32_NE:
            case Opcodes.i32_EQ:
            case Opcodes.i32_WRAP_i64:
            
            case Opcodes.i64_SUB:
            case Opcodes.i64_ADD:
            case Opcodes.i64_MUL:
            case Opcodes.i64_DIV_u:
            case Opcodes.i64_AND:            
            case Opcodes.i64_OR:
            case Opcodes.i64_XOR:
            case Opcodes.i64_SHL:
            case Opcodes.i64_SHR_s:
            case Opcodes.i64_SHR_u:
            case Opcodes.i64_LT_u:
            case Opcodes.i64_LT_s:
            case Opcodes.i64_LE_u:
            case Opcodes.i64_LE_s:
            case Opcodes.i64_GT_u:
            case Opcodes.i64_GT_s:
            case Opcodes.i64_GE_u:
            case Opcodes.i64_GE_s:
            case Opcodes.i64_EQZ:
            case Opcodes.i64_NE:
            case Opcodes.i64_EQ:
            
            case Opcodes.parametric_DROP:
            case Opcodes.parametric_SELECT: 
            
            case Opcodes.ctrl_END:
            case Opcodes.ctrl_ELSE:
            case Opcodes.ctrl_RETURN:
                addCode(opcode, []);
                break;
                
            case Opcodes.ctrl_BLOCK:
            case Opcodes.ctrl_LOOP:
            case Opcodes.ctrl_IF:
                addCode(opcode, []);
                handleBlock();
                break;
                
            case Opcodes.ctrl_CALL:
                int fn = reader.readU32();
                addCode(opcode, [fn]);
                break;
                
            case Opcodes.ctrl_CALL_INDIRECT:
                int typeIndex = reader.readU32();
                int b00 = reader.readByte();
                if(b00 == 0x00) {
                    _show("Call indirect!");
                }
                break;                
                
            case Opcodes.ctrl_BR_IF:
            case Opcodes.ctrl_BR:
                int labelIndex = reader.readU32();
                break;
                
            case Opcodes.local_SET:
            case Opcodes.local_GET:
            case Opcodes.local_TEE:
            case Opcodes.global_GET:
            case Opcodes.global_SET:
                int index = reader.readU32();
                addCode(opcode, [index]);
                break;
                
            case Opcodes.i32_LOAD:
            case Opcodes.i32_LOAD8_s:
            case Opcodes.i32_LOAD8_u:
            case Opcodes.i64_LOAD:
            case Opcodes.i32_STORE:
            case Opcodes.i32_STORE8:
            case Opcodes.i64_STORE:            
                readMemArg();
                break;
                
            default:
                print("Not found!");
                exit(1);
        }
    }
    
    void readExpr({bool insideFunction = false}) {
        while(true) {
            int opcode = reader.readByte();            
            if(opcode == 0x0b) {  
                _show("Expression ended");
                if(insideFunction) {
                    cg.addReturnIfNecessary(currentFn);
                }
                processOpCode(opcode);
                break;
            }
            processOpCode(opcode);
        }
    }
    
    void readElementSection(int size) {
        int originalOffset = reader.offset;
        int nElements = reader.readU32();
        for(int i=0;i<nElements;i++) {
            int index = reader.readU32();
            readExpr();
            int nIndices = reader.readU32();
            for(int j=0;j<nIndices;j++) {
                int fi = reader.readU32();
            }
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the element section");
        }
    }
    
    void readMemorySection(int size) {
        int originalOffset = reader.offset;
        int nMems = reader.readU32();
        for(int i=0;i<nMems;i++) {
            readLimit();
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the memory section");
        }
    }
    
    void readGlobalsSection(int size) {
        int originalOffset = reader.offset;
        int nGlobals = reader.readU32();
        for(int i=0;i<nGlobals;i++) {
            int valType = reader.readByte();
            int mutability = reader.readByte();
            if(mutability == 0) {
                _show("Found global const");
            } else {
                _show("Found global var");
            }
            readExpr();
        }
        
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the globals section");
        }
    }

    void readStartSection(int size) {
        int originalOffset = reader.offset;
        
        int startFnIndex = reader.readU32();
        _show("Start with function $startFnIndex");
        
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the start section");
        }
    }
    
    void readCodeSection(int size) {
        int originalOffset = reader.offset;
        int nEntries = reader.readU32();
        for(int i=0;i<nEntries;i++) {
            int functionSize = reader.readU32();
            int nLocals = reader.readU32();
            for(int j=0;j<nLocals;j++) {
                int nOfType = reader.readU32();
                int valType = reader.readByte();
                cg.addLocalsOfType(i, nOfType, valType);
                _show("Function $i: $nOfType locals of type " + Utils.getValueTypeName(valType));
            }
            currentFn = i;
            readExpr(insideFunction: true);            
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the code section");
        }
    }
    
    void readDataSection(int size) {
        int originalOffset = reader.offset;
        int nData = reader.readU32();
        for(int i=0;i<nData;i++) {
            int memIndex = reader.readU32();
            readExpr();
            int nBytes = reader.readU32();
            for(int j=0;j<nBytes;j++) {
                int b = reader.readByte();
            }
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the data section");
        }
    }
    
    void readCustomSection(int size) {
        reader.offset += size; // Skip custom sections for now
    }
    
    void readSection() {
        int sectionType = reader.readByte();
        int sectionSize = reader.readU32();
        currentSection = sectionType;
        switch(sectionType) {
            case 0: readCustomSection(sectionSize);
                    break;
            case 1: readTypeSection(sectionSize);
                    break;
            case 2: readImportSection(sectionSize);
                    break;
            case 3: readFunctionSection(sectionSize);
                    break;
            case 4: readTableSection(sectionSize);
                    break;
            case 5: readMemorySection(sectionSize);
                    break;
            case 6: readGlobalsSection(sectionSize);
                    break;
            case 7: readExportSection(sectionSize);
                    break;
            case 8: readStartSection(sectionSize);
                    break;
            case 9: readElementSection(sectionSize);
                    break;
            case 10: readCodeSection(sectionSize);
                     break;
            case 11: readDataSection(sectionSize);
                     break;
            default: _show("Invalid section: $sectionType");
        }
    }
    
    void addCode(int opcode, List parameters) {
        if(currentSection == 10) {
            cg.addCode(currentFn, opcode, parameters);
        }
    }
    
    void parse() {
        if(!checkMagic()) {
            _show("Not valid WASM file.");
            return;
        }
        if(!checkVersion()) {
            _show("Invalid version");
            return;
        }
        while(true) {
            readSection();
            if(reader.isReadComplete()) {
                break;
            }
        }
        cg.generateFunctions();
    }
    
    void _show(s) {
        //print(s);
    }
}
