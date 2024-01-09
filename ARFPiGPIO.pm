package ARFPiGPIO;

## Input 1: GPIO Pin to be initialized (NOT the Physical Pin)
## Input 2: GPIO Direction (Expects "in" or "out")
## Input 3: Initial State (Expects "0" or "1")
## Output: None
## This routine initilizes GPIO using the sysfs methods.
sub InitializeGPIO {

    my $GPIONum   = shift;
    my $Direction = shift;
    my $State     = shift;

    system( "echo " . $GPIONum . " >/sys/class/gpio/export" );
    system("sudo chmod -R 777 /sys/class/gpio/gpio*");
    system( "echo " . $Direction . " >/sys/class/gpio/gpio" . $GPIONum . "/direction" );
    system( "echo " . $State . " >/sys/class/gpio/gpio" . $GPIONum . "/value" );

}

sub WriteGPIO {

    my $GPIONum = shift;
    my $State   = shift;

    system( "echo " . $State . " >/sys/class/gpio/gpio" . $GPIONum . "/value" );

}

sub ReadGPIO {

    my $GPIONum = shift;

    system( "cat >/sys/class/gpio/gpio" . $GPIONum . "/value" );

}

sub UninitializeGPIO {

    my $GPIONum = shift;

    system( "echo " . $GPIONum . " >/sys/class/gpio/unexport" );

}

1;
