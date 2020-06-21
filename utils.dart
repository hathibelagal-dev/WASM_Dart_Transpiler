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
    
    static String toDartType(i) {
        switch(i) {
            case 0x7F:
                return "int";
            case 0x7E:
                return "int";
            case 0x7D:
                return "double";
            case 0x7C:
                return "double";
        }
    }

    static String get0x(int v) {
        return v.toRadixString(16);
    }        
}
