package ARFConvert;

use Data::Dumper;
sub ToBinary {
    ## Input 1: Decimal or Hexadecimal Number of any size.
        # Example Decimal: 314, 420, 1234
        # Example Hex: 0xFFF0, 0xCAFE, 0x03
            # Hex MUST have 0x prefix
    ## Output: Binary Number in the form of an ARRAY of 1s and 0s
    ## This routine takes a decimal or hex number and converts it to binary. 
    ## Leading zeros are not present. Binary Array will be of minimal size.

    my $NumToConvert = shift;

    my $BinaryNum = sprintf ("%b", $NumToConvert);
    my @BinaryArray = split(//, $BinaryNum);

    return @BinaryArray;

}

sub ToBinaryLeadingZeroes {
    ## Input 1: Decimal or Hexadecimal Number of any size.
        # Example Decimal: 314, 420, 1234
        # Example Hex: 0xFFF0, 0xCAFE, 0x03
            # Hex MUST have 0x prefix
    ## Input 2: How many bits is the desired Binary Array
    ## Output: Binary Number in the form of an ARRAY of 1s and 0s
    ## This routine takes a decimal or hex number and converts it to binary. .

    my $NumToConvert = shift;
    my $NumBitsDesired = shift;

    my $BinaryNum = sprintf ("%b", $NumToConvert);
    my $NumLeadingZeroes = $NumBitsDesired - length( $BinaryNum );
    my @LeadingZeroes = (0) x $NumLeadingZeroes;
    my @BinaryArray = ( @LeadingZeroes, split(//, $BinaryNum));
    
    return @BinaryArray

}

1;
