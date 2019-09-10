#$Id: Giovanni-UnitsConversion_checkConversions.t,v 1.3 2015/04/09 20:41:13 csmit Exp $
#-@@@ Giovanni, Version $Name:  $
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Giovanni-UnitsConversion.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 5;
BEGIN { use_ok('Giovanni::UnitsConversion') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use warnings;
use strict;
use Giovanni::Data::NcFile;
use File::Temp qq/tempdir/;
use List::MoreUtils qq/uniq/;

my $dir = tempdir( CLEANUP => 1 );

my $conversionCfg = <<XML;
<units>
    <linearConversions>
        <linearUnit source="mm/hr" destination="mm/day"
            scale_factor="24" add_offset="0" />
        <linearUnit source="mm/hr" destination="inch/hr"
            scale_factor="1.0/25.4" add_offset="0" />
        <linearUnit source="mm/hr" destination="inch/day"
            scale_factor="24.0/25.4" add_offset="0" />
        <linearUnit source="mm/day" destination="mm/hr"
            scale_factor="1.0/24.0" add_offset="0" />
        <linearUnit source="mm/day" destination="inch/day"
            scale_factor="1.0/25.4" add_offset="0" />
        <linearUnit source="kg/m^2" destination="mm" scale_factor="1"
            add_offset="0" />
        <linearUnit source="K" destination="C" scale_factor="1"
            add_offset="-273.15" />
        <linearUnit source="kg/m^2/s" destination="mm/s"
            scale_factor="1" add_offset="0" />
        <linearUnit source="molecules/cm^2" destination="DU"
            scale_factor="1.0/2.6868755e+16" add_offset="0" />
    </linearConversions>
    <nonLinearConversions>
        <timeDependentUnit source="mm/hr" destination="mm/month"
            class="Giovanni::UnitsConversion::MonthlyAccumulation"
            to_days_scale_factor="24.0" temporal_resolutions="monthly"/>
        <timeDependentUnit source="mm/hr" destination="inch/month"
            class="Giovanni::UnitsConversion::MonthlyAccumulation"
            to_days_scale_factor="24.0/25.4" temporal_resolutions="monthly"/>
        <timeDependentUnit source="mm/hr" destination="inch/month"
            class="Giovanni::UnitsConversion::MonthlyAccumulation"
            to_days_scale_factor="86400.0" temporal_resolutions="monthly"/>
    </nonLinearConversions>
    <fileFriendlyStrings>
        <destinationUnit original="mm/day" file="mmPday" />
        <destinationUnit original="inch/hr" file="inPhr" />
        <destinationUnit original="inch/day" file="inPday" />
        <destinationUnit original="mm/hr" file="mmPhr" />
        <destinationUnit original="mm" file="mm" />
        <destinationUnit original="mm/s" file="mmPs" />
        <destinationUnit original="DU" file="DU" />
        <destinationUnit original="mm/month" file="mmPmon" />
        <destinationUnit original="inch/month" file="inPmon" />
    </fileFriendlyStrings>
</units>
XML
my $cfg = "$dir/cfg.xml";
open( CFG, ">", $cfg );
print CFG $conversionCfg;
close(CFG);

my %ret = Giovanni::UnitsConversion::checkConversions(
    config             => $cfg,
    sourceUnits        => 'mm/day',
    destinationUnits   => ['mm/hr'],
    temporalResolution => 'daily',
);
is_deeply(
    \%ret,
    {   allOkay => 1,

    },
    'No incorrect conversions'
);

%ret = Giovanni::UnitsConversion::checkConversions(
    config             => $cfg,
    sourceUnits        => 'mm/day',
    destinationUnits   => [ 'mm/hr', 'mm' ],
    temporalResolution => 'daily',
);
is_deeply(
    \%ret,
    {   allOkay                            => 0,
        problemUnits                       => ['mm'],
        conversionsThatDontExist           => ['mm'],
        conversionsForOtherTimeResolutions => [],
        message =>
            "The following conversions are not available for mm/day: mm."
    },
    'Unknown conversion'
);
%ret = Giovanni::UnitsConversion::checkConversions(
    config             => $cfg,
    sourceUnits        => 'mm/hr',
    destinationUnits   => [ 'mm/month', 'mm/day' ],
    temporalResolution => 'monthly',
);
is_deeply(
    \%ret,
    {   allOkay => 1,

    },
    'Correctly monthly conversion'
);

%ret = Giovanni::UnitsConversion::checkConversions(
    config             => $cfg,
    sourceUnits        => 'mm/hr',
    destinationUnits   => [ 'mm/day', 'kg', 'elephant', 'mm/month' ],
    temporalResolution => 'daily',
);

is_deeply(
    \%ret,
    {   allOkay      => 0,
        problemUnits => [ 'kg', 'elephant', 'mm/month' ],
        conversionsThatDontExist           => [ 'kg', 'elephant' ],
        conversionsForOtherTimeResolutions => ['mm/month'],
        message =>
            "The following conversions are not available for mm/hr: kg, "
            . "elephant. The following conversions are not available for mm/hr "
            . "with daily temporal resolution: mm/month."
    },
    'All kinds of wrong units'
);

1;
