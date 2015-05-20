use 5.8.8;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME               => 'Replay::EventSystem::RabbitMQ',
    AUTHOR             => q{David Ihnen <davidihnen@gmail.com>},
    VERSION_FROM       => 'lib/Replay/EventSystem/RabbitMQ.pm',
    ABSTRACT_FROM      => 'lib/Replay/EventSystem/RabbitMQ.pm',
    LICENSE            => 'Artistic_2_0',
    PL_FILES           => {},
    MIN_PERL_VERSION   => 5.8.8,
    CONFIGURE_REQUIRES => { 'ExtUtils::MakeMaker' => 0, },
    BUILD_REQUIRES     => {
        'Test::More'  => 0,
        'Test::More'  => 1.001003,
        'Test::Most'  => 0.33,
        'File::Slurp' => '999.19',
        'Replay'      => '0.03',
    },
    PREREQ_PM => {
        'Carp'                                 => '1.3301',
        'Data::UUID'                           => '1.219',
        'Net::RabbitMQ'                        => '0.2.7',
        'JSON'                                 => '2.53',
        'JSON::Any'                            => '1.29',
        'Replay'                               => '0.03',
        'Moose'                                => '2.1209',
        'Moose::Util::TypeConstraints'         => '2.1209',
        'MooseX::MetaDescription::Meta::Trait' => '0.06',
        'MooseX::Storage'                      => '0.46',
        'POSIX'                                => '1.09',
        'Perl::Version'                        => '1.013',
        'Readonly'                             => '1.04',
        'Scalar::Util'                         => '1.21',
        'Storable'                             => '2.45',
        'Time::HiRes'                          => '1.9717',
        'Try::Tiny'                            => '0.11',
        'perl'                                 => '5.008008',
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Replay-*' },
);
