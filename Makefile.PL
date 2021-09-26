use lib '.';
use inc::Module::Install;

RTx     'RT-Extension-PersistentTimers';
license 'gpl_2';

my ($lib_path) = $INC{'RT.pm'} =~ /^(.*)[\\\/]/;
my $local_lib_path = "$RT::LocalPath/lib";
unshift @INC, $local_lib_path, $lib_path;

substitute(
    {
        RT_LIB_PATH => join( ' ', $local_lib_path, $lib_path ),
    },
    { sufix => '.in' },
    'xt/lib/RT/Extension/PersistentTimers/Test.pm',
);

repository 'https://github.com/renderorange/rt-extension-persistenttimers';
bugtracker 'https://github.com/renderorange/rt-extension-persistenttimers/issues';

requires_rt '5.0.0';
rt_too_new '5.2.0';

sign;
WriteAll;
