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

class Utils {
    static String getValueTypeName(i) {
        switch(i) {
            case 0x7F:
                return "i32";
            case 0x7E:
                return "i64";
            case 0x7D:
                return "f32";
            case 0x7C:
                return "f64";
        }
    }

    static String get0x(int v) {
        return v.toRadixString(16);
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
    
    void add(int index) {
        contents[nFunctions] = index;
        nFunctions++;
    }
}
