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
import './utils.dart';

class Parser {
    String filename;
    WASMReader reader;
    
    TypesHolder typesHolder = TypesHolder();
    FunctionsHolder functionsHolder = FunctionsHolder();
    
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
        
        typesHolder.add(
            FunctionType(
                nParameters: nParameters,
                nResults: nResults,
                parameters: parameters,
                results: results
            )
        );
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
                int n = reader.readU32();
            } else if(descb1 == 0x01) {
                _show("Table");
                readTableType();
            }
        }
        
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the import section");
        }
    }
    
    void readFunctionSection(int size) {
        int originalOffset = reader.offset;
        int nTypeIndices = reader.readU32();
        for(int i=0;i<nTypeIndices;i++) {
            int index = reader.readU32();            
            functionsHolder.add(index);            
            _show("Type index: " + Utils.get0x(index));
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
        _show("Processing opcode: 0x${Utils.get0x(opcode)}");
        if(opcode == Opcodes.i32_CONST) {
            int n = reader.readS32();
            _show("32-bit constant value is $n");
        }
        else if(opcode == Opcodes.i64_CONST) {
            int n = reader.readS64();
            _show("64-bit constant value is $n");
        }
        else if(opcode == Opcodes.local_GET) {
            int i = reader.readU32();
            _show("Fetch local value $i");
        }
        else if(opcode == Opcodes.i64_LT_u) {
            _show("lt_u");
        }
        else if(opcode == Opcodes.i32_LT_u) {
            _show("lt_u");
        }
        else if(opcode == Opcodes.i32_EQZ) {
            _show("eqz");
        }
        else if(opcode == Opcodes.ctrl_IF) {
            _show("If condition starts");
            handleBlock();
        }
        else if(opcode == Opcodes.ctrl_ELSE) {
            _show("Else starts");
        }
        else if(opcode == Opcodes.ctrl_RETURN) {
            _show("Return");            
        }
        else if(opcode == Opcodes.i32_SUB) {
            _show("Subtract32");
        }
        else if(opcode == Opcodes.i32_ADD) {
            _show("Add32");
        }
        else if(opcode == Opcodes.i64_SUB) {
            _show("Subtract64");
        }
        else if(opcode == Opcodes.i64_ADD) {
            _show("Add64");
        }
        else if(opcode == Opcodes.ctrl_CALL) {
            int fn = reader.readU32();
            _show("Call function $fn");
        }
    }
    
    void readExpr() {
        while(true) {
            int opcode = reader.readByte();
            if(opcode == 0x0b) {
                _show("Expression ended");
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
            _show("Something's wrong in the import section");
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
                _show("$nOfType locals of type $valType");
            }
            readExpr();
        }
        if(!reader.isOffsetCorrect(originalOffset, size)) {
            _show("Something's wrong in the code section");
        }
    }
    
    void readCustomSection(int size) {
        reader.offset += size; // Skip custom sections for now
    }
    
    void readSection() {
        int sectionType = reader.readByte();
        int sectionSize = reader.readU32();
        _show("Section type: $sectionType");
        if(sectionType == 0) {
            readCustomSection(sectionSize);
        }
        if(sectionType == 1) {
            readTypeSection(sectionSize);
        }
        if(sectionType == 2) {
            readImportSection(sectionSize);
        }
        if(sectionType == 3) {
            readFunctionSection(sectionSize);
        }        
        if(sectionType == 4) {
            readTableSection(sectionSize);
        }
        if(sectionType == 5) {
            readMemorySection(sectionSize);
        }
        if(sectionType == 6) {
            readGlobalsSection(sectionSize);
        }
        if(sectionType == 7) {
            readExportSection(sectionSize);
        }
        if(sectionType == 8) {
            readStartSection(sectionSize);
        }
        if(sectionType == 9) {
            readElementSection(sectionSize);
        }
        if(sectionType == 10) {
            readCodeSection(sectionSize);
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
    }
    
    void _show(s) {
        print(s);
    }
}
