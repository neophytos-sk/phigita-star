// Encode an unsigned 64-bit varint.  Returns number of encoded bytes.
// 'buffer' must have room for up to 10 bytes.
int encode_unsigned_varint(uint8_t *const buffer, uint64_t value)
{
    int encoded = 0;

    do
    {
        uint8_t next_byte = value & 0x7F;
        value >>= 7;

        if (value)
            next_byte |= 0x80;

        buffer[encoded++] = next_byte;

    } while (value);


    return encoded;
}

// Encode a signed 64-bit varint.  Works by first zig-zag transforming
// signed value into an unsigned value, and then reusing the unsigned
// encoder.  'buffer' must have room for up to 10 bytes.
int encode_signed_varint(uint8_t *const buffer, int64_t value)
{
    uint64_t uvalue;

    uvalue = uint64_t( value < 0 ? ~(value << 1) : (value << 1) );

    return encode_unsigned_varint( buffer, uvalue );
}

#include <stdint.h>
#include <iostream>


uint64_t decode_unsigned_varint( const uint8_t *const data, int &decoded_bytes )
{
    int i = 0;
    uint64_t decoded_value = 0;
    int shift_amount = 0;

    do 
    {
        decoded_value |= (uint64_t)(data[i] & 0x7F) << shift_amount;     
        shift_amount += 7;
    } while ( (data[i++] & 0x80) != 0 );

    decoded_bytes = i;
    return decoded_value;
}

int64_t decode_signed_varint( const uint8_t *const data, int &decoded_bytes )
{
    uint64_t unsigned_value = decode_unsigned_varint(data, decoded_bytes);
    return (int64_t)( unsigned_value & 1 ? ~(unsigned_value >> 1) 
                                         :  (unsigned_value >> 1) );
}



uint8_t ex_p300[] = { 0xAC, 0x02 };
uint8_t ex_n1  [] = { 0x01 };

using namespace std;

int main()
{
    int decoded_bytes_p300;
    uint64_t p300;

    p300 = decode_unsigned_varint( ex_p300, decoded_bytes_p300 );

    int decoded_bytes_n1;
    int64_t  n1;

    n1 = decode_signed_varint( ex_n1, decoded_bytes_n1 );

    cout << "p300 = " << p300 
         << "   decoded_bytes_p300 = " << decoded_bytes_p300 << endl;

    cout << "n1 = " << n1 
         << "   decoded_bytes_n1 = " << decoded_bytes_n1 << endl;

    return 0;
}


// http://stackoverflow.com/questions/19758270/read-varint-from-linux-sockets


