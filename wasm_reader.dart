import 'dart:typed_data';

class WASMReader {
    ByteData data;
    int offset = 0;
    int fileLength;
    
    WASMReader({this.data, this.fileLength});
    
    int readUnsigned(int size) {
        int result = 0;
        int shift = 0;
        int byte = 0;
        while (true) {
            byte = readByte();
            int bits7 = byte & 0x7f;
            result |= (bits7 << shift);
            if((byte & 0x80) == 0) {
                break;
            }
            shift += 7;
        }
        return result;
    }
    
    int readSigned(int size) {
        int result = 0;
        int cur;
        int count = 0;
        int signBits = -1;
        while(true) {
            cur = readByte() & 0xff;
            result |= (cur & 0x7f) << (count *7);
            signBits <<= 7;
            count++;
            if(((cur & 0x80) == 0)) break;
        }
        if(((signBits >> 1) & result) != 0) {
            result |= signBits;
        }
        return result;
    }
    
    int readSignedOld(int size) {
        int result = 0;
        int shift = 0;
        int byte = 0;
        while(true) {
            byte = readByte();
            int bits7 = byte & 0x7f;
            result |= (bits7 << shift);
            shift += 7;
            if((byte & 0x80) == 0) {
                break;
            }
        };

        if ((shift < size) && ((byte & 0x80) == 1)) {
            result |= (~0 << shift);
        }
        
        return result;
    }
    
    int readU32() {
        return readUnsigned(32);
    }
    
    int readS32() {
        return readSigned(32);
    }
    
    int readS64() {
        return readSigned(64);
    }
    
    int readByte() {
        int output = data.getUint8(offset);
        offset += 1;
        return output;
    }    
    
    bool isOffsetCorrect(int oo, int size) {
        return (offset - oo == size);
    }
    
    bool isReadComplete() {
        return fileLength - offset == 0;
    }
}
