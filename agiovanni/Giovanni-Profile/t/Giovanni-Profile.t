#!/usr/bin/perl
use strict;
use File::Temp qw/ tempdir /;
use warnings;

use Test::More tests => 46;

BEGIN { use_ok('Giovanni::Profile') }

my $profileDir = tempdir( CLEANUP => 1, DIR => $ENV{TMPDIR} );
my $badPublicProfileJson = <<'END';
{
   "IS_LOGGED_IN" : "true",
   "PUBLIC" : {
      "user_type" : "Data Provider Internal User",
      "agreed_to_sentinel_eula" : false,
      "study_area" : "Other",
      "last_name" : "Seiler",
      "member_groups" : [
         "echo"
      ],
      "organization" : "GESDISC",
      "roles" : [
         "giovanniDeveloper",
         "contentViewer"
      ],
      "email_address" : "edward.j.seiler.1@gsfc.nasa.gov",
      "country" : "United States",
      "uid" : "edseiler",
      "agreed_to_meris_eula" : false,
      "registered_date" : "25 Apr 2012 16:55:55PM",
      "allow_auth_app_emails" : true,
      "user_authorized_apps" : 15,
      "user_groups" : [],
      "affiliation" : "COMMERCIAL",
      "authorized_date" : " 7 Jul 2018 01:11:11AM",
      "first_name" : "Edward"
   },
   "PRIVATE" : {
      "expires_in" : 3600,
      "refresh_token" : "82db9d20a04f4f5dee4045adf874bd9e6581999407d70de7df5e8cd6fc3d113a",
      "access_token" : "1ee742e5b1544a8f28412ddae67998286353fbb65af6fb0b568de23a35ef7f9d",
      "token_type" : "Bearer"
   }
END
my $publicProfilePerl = {
    "user_type" => "Data Provider Internal User",
    "agreed_to_sentinel_eula" => 0,
    "study_area" => "Other",
    "last_name" => "Seiler",
    "member_groups" => ["echo"],
    "organization" => "GESDISC",
    "roles" => ["giovanniDeveloper","contentViewer"],
    "email_address" => 'edward.j.seiler.1@gsfc.nasa.gov',
    "country" => "United States",
    "uid" => "edseiler",
    "agreed_to_meris_eula" => 0,
    "registered_date" => "25 Apr 2012 16:55:55PM",
    "allow_auth_app_emails" => 1,
    "user_authorized_apps" => 15,
    "user_groups" => [],
    "affiliation" => "COMMERCIAL",
    "authorized_date" => " 7 Jul 2018 01:11:11AM",
    "first_name" => "Edward"
};
my $privateProfileJson = <<END2;
    "expires_in" : 3600,
    "refresh_token" : "256eaa7247642fbc9445aa1e768ec4424ad0fb1862359745e6849e4e24c13de9",
    "access_token" : "171312a843fd251a7ad0d8a3cbb11ed6ba8284387cd797262327c2c9959b1ad7",
    "token_type" : "Bearer"
END2
my $privateProfilePerl = {
    "expires_in"    => 3600,
    "refresh_token" => "256eaa7247642fbc9445aa1e768ec4424ad0fb1862359745e6849e4e24c13de9",
    "access_token"  => "171312a843fd251a7ad0d8a3cbb11ed6ba8284387cd797262327c2c9959b1ad7",
    "token_type"    => "Bearer"
};
my $profilePerl = { PRIVATE => $privateProfilePerl, PUBLIC => $publicProfilePerl };

my $profile = Giovanni::Profile->new(profileDir => $profileDir, uid => 'edseiler', profile => $profilePerl);
ok($profile, "Created profile from profile ref");
ok(!$profile->onError(), "No error creating profile");
ok(!$profile->errorMessage(), "No error messages creating profile");
my $dirMatch = (defined $profile->getProfileDir()) ? ($profile->getProfileDir() eq $profileDir) : 0;
ok($dirMatch, "getProfileDir() returns correct value");
ok($profile->isLoggedIn(), "User for new profile is logged in");
ok((ref($profile->getRoles()) eq 'ARRAY'), "Found multiple roles");
ok(($profile->getFirstName() eq 'Edward'), "Got first name from profile");
ok(($profile->getLastName() eq 'Seiler'), "Got last name from profile");
ok(($profile->getFullName() eq 'Edward Seiler'), "Got full name from profile");

my $profile2 = Giovanni::Profile->new(profileDir => $profileDir, uid => 'edseiler');
ok($profile2, "Read existing profile from profile directory");
ok(!$profile2->onError(), "No error reading existing profile");
ok(!$profile2->errorMessage(), "No error messages reading existing profile");
my $dirMatch2 = (defined $profile2->getProfileDir()) ? ($profile2->getProfileDir() eq $profileDir) : 0;
ok($dirMatch2, "getProfileDir() returns correct value");
ok($profile2->isLoggedIn(), "User for new profile is logged in");
ok((ref($profile2->getRoles()) eq 'ARRAY'), "Found multiple roles");
ok(($profile2->getFirstName() eq 'Edward'), "Got first name from profile");
ok(($profile2->getLastName() eq 'Seiler'), "Got last name from profile");
ok(($profile2->getFullName() eq 'Edward Seiler'), "Got full name from profile");

my $profile3 = Giovanni::Profile->new(profileDir => $profileDir, uid => 'joeschmo');
ok($profile3, "Read existing profile from profile directory for different user");
ok($profile3->onError(), "Error reading profile for different user");
ok($profile3->errorMessage(), "Error message reading profile for different user");
my $dirMatch3 = (defined $profile3->getProfileDir()) ? ($profile3->getProfileDir() eq $profileDir) : 0;
ok($dirMatch3, "getProfileDir() returns correct value");
ok(!$profile3->isLoggedIn(), "Different user is not logged in");
ok(!$profile3->getRoles(), "Roles unavailable");
ok(!$profile3->getFirstName(), "First name unavailable");
ok(!$profile3->getLastName(), "Last name unavailable");
ok(!$profile3->getFullName(), "Full name unavailable");

my $profile4 = Giovanni::Profile->new(profileDir => $profileDir);
ok($profile4, "Read existing profile from profile directory without uid");
ok(!$profile4->onError(), "No error reading existing profile without uid");
ok(!$profile4->errorMessage(), "No error messages reading existing profile without uid");
my $dirMatch4 = (defined $profile4->getProfileDir()) ? ($profile4->getProfileDir() eq $profileDir) : 0;
ok($dirMatch4, "getProfileDir() returns correct value");
ok($profile4->isLoggedIn(), "User for new profile is logged in");
ok(!$profile4->getRoles(), "Roles unavailable");
ok(!$profile4->getFirstName(), "First name unavailable");
ok(!$profile4->getLastName(), "Last name unavailable");
ok(!$profile4->getFullName(), "Full name unavailable");

my $profile5 = Giovanni::Profile->new();
ok($profile5, "Object created when no profileDir specified");
ok($profile5->onError(), "Error when no profileDir specified");
ok($profile5->errorMessage(), "Error message when no profileDir specified");

my $profile6 = Giovanni::Profile->new(profileDir => '/x/y/z');
ok($profile6, "Object created when profileDir does not exist");
ok($profile6->onError(), "Error when profileDir does not exist");
ok($profile6->errorMessage(), "Error message when profileDir does not exist");

my $profileDir2 = tempdir( CLEANUP => 1, DIR => $ENV{TMPDIR} );
my $profilePath = join('/', $profileDir2, 'profile.json');
open(OUT, "> $profilePath") or die "Could not open $profilePath for writing\n";
print OUT $badPublicProfileJson;
close(OUT);
my $profile7 = Giovanni::Profile->new(profileDir => $profileDir2, uid => 'edseiler');
ok($profile7, "Read bad profile");
ok($profile7->onError(), "Error creating bad profile");
ok($profile7->errorMessage(), "Error messages creating bad profile");
