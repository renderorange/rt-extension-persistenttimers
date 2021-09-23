use lib '.';
use inc::Module::Install;

RTx     'RT-Extension-PersistentTimers';
license 'gpl_2';
repository 'https://github.com/renderorange/rt-extension-persistenttimers';
bugtracker 'https://github.com/renderorange/rt-extension-persistenttimers/issues';

requires_rt '5.0.0';
rt_too_new '5.2.0';

sign;
WriteAll;
