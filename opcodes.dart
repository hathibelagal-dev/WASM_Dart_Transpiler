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
    static final int i64_LOAD = 0x29;
    static final int i64_LOAD8_s = 0x30;
    static final int i64_LOAD8_u = 0x31;
    static final int i64_LOAD16_s = 0x32;
    static final int i64_LOAD16_u = 0x33;
    static final int i64_LOAD32_s = 0x34;
    static final int i64_LOAD32_u = 0x35;
    static final int i64_STORE = 0x37;
    static final int i64_STORE8 = 0x3c;
    static final int i64_STORE16 = 0x3d;
    static final int i64_STORE32 = 0x3e;
    static final int i64_CONST = 0x42;
    static final int i64_EQZ = 0x50;
    static final int i64_EQ = 0x51;
    static final int i64_NE = 0x52;
    static final int i64_LT_s = 0x53;
    static final int i64_LT_u = 0x54;
    static final int i64_GT_s = 0x55;
    static final int i64_GT_u = 0x56;
    static final int i64_LE_s = 0x57;
    static final int i64_LE_u = 0x58;
    static final int i64_GE_s = 0x59;
    static final int i64_GE_u = 0x5a;
    static final int i64_CLZ = 0x79;
    static final int i64_CTZ = 0x7a;
    static final int i64_POPCNT = 0x7b;
    static final int i64_ADD = 0x7c;
    static final int i64_SUB = 0x7d;
    static final int i64_MUL = 0x7e;
    static final int i64_DIV_s = 0x7f;
    static final int i64_DIV_u = 0x80;
    static final int i64_REM_s = 0x81;
    static final int i64_REM_u = 0x82;
    static final int i64_AND = 0x83;
    static final int i64_OR = 0x84;
    static final int i64_XOR = 0x85;
    static final int i64_SHL = 0x86;
    static final int i64_SHR_s = 0x87;
    static final int i64_SHR_u = 0x88;
    static final int i64_ROTL = 0x89;
    static final int i64_ROTR = 0x8a;
    static final int i64_EXTEND_i32_s = 0xac;
    static final int i64_EXTEND_i32_u = 0xad;
    static final int i64_TRUNC_f32_s = 0xae;
    static final int i64_TRUNC_f32_u = 0xaf;
    static final int i64_TRUNC_f64_s = 0xb0;
    static final int i64_TRUNC_f64_u = 0xb1;
    static final int i64_REINTERPRET_f64 = 0xbd;

    static final int i32_LOAD = 0x28;
    static final int i32_LOAD8_s = 0x2c;
    static final int i32_LOAD8_u = 0x2d;
    static final int i32_LOAD16_s = 0x2e;
    static final int i32_LOAD16_u = 0x2f;
    static final int i32_STORE = 0x36;
    static final int i32_STORE8 = 0x3a;
    static final int i32_STORE16 = 0x3b;
    static final int i32_CONST = 0x41;
    static final int i32_EQZ = 0x45;
    static final int i32_EQ = 0x46;
    static final int i32_NE = 0x47;
    static final int i32_LT_s = 0x48;
    static final int i32_LT_u = 0x49;
    static final int i32_GT_s = 0x4a;
    static final int i32_GT_u = 0x4b;
    static final int i32_LE_s = 0x4c;
    static final int i32_LE_u = 0x4d;
    static final int i32_GE_s = 0x4e;
    static final int i32_GE_u = 0x4f;
    static final int i32_CLZ = 0x67;
    static final int i32_CTZ = 0x68;
    static final int i32_POPCNT = 0x69;
    static final int i32_ADD = 0x6a;
    static final int i32_SUB = 0x6b;
    static final int i32_MUL = 0x6c;
    static final int i32_DIV_s = 0x6d;
    static final int i32_DIV_u = 0x6e;
    static final int i32_REM_s = 0x6f;
    static final int i32_REM_u = 0x70;
    static final int i32_AND = 0x71;
    static final int i32_OR = 0x72;
    static final int i32_XOR = 0x73;
    static final int i32_SHL = 0x74;
    static final int i32_SHR_s = 0x75;
    static final int i32_SHR_u = 0x76;
    static final int i32_ROTL = 0x77;
    static final int i32_ROTR = 0x78;
    static final int i32_WRAP_i64 = 0xa7;
    static final int i32_TRUNC_f32_s = 0xa8;
    static final int i32_TRUNC_f32_u = 0xa9;
    static final int i32_TRUNC_f64_s = 0xaa;
    static final int i32_TRUNC_f64_u = 0xab;
    static final int i32_REINTERPRET_f32 = 0xbc;

    static final int f32_LOAD = 0x2a;
    static final int f32_STORE = 0x38;
    static final int f32_CONST = 0x43;
    static final int f32_EQ = 0x5b;
    static final int f32_NE = 0x5c;
    static final int f32_LT = 0x5d;
    static final int f32_GT = 0x5e;
    static final int f32_LE = 0x5f;
    static final int f32_GE = 0x60;
    static final int f32_ABS = 0x8b;
    static final int f32_NEG = 0x8c;
    static final int f32_FLOOR = 0x8e;
    static final int f32_TRUNC = 0x8f;
    static final int f32_NEAREST = 0x90;
    static final int f32_SQRT = 0x91;
    static final int f32_ADD = 0x92;
    static final int f32_SUB = 0x93;
    static final int f32_MUL = 0x94;
    static final int f32_DIV = 0x95;
    static final int f32_MIN = 0x96;
    static final int f32_MAX = 0x97;
    static final int f32_COPYSIGN = 0x98;
    static final int f32_CONVERT_i32_s = 0xb2;
    static final int f32_CONVERT_i32_u = 0xb3;
    static final int f32_CONVERT_i64_s = 0xb4;
    static final int f32_CONVERT_i64_u = 0xb5;
    static final int f32_DEMOTE_f64 = 0xb6;
    static final int f32_REINTERPRET_i32 = 0xbe;

    static final int local_GET = 0x20;
    static final int local_SET = 0x21;
    static final int local_TEE = 0x22;

    static final int global_GET = 0x23;
    static final int global_SET = 0x24;

    static final int ctrl_UNREACHABLE = 0x0;
    static final int ctrl_NOP = 0x1;
    static final int ctrl_BLOCK = 0x2;
    static final int ctrl_LOOP = 0x3;
    static final int ctrl_IF = 0x4;
    static final int ctrl_ELSE = 0x5;
    static final int ctrl_END = 0xb;
    static final int ctrl_BR = 0xc;
    static final int ctrl_BR_IF = 0xd;
    static final int ctrl_BR_TABLE = 0xe;
    static final int ctrl_RETURN = 0xf;
    static final int ctrl_CALL = 0x10;
    static final int ctrl_CALL_INDIRECT = 0x11;
}
