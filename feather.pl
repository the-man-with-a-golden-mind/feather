#!usr/bin/perl

use strict;
use warnings;
use feature 'switch';
use feature qw(say);
use File::Path qw(rmtree);
use File::Spec;

no warnings "experimental::smartmatch";

sub check_exists_command { 
    my $check = `sh -c 'command -v $_[0]'`; 
    return $check;
}

sub clean_feather {
  rmtree "./ol/";
  unlink("run.sh");
}

sub clean_ol {
  rmtree "./ol/samples";
  rmtree "./ol/tests";
  rmtree "./ol/tmp";
  rmtree "./ol/.git";
  rmtree "./ol/.github";
}


sub make_run_file {
  # @TODO: If I would even need to run it on windows.
  #my $sep = File::Spec->catfile('', '');
  my $shell = $ENV{SHELL};
  my $alias_file = "run.sh";
  #rlwrap is not recognizing aliases :/
  #my $rlwrap = length(check_exists_command("rlwrap")) > 0 ? "rlwrap" : "";
  open(my $fh, ">", $alias_file) or die "Could not creaate .alias file";
  my $content = "
    #!$shell
    alias ol=\"./ol/ol\"
    ol \$@
  ";

  print $fh $content;
  close $fh;
  system("chmod u+x run.sh");
  say("Run file has been created");
}

sub build_ol {
  say("I am trying to build Ol...");
  my $result = system("cd ./ol && make");
  if ($result == 0) {
    make_run_file();
    clean_ol();
  } else {
    say("Somethings has crashed. Check logs");
  }
}

sub download_ol {
  my $otus_link = "https://github.com/yuriy-chumak/ol";
  say("Downloading new Ol instance");
  system("git", "clone", "--depth=1", "--branch=master",  $otus_link);
  say("Ol has been downloaded");
}

sub update_ol {
  say("Updating existing instance of Ol");
  rmtree "./ol";
  download_ol();
  build_ol();
  }

sub install_ol {
  say("Installing Ol...");
  if (-d "ol") {
    update_ol();
  } else {
    download_ol();
    build_ol();
  }
}

sub print_help {
  say("HELLP");
}

sub parse_command {
  my ($command) = (@_);
   given ($command) {
      when (/^init/) { install_ol() }
      when (/^update/) { update_ol() }
      when (/^link/) { make_run_file() }
      when (/^clean/) { clean_feather() }
      default { print_help() }
    } 
}

sub parse_argv {
  my @args = shift(@_);
  if ((scalar @args) > 0) {
    my $command = $args[0];
    parse_command($command); 
  }
}

parse_argv(@ARGV);
