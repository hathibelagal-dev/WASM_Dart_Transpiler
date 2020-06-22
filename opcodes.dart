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

class Opcodes {
    static const int i64_LOAD = 0x29;
    static const int i64_LOAD8_s = 0x30;
    static const int i64_LOAD8_u = 0x31;
    static const int i64_LOAD16_s = 0x32;
    static const int i64_LOAD16_u = 0x33;
    static const int i64_LOAD32_s = 0x34;
    static const int i64_LOAD32_u = 0x35;
    static const int i64_STORE = 0x37;
    static const int i64_STORE8 = 0x3c;
    static const int i64_STORE16 = 0x3d;
    static const int i64_STORE32 = 0x3e;
    static const int i64_CONST = 0x42;
    static const int i64_EQZ = 0x50;
    static const int i64_EQ = 0x51;
    static const int i64_NE = 0x52;
    static const int i64_LT_s = 0x53;
    static const int i64_LT_u = 0x54;
    static const int i64_GT_s = 0x55;
    static const int i64_GT_u = 0x56;
    static const int i64_LE_s = 0x57;
    static const int i64_LE_u = 0x58;
    static const int i64_GE_s = 0x59;
    static const int i64_GE_u = 0x5a;
    static const int i64_CLZ = 0x79;
    static const int i64_CTZ = 0x7a;
    static const int i64_POPCNT = 0x7b;
    static const int i64_ADD = 0x7c;
    static const int i64_SUB = 0x7d;
    static const int i64_MUL = 0x7e;
    static const int i64_DIV_s = 0x7f;
    static const int i64_DIV_u = 0x80;
    static const int i64_REM_s = 0x81;
    static const int i64_REM_u = 0x82;
    static const int i64_AND = 0x83;
    static const int i64_OR = 0x84;
    static const int i64_XOR = 0x85;
    static const int i64_SHL = 0x86;
    static const int i64_SHR_s = 0x87;
    static const int i64_SHR_u = 0x88;
    static const int i64_ROTL = 0x89;
    static const int i64_ROTR = 0x8a;
    static const int i64_EXTEND_i32_s = 0xac;
    static const int i64_EXTEND_i32_u = 0xad;
    static const int i64_TRUNC_f32_s = 0xae;
    static const int i64_TRUNC_f32_u = 0xaf;
    static const int i64_TRUNC_f64_s = 0xb0;
    static const int i64_TRUNC_f64_u = 0xb1;
    static const int i64_REINTERPRET_f64 = 0xbd;

    static const int i32_LOAD = 0x28;
    static const int i32_LOAD8_s = 0x2c;
    static const int i32_LOAD8_u = 0x2d;
    static const int i32_LOAD16_s = 0x2e;
    static const int i32_LOAD16_u = 0x2f;
    static const int i32_STORE = 0x36;
    static const int i32_STORE8 = 0x3a;
    static const int i32_STORE16 = 0x3b;
    static const int i32_CONST = 0x41;
    static const int i32_EQZ = 0x45;
    static const int i32_EQ = 0x46;
    static const int i32_NE = 0x47;
    static const int i32_LT_s = 0x48;
    static const int i32_LT_u = 0x49;
    static const int i32_GT_s = 0x4a;
    static const int i32_GT_u = 0x4b;
    static const int i32_LE_s = 0x4c;
    static const int i32_LE_u = 0x4d;
    static const int i32_GE_s = 0x4e;
    static const int i32_GE_u = 0x4f;
    static const int i32_CLZ = 0x67;
    static const int i32_CTZ = 0x68;
    static const int i32_POPCNT = 0x69;
    static const int i32_ADD = 0x6a;
    static const int i32_SUB = 0x6b;
    static const int i32_MUL = 0x6c;
    static const int i32_DIV_s = 0x6d;
    static const int i32_DIV_u = 0x6e;
    static const int i32_REM_s = 0x6f;
    static const int i32_REM_u = 0x70;
    static const int i32_AND = 0x71;
    static const int i32_OR = 0x72;
    static const int i32_XOR = 0x73;
    static const int i32_SHL = 0x74;
    static const int i32_SHR_s = 0x75;
    static const int i32_SHR_u = 0x76;
    static const int i32_ROTL = 0x77;
    static const int i32_ROTR = 0x78;
    static const int i32_WRAP_i64 = 0xa7;
    static const int i32_TRUNC_f32_s = 0xa8;
    static const int i32_TRUNC_f32_u = 0xa9;
    static const int i32_TRUNC_f64_s = 0xaa;
    static const int i32_TRUNC_f64_u = 0xab;
    static const int i32_REINTERPRET_f32 = 0xbc;

    static const int f32_LOAD = 0x2a;
    static const int f32_STORE = 0x38;
    static const int f32_CONST = 0x43;
    static const int f32_EQ = 0x5b;
    static const int f32_NE = 0x5c;
    static const int f32_LT = 0x5d;
    static const int f32_GT = 0x5e;
    static const int f32_LE = 0x5f;
    static const int f32_GE = 0x60;
    static const int f32_ABS = 0x8b;
    static const int f32_NEG = 0x8c;
    static const int f32_FLOOR = 0x8e;
    static const int f32_TRUNC = 0x8f;
    static const int f32_NEAREST = 0x90;
    static const int f32_SQRT = 0x91;
    static const int f32_ADD = 0x92;
    static const int f32_SUB = 0x93;
    static const int f32_MUL = 0x94;
    static const int f32_DIV = 0x95;
    static const int f32_MIN = 0x96;
    static const int f32_MAX = 0x97;
    static const int f32_COPYSIGN = 0x98;
    static const int f32_CONVERT_i32_s = 0xb2;
    static const int f32_CONVERT_i32_u = 0xb3;
    static const int f32_CONVERT_i64_s = 0xb4;
    static const int f32_CONVERT_i64_u = 0xb5;
    static const int f32_DEMOTE_f64 = 0xb6;
    static const int f32_REINTERPRET_i32 = 0xbe;

    static const int local_GET = 0x20;
    static const int local_SET = 0x21;
    static const int local_TEE = 0x22;

    static const int global_GET = 0x23;
    static const int global_SET = 0x24;

    static const int ctrl_UNREACHABLE = 0x0;
    static const int ctrl_NOP = 0x1;
    static const int ctrl_BLOCK = 0x2;
    static const int ctrl_LOOP = 0x3;
    static const int ctrl_IF = 0x4;
    static const int ctrl_ELSE = 0x5;
    static const int ctrl_END = 0xb;
    static const int ctrl_BR = 0xc;
    static const int ctrl_BR_IF = 0xd;
    static const int ctrl_BR_TABLE = 0xe;
    static const int ctrl_RETURN = 0xf;
    static const int ctrl_CALL = 0x10;
    static const int ctrl_CALL_INDIRECT = 0x11;
    
    static const int parametric_DROP = 0x1A;
    static const int parametric_SELECT = 0x1B;
    
    static const int memory_SIZE = 0x3F;
    static const int memory_GROW = 0x40;
}
